---
title: golang 依赖注入
date: 2020-08-15
private: true
---
# golang 依赖注入
> 本文转自：https://www.cyhone.com/articles/facebookgo-inject/

依赖注入是一个经典的设计模式，在解决复杂的对象依赖关系方面是一个非常行之有效的手段。

对于有反射功能的语言来说，实现依赖注入都比较方便一些。在 Golang 中有几个比较知名的依赖注入开源库，例如 google/wire、uber-go/dig 以及 facebookgo/inject 等。

本文将基于 facebookgo/inject 介绍依赖注入, 接下来将会着重讨论以下几点内容：

1. 依赖注入的背景以及解决的问题
1. facebookgo/inject 的使用方法
1. facebookgo/inject 的缺陷

# 依赖注入的背景
对于稍微复杂些的项目，我们往往就会遇到对象之间复杂的依赖关系。手动管理和初始化这些管理关系将会极其繁琐，依赖注入可以帮我们自动实现依赖的管理和对象属性的赋值，将我们从这些繁琐的依赖管理中解放出来。

以一个常见的 HTTP 服务为例，我们在开发后台时往往会把代码分为 Controller、Service 等层次。如下：

    type UserController struct {
        UserService *UserService
        Conf        *Conf
    }

    type PostController struct {
        UserService *UserService
        PostService *PostService
        Conf        *Conf
    }

    type UserService struct {
        Db   *DB
        Conf *Conf
    }

    type PostService struct {
        Db *DB
    }

    type Server struct {
        UserApi *UserController
        PostApi *PostController
    }

上述的代码例子中，有两个 Controller：UserController 和 PostController，分别用来接收用户和文章的相关请求逻辑。除此之外还会有 Service 相关类、Conf 配置文件、DB 连接等。

这些对象之间存在比较复杂的依赖关系，这就给项目的初始化带来了一些困扰。对于以上代码，对应初始化逻辑大概就会是这样:

    func main() {
        conf := loadConf()
        db := connectDB()

        userService := &UserService{
            Db:   db,
            Conf: conf,
        }

        postService := &PostService{
            Db: db,
        }

        userHandler := &UserController{
            UserService: userService,
            Conf:        conf,
        }

        postHandler := &PostController{
            UserService: userService,
            PostService: postService,
            Conf:        conf,
        }

        server := &Server{
            UserApi: userHandler,
            PostApi: postHandler,
        }

        server.Run()
    }

我们会有一大段的逻辑都是用来做对象初始化，而当接口越来越多的时候，整个初始化过程就会异常的冗长和复杂。

针对以上问题，依赖注入可以完美的解决。

# facebookgo/inject 的使用
接下来，我们试着使用 facebookgo/inject 的方式，对这段代码进行依赖注入的改造。如下：

    type UserController struct {
        UserService *UserService `inject:""`
        Conf        *Conf        `inject:""`
    }

    type PostController struct {
        UserService *UserService `inject:""`
        PostService *PostService `inject:""`
        Conf        *Conf        `inject:""`
    }

    type UserService struct {
        Db   *DB   `inject:""`
        Conf *Conf `inject:""`
    }

    type PostService struct {
        Db *DB `inject:""`
    }

    type Server struct {
        UserApi *UserController `inject:""`
        PostApi *PostController `inject:""`
    }

    func main() {
        conf := loadConf() // *Conf
        db := connectDB() // *DB

        server := Server{}

        graph := inject.Graph{}

        if err := graph.Provide(
            &inject.Object{
                Value: &server,
            },
            &inject.Object{
                Value: conf,
            },
            &inject.Object{
                Value: db,
            },
        ); err != nil {
            panic(err)
        }

        if err := graph.Populate(); err != nil {
            panic(err)
        }

        server.Run()
    }

首先每一个需要注入的字段都需要打上 inject:"" 这样的 tag。所谓依赖注入，这里的依赖指的就是对象中包含的字段，而注入则是指有其它程序会帮你对这些字段进行赋值。

其次，我们使用 inject.Graph{} 创建一个 graph 对象。这个 graph 对象将负责管理和注入所有的对象。至于为什么叫 Graph，其实这个名词起的非常形象，因为各个对象之间的依赖关系，也确实像是一张图一样。

接下来，我们使用 graph.Provide() 将需要注入的对象提供给 graph。

    graph.Provide(
        &inject.Object{
            Value: &server,
        },
        &inject.Object{
            Value: &conf,
        },
        &inject.Object{
            Value: &db,
        },
    );

最后调用 Populate 函数，开始进行注入。

从代码中可以看到，我们一共就向 Graph 中 Provide 了三个对象。我们提供了 server 对象，是因为它是一个顶层对象。提供了 conf 和 db对象，是因为所有的对象都依赖于它们，可以说它们是基础对象了。

但是其他的对象呢？ 例如 UserApi 和 UserService 呢？我们并没有向 graph 调用 Provide 过。那么它们是怎么完成赋值和注入的呢？

其实从下面这张对象依赖图能够很简单的看清楚。

        |--UserHandler-------->-------├
        |       |                     |
    Server      |->UserService------->conf
        |       |                     |
        |--PostHandler-----------------
                ├
                └->PostService-------->db

