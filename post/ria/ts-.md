# 初学 Typescript
最近一直在使用vue+babel 做东西（rollup来打包）。不过babel+vue 这两货的配合在遇到装饰器时就有点问题：
vue 肯定要先处理SFC(Single File Component)后才能用babel 处理, 但是Vue 又不能处理decorator。

但是vue 能很好的解析typescript, ts 不仅提供decorator, 还提供强类型，代码提示，所以今天就来了解下typescript。 
> 隆重推荐下typescript 精通指南：https://nodelover.gitbook.io/typescript/ji-chu-ren-zhi

## ts hello world
编写ts hello world 后，用tsc 编译

    tsc hello.ts

如果想编译为es6, 我们生成编译配置

    tsc --init; # vi tsconfig.json 手动配置
    tsc 
    tsc --p tsconfig.json
    tsc hello.ts; # 编译单文件 和 使用tsconfig.json 不能同时

## 代码补全
输入关键字后，vscode 会自动基于`ts`补全。但是对于纯js 文件，由于没有强类型，很难做到补全。我们可以手写`.d.ts`. 

`ts` 也可以生成`.d.ts`:

    tsc hello.ts -d

## type

    string
    number
    Array<string> or string[]
    enum Choose { Wife = 1, Mother = 2} // 选择 妻子 还是 妈妈

## interface 接口

    interface Person{
        readonly IdCard: string; // 身份证号
    }
    class Person implements Person{
        readonly IdCard: string = "42xxxxxxxxxxxxxxx";
        constructor(){}
    }

或者字面量

    let person: Person =  { IdCard:'43xxxxxxxxx' }

### 可选属性

    class Person implements Person{
        readonly IdCard: string = "42xxxxxxxxxxxxxxx";
        name?:string;
    }
    let person: Person = { IdCard:'43xxxxxxxxx',name:"ahui" }

### 任意propName

    interface Person{
        readonly IdCard: string; // 身份证号
        name?: string;
        [propName : string]: any;
    }
    ​
    let person: Person =  { IdCard:'43xxxxxxxxx' }
    ​
    function getPerson(p: Person) {
        console.log(p);
    }
    ​
    getPerson({ IdCard: 's', b : 2 })

### class 属性

    class Dad{
        protected surname; // 姓氏
        private private_money; // 私房钱
        public public_something;
        default_something;
        constructor(){}
    }

### 描述 function

    interface Db {
        host: string;
        port: number;
    }
    ​
    interface InitFunc{
        (options: Db) : string;
    }
    ​
    ​
    let myfunc : InitFunc = function (opts: Db) {
        return '';
    }

### 描述method

    interface test{
        constructor(year: string, month: string, day: string);
    }
    ​
    let a3 : test = {
        constructor(year: string, month: string, day: string){
    ​
        }
    }

### 描述 实例化
    interface MyDateInit {
        new (year: string, month: string, day: string) : MyDate;
    }

    function getDate(Class: MyDateInit, { year, month, day }) : MyDate{
        return new Class(year, month, day);
    }

### 描述混合类型
    interface Counter {
        (start: number): string;
        interval: number;
        reset(): void;
    }
    ​
    function getCounter(): Counter {
        let counter = <Counter>function (start: number) {console.log('start is ' + start)};
        counter.interval = 123;
        counter.reset = function () {console.log('do you want reset counter?')};
        return counter;
    }
    ​
    let c = getCounter();
    c(10);
    c.reset();
    c.interval = 5.0;
    ​
    console.dir(c)

## 函数

    class Chicken{}
    class Beef{}
    ​
    function cooking(food : Chicken | Beef ) {
        if(food instanceof Chicken) {
            console.log("vscode 提示chicken:", food);
            console.log("煮鸡肉呀~ 我最喜欢吃~");
        }
    }

## 创建一个ts 项目
手动或者用vue-cli 自动创建

    $ npm install -g vue-cli
    $ vue init vuets/rollup-simple-vue2 my-project
    $ cd my-project
    $ npm install
    $ npm run dev

可以再vscode 中手动创建：https://www.cnblogs.com/hammerc/p/7413228.html

    1.创建tsconfig.json，使用命令行在项目文件夹下输入“tsc --init”即可；
    2.创建tasks.json，在VSCode中，使用ctrl+shift+p打开命令板，然后输入configure task Runner，按回车选择typescript-tsconfig.json即可；
    3.执行tasks.json的命令，即把.ts编译为.js文件，按ctrl+shift+b可以执行该命令，如果报错，可以重启VSCode试试；
    4.按下"F5"，配置和创建launch.json文件，后续只要按下"F5"即可执行；
    5.执行"npm install @types/node --save-dev"命令生成node的对应.d.ts文件