---
title: gonic
date: 2019-04-22
private:
---
# Request Bind
## binding 属性required 
传`0`，`""` 空字符相当于没传
1. binding:"required" 限制了，不能传`0`，`""` 空字符等等！！！
1. binding:"-" 不限制

    struct{
        PackageType int    `form:"package_type" binding:"required"`
        Peg int    `form:"peg" binding:"-"`
    }

## Uri args
### one uri param

    r := gin.Default()
	r.GET("/user/:name", func(c *gin.Context) {
        name := c.Param("name")
    }

### ShoudBindUri

    type Person struct {
        ID string `uri:"id" binding:"required,uuid"`
        Name string `uri:"name" binding:"required"`
    }
    route.GET("/:name/:id", func(c *gin.Context) {
		var person Person
        if err := c.ShouldBindUri(&person); err != nil {
            c.AbortWithError(http.StatusBadRequest, err)
            return
        }

### BindUri
    func (c *Context) BindUri(obj interface{}) error {
        if err := c.ShouldBindUri(obj); err != nil {
            c.AbortWithError(http.StatusBadRequest, err).SetType(ErrorTypeBind) 
            return err
        }
        return nil
    }

## One key param(get/post)
### get one key
query('id') 

    id := c.Query("id") // shortcut for c.Request.URL.Query().Get("id") 默认是空字符
        id, _ := c.GetQuery("id")

    _, isDebug := c.GetQuery("id")

default query

    page := c.DefaultQuery("page", "0")

### post one key
PostForm('name')

    name := c.PostForm("name")  //默认是空
    nick := c.DefaultPostForm("nick", "anonymous")

## Bind 方法
Note: 
1. 注意bind 成员需要大写！ > 小写的成员无效, 且不会报err (go-lib/gonic/bind/bind.go)
1. 需要使用引用：`bind(&query)`

### bind struct 定义
    type Person struct {
        ID string `uri:"id" binding:"required,uuid"`
        Name string `form:"name"` // post form 字段
        Age in `json:"age"`     // post application/json 字段
    }

gonic 目前只支持RFC3339, time_format 不起作用（2020.01.02）

    EndTime   *time.Time `json:"end_time" form:"end_time" time_format:"2012-11-01T22:08:41+08:00"`

### Must and Should
gin 有两套[Bind](https://gin-gonic.com/docs/examples/binding-and-validation/):
1. 基于 MustBindWith： Bind, BindJSON, BindXML, BindQuery, BindYAML
    1. error发生时： `c.AbortWithError(400, err).SetType(ErrorTypeBind)`.
    2. 同时header： is set to `text/plain; charset=utf-8`.
2. 基于 ShouldBindWith： ShouldBind, ShouldBindJSON, ShouldBindXML, ShouldBindQuery, ShouldBindYAML
    1. 返回err, 自己控制error

### Bind:get+post(post优先)
同时包含post+get(post优先)

    type StructA struct {
        FieldA string `form:"field_a"`
    }
    type StructB struct {
        NestedStruct StructA
        //NestedStruct *StructA 也行
        FieldB string `form:"field_b"`
    }

    var b StructB
    c.Bind(&b)
    $ curl "http://localhost:8080/getb?field_a=hello&field_b=world"
    {"a":{"FieldA":"hello"},"b":"world"}

#### bind checkbox

    type myForm struct {
        Colors []string `form:"colors[]"`
    }

### shoudBind:get+post(post优先)
需要用到注解:`form:"key"`

#### ShouldBind
方法 - ShouldBind, ShouldBindJSON, ShouldBindQuery
行为 - 这些方法在底层使用 ShouldBindWith

    type myForm struct {
        querya string `form:"a"`
    }
    err := c.ShouldBind(&myForm)
    $ curl -X GET "localhost:8085/testing?a=1

#### ShouldBindWith
    "github.com/gin-gonic/gin/binding"
    type LoginForm struct {
        User     string `form:"user" binding:"required" json:"user"`
        Password string `form:"password" binding:"required"`
    }

    if c.ShouldBindWith(&form, gonic.binding.Query)
    if c.ShouldBind(&form) == nil 

### showBindQuery:get only
    type myForm struct {
        querya string `form:"a"`
    }
    c.ShouldBindQuery(&myForm) 

### Bind:json
    var json struct {
        Value string `json:"value" binding:"required"`
    }
    c.Bind(&json)

test：

    curl -H 'Content-type:application/json' http://foo:bar@localhost:8080/admin -d '{"value":"abc"}'

## Bind Multiple
[Bind 执行时，c.Request.Body 会到达 EOF](https://gin-gonic.com/docs/examples/bind-body-into-dirrerent-structs/)

如果想让bind body different structs， 就copy body出来, 再用`ShouldBindBodyWith`

    objA := formA{}
    objB := formB{}
    if errA := c.ShouldBindBodyWith(&objA, binding.JSON); errA == nil {
        c.String(http.StatusOK, `the body should be formA`)
    } else if errB2 := c.ShouldBindBodyWith(&objB, binding.XML); errB2 == nil {
        c.String(http.StatusOK, `the body should be formB XML`)
    } else {
        ...
    }

This feature is:
1. only needed for some formats – `JSON, XML, MsgPack, ProtoBuf`.
2. For other formats, `Query, Form, FormPost, FormMultipart`, can be called by `c.ShouldBind()` multiple times without any damage to performance 

## Bind map
### QueryMap:GET
    POST /post?ids[a]=1234&ids[b]=hello HTTP/1.1
    Content-Type: application/x-www-form-urlencoded

    names[first]=thinkerou&names[second]=tianou

    func main() {
        router := gin.Default()

        router.POST("/post", func(c *gin.Context) {

            ids := c.QueryMap("ids")
            names := c.PostFormMap("names")

            fmt.Printf("ids: %v; names: %v", ids, names)
        })
        router.Run(":8080")
    }
### PostFormMap:POST
    names := c.PostFormMap("names")

## Multipart(post)
### Multipart/Urlencoded
这是默认的post `curl  "https://httpbin.org/post"  -d 'file=go&bucket=bucketpath&a=1`

Test it with:

    $ curl -v --form user=user --form password=password http://localhost:8080/login
    $ curl -v -d 'user=user&password=password' http://localhost:8080/login

### Multipart/file(form-data)
    // 'Content-Type: multipart/form-data; boundary=---xxx'
    curl  "https://httpbin.org/post"  -F 'file=@a.txt' -F 'key=value'

#### via bind
c.SaveUploadedFile(file, dst+"/a.txt") 会覆盖旧文件

    //https://github.com/gin-gonic/examples/blob/master/file-binding/main.go
    type BindFile struct {
        Name  string                `form:"name" binding:"required"`
        Email string                `form:"email" binding:"required"`
        File  *multipart.FileHeader `form:"file" binding:"required"`
        Files  []*multipart.FileHeader `form:"files[]" binding:"required"` //??
    }

    var bindFile BindFile
    // Bind file
    if err := c.ShouldBind(&bindFile); err != nil {
        c.String(http.StatusBadRequest, fmt.Sprintf("err: %s", err.Error()))
        return
    }
    // Save uploaded file
    file := bindFile.File //FileHeader
    dst := filepath.Base(file.Filename)
    if err := c.SaveUploadedFile(file, dst); err != nil {
        c.String(http.StatusBadRequest, fmt.Sprintf("upload file err: %s", err.Error()))
        return
    }


#### via multiparForm()
    curl -X POST http://localhost:8080/upload \
        -F "upload[]=@/Users/appleboy/test2.zip" \
        -H "Content-Type: multipart/form-data"


    form, _ := c.MultipartForm()
    fmt.Printf("Value: %#v\n", form.Value["bucket"])
    files := form.File["upload[]"]

    for _, file := range files {
        log.Println(file.Filename) //含扩展名
			// Upload the file to specific dst.
			// c.SaveUploadedFile(file, dst)
		}

#### single FromFile

single file:

    file File
    file, header , err := c.Request.FormFile("upload")
    out, err := os.Create("./tmp/"+header.Filename)
    defer out.Close()
    _, err = io.Copy(out, file)

single fileHeader

    fileHeader, err := c.FormFile("file")
    log.Println(fileHeader.Filename) //含扩展名

    fileHeader *multipart.FileHeader
        .Size
        .Filename
        .content, 
        .tmpfile 

##### open file
fileHeader

    // getFileHeader
    fileHeader := c.FormFile("upload")

    //fp = fileHeader.Open()
    func (fh *FileHeader) Open() (File, error) {
        if b := fh.content; b != nil {
            r := io.NewSectionReader(bytes.NewReader(b), 0, int64(len(b)))
            return sectionReadCloser{r}, nil
        }
        return os.Open(fh.tmpfile)
    }



## Read Raw Body
https://github.com/gin-gonic/gin/issues/961

    func BindServer(c *gin.Context) {
    	//backup
    	buf, _ := ioutil.ReadAll(c.Request.Body)
        // revert
    	c.Request.Body = ioutil.NopCloser(bytes.NewBuffer(buf)) // important!!

        // bind
    	query := struct {
    		Name string `json:"name"`
    	}{}
    	if err := c.ShouldBind(&query); err != nil {
    		println("bind error:", err)
    	}
    	fmt.Println(1, query)

        // revert
    	c.Request.Body = ioutil.NopCloser(bytes.NewBuffer(buf)) // important!!

    	res := ""
    	c.String(http.StatusOK, res)

    }

另外:

    func readBody(body io.Reader) string {
        // reader = ioutil.NopCloser(bytes.NewBuffer(buf))

        buf := new(bytes.Buffer)
        buf.ReadFrom(body)

        s := buf.String()
        return s
    }


### Body Stream
https://github.com/gin-gonic/gin/pull/857/files

    func (c *Context) GetRawData() ([]byte, error) {
        return ioutil.ReadAll(c.Request.Body)


# Request Info

## clientIp
    r := gin.New()
    r.ForwardedByClientIP = false //默认是true
    func (c *Context) ClientIP() string {

## request  info
Request   *http.Request

    c.Request.URL.Path = "/test2"
    c.Request.Host // host:port
    c.Request.Method
    c.ClientIP()
    c.Request.UserAgent()

## headers

    origin := c.Request.Header.Get("Origin")
    origin := c.Request.Header.Get("Referer")

response info

    c.Writer.Status()

## request URL

    c.Request.URL.Path
    c.Request.URL.RawQuery

## cookie
    cookie, err := c.Cookie("gin_cookie")
    if err != nil {
        cookie = "NotSet"
        c.SetCookie("gin_cookie", "test", 3600, "/", "localhost", false, true)
    }

# Custom validators
It is also possible to register custom validators. See the example code.

    package main

    import (
        "net/http"
        "reflect"
        "time"

        "github.com/gin-gonic/gin"
        "github.com/gin-gonic/gin/binding"
        "gopkg.in/go-playground/validator.v8"
    )

    // Booking contains binded and validated data.
    type Booking struct {
        CheckIn  time.Time `form:"check_in" binding:"required,bookabledate" time_format:"2006-01-02"`
        CheckOut time.Time `form:"check_out" binding:"required,gtfield=CheckIn" time_format:"2006-01-02"`
    }

    func bookableDate(
        v *validator.Validate, topStruct reflect.Value, currentStructOrField reflect.Value,
        field reflect.Value, fieldType reflect.Type, fieldKind reflect.Kind, param string,
    ) bool {
        if date, ok := field.Interface().(time.Time); ok {
            today := time.Now()
            if today.Year() > date.Year() || today.YearDay() > date.YearDay() {
                return false
            }
        }
        return true
    }

    func main() {
        route := gin.Default()

        if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
            v.RegisterValidation("bookabledate", bookableDate)
        }

        route.GET("/bookable", getBookable)
        route.Run(":8085")
    }

    func getBookable(c *gin.Context) {
        var b Booking
        if err := c.ShouldBindWith(&b, binding.Query); err == nil {
            c.JSON(http.StatusOK, gin.H{"message": "Booking dates are valid!"})
        } else {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        }
    }