从这个依赖图中可以看出，conf 和 db 对象是属于根节点，所有的对象都依赖和包含着它们。而 server 属于叶子节点，不会有其他对象依赖它了。

我们需要提供给 Graph 的就是根节点和叶子节点，对于中间节点来说，Graph 会通过 inject:"" 标签，自动将其 Provide 到 Graph 中，并进行注入。

对以上例子，我们深入剖析下 Graph 内部进行 Populate 时都发生了哪些动作:

1. Graph 首先解析 server 对象，发现其有两个标记为 inject 的字段：UserApi 和 PostApi。其类型 UserController 和 PostController, Graph 中从未出现过这两个类型。因此，Graph 会自动对该字段调用 Provide，提供给 Graph。
2. 解析 UserApi 时，发现其依然有也有两个标记为 inject 的字段：UserService 和 Conf。对于 UserService 这种 Graph 中未登记过的类型，会自动 Provide。而对 Conf, Graph 中之前已经注册过了，因此直接将注册的对象赋值给该字段即可。
3. 接下来就是继续逐步解析，直至没有tag为 inject 的字段。

以上就是整个依赖注入的流程了。

这里需要注意的是，在我们上面的示例中，以这种方式注入，其中所有的对象都相当于单例对象。即一个类型，只会在 Graph 中存在一个实例对象。比如 `UserController 和 PosterController` 中的 `UserService` 实际上是同一个对象。

我们的 main 函数使用 inject 进行改造后，将会变得非常简洁。而且即使随着业务越来越复杂，Handler 和 Service 越来越多，这个 main 函数中的注入逻辑也不会任何改变，除非有新的根节点对象出现。

当然，对于 Graph 来说，也不是只能 Provide 根节点和叶子节点，我们也可以自行 Provide 一个 UserService 的实例进去，对于 Graph 的运作是没有任何影响的。只不过只 Provide 根节点和叶子节点，代码会更简洁一些。

# inject 的高级用法
我们在声明 tag 时，除了声明为 `inject:""` 这种默认用法外，还可以有其他三种高级的用法:

    inject:"private"。私有注入。
    inject:"inline"。内联注入。
    inject:"object_name"。命名注入，这里的 object_name 可以取成任意的名字。

## private (私有注入)
我们上文讲过，默认情况下，所有的对象都是单例对象。一个类型只会有一个实例对象存在。但也可以不使用单例对象，private 就是提供了这种可能。

    type UserController struct {
        UserService *UserService `inject:"private"`
        Conf        *Conf        `inject:""`
    }

我们将 UserController 中的 UserService 属性声明为 private 注入。这样的话，graph 遇到 private 标签时，会自动的 new 一个全新的 UserService 对象，将其赋值给该字段。

这样 Graph 中就同时存在了两个 UserService 的实例，一个是 UserService 的全局实例，给默认的 inject:"" 使用。一个是专门给 UserController 实例中的 UserService 使用。

但在实际开发中，这种 private 的场景似乎也比较少，大部分情况下，默认的单例对象就足够了。

## inline (内联注入)
默认情况下，需要注入的属性必须得是 *Struct。但是也是可以声明为普通对象的。例如：

    type UserController struct {
        UserService UserService `inject:"inline"`
        Conf        *Conf       `inject:""`
    }

注意，这里的 UserService 的类型，并非是 `*UserService` 指针类型了，而是普通的 struct 类型。struct 类型在 Go 里面都是值语义，这里当然也就不存在单例的问题了。

## 命名注入
如果我们需要对某些字段注入专有的对象实例，那么我们可能会用到命名注入。使用方法就是在 inject 的 tag 里写上专有的名字。如下：

    type UserController struct {
        UserService UserService `inject:"named_service"`
        Conf        *Conf       `inject:""`
    }

当然，这个命名肯定不能命名为 private 和 inline，这两个属于保留词。

同时，我们一定要把这个命名实例 Provide 到 graph 里面，这样 graph 才能把两个对象联系起来。

    graph.Provide(
        &inject.Object{
            Value: &namedService,
            Name: "named_service",
        },
    );

##　注入 map
我们除了可以注入对象外，还可以注入 map。如下：

    type UserController struct {
        UserService UserService       `inject:"inline"`
        Conf        *Conf             `inject:""`
        UserMap     map[string]string `inject:"private"`
    }

需要注意的是，map 的注入 tag 一定要是 inject:"private"。

# facebookgo/inject 的缺陷
facebookgo/inject 固然很好用，只要声明 `inject:""` 的 tag，提供几个对象，就可以完全自动的注入所有依赖关系。

但是由于Golang本身的语言设计， facebookgo/inject 也会有一些缺陷和短板：

1. 所有需要注入的字段都需要是 public 的。 这也是 Golang 的限制，不能对私有属性进行赋值。所以只能对public的字段进行注入。但这样就会把代码稍显的不那么优雅，毕竟很多变量我们其实并不想 public。

2. 只能进行属性赋值，不能执行初始化函数。 facebookgo/inject只会帮你注入好对象，把各个属性赋值好。但很多时候，我们往往需要在对象赋值完成后，再进行其他一些动作。但对于这个需求场景，facebookgo/inject并不能很好的支持。

这两个问题的原因总结归纳为：Golang没有构造函数……