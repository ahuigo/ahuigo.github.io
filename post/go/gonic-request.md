---
title: gonic
date: 2019-04-22
private:
---
# Request bind
## required
传`0`，`""` 空字符相当于没传
Required 限制了，不能传`0`，`""` 空字符等等！！！

    struct{
        PackageType int    `form:"package_type" binding:"required"`
    }

## Uri args
### one uri param

    r := gin.Default()
	r.GET("/user/:name", func(c *gin.Context) {
        name := c.Param("name")
        name := c.Params.ByName("name")
    }

### ShoudBindUri

    type Person struct {
        ID string `uri:"id" binding:"required,uuid"`
        Name string `uri:"name" binding:"required"`
    }
    route.GET("/:name/:id", func(c *gin.Context) {
		var person Person
		if err := c.ShouldBindUri(&person);


## One key param(get/post)
### get one key
query('id') 

    id := c.Query("id") // shortcut for c.Request.URL.Query().Get("id")
    page := c.DefaultQuery("page", "0")

### post one key
PostForm('name')

    name := c.PostForm("name")  //默认是空
    nick := c.DefaultPostForm("nick", "anonymous")

## Bind struct
> Note: 注意bind 成员需要大写！

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

#### ShouldBind

    type myForm struct {
        querya string `form:"a"`
    }
    err := c.ShouldBind(&fakeForm)
    $ curl -X GET "localhost:8085/testing?a=1

#### ShouldBindWith
    "github.com/gin-gonic/gin/binding"
    type LoginForm struct {
        User     string `form:"user" binding:"required"`
        Password string `form:"password" binding:"required"`
    }

    if c.ShouldBindWith(&form, gonic.binding.Query)
    if c.ShouldBind(&form) == nil 

### showBindQuery:get only:
    c.ShouldBindQuery(&fakeForm) 

### Bind:json
    var json struct {
        Value string `json:"value" binding:"required"`
    }
    c.Bind(&json)

test：

    curl -H 'Content-type:application/json' http://foo:bar@localhost:8080/admin -d '{"value":"abc"}'

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
    file := bindFile.File
    dst := filepath.Base(file.Filename)
    if err := c.SaveUploadedFile(file, dst); err != nil {
        c.String(http.StatusBadRequest, fmt.Sprintf("upload file err: %s", err.Error()))
        return
    }


#### via multiparForm()

    form, _ := c.MultipartForm()
    fmt.Printf("Value: %#v\n", form.Value["bucket"])
    files := form.File["upload[]"]

    for _, file := range files {
        log.Println(file.Filename)
			// Upload the file to specific dst.
			// c.SaveUploadedFile(file, dst)
		}
    curl -X POST http://localhost:8080/upload \
        -F "upload[]=@/Users/appleboy/test2.zip" \
    -H "Content-Type: multipart/form-data"

#### single FromFile

    // single file
    file, _ := c.FormFile("file")
    log.Println(file.Filename)

#### open file
fileHeader

    // getFileHeader
    fileHeader := c.FormFile("upload")
    fileHeader *FileHeader
        .content, 
        .Filename
        *multipart.FileHeader

    //fp = fileHeader.Open()
    func (fh *FileHeader) Open() (File, error) {
        if b := fh.content; b != nil {
            r := io.NewSectionReader(bytes.NewReader(b), 0, int64(len(b)))
            return sectionReadCloser{r}, nil
        }
        return os.Open(fh.tmpfile)
    }

file:

    file File
    file, header , err := c.Request.FormFile("upload")
    out, err := os.Create("./tmp/"+header.Filename+".png")
    defer out.Close()
    _, err = io.Copy(out, file)

### Body Stream
https://github.com/gin-gonic/gin/pull/857/files

    func (c *Context) GetRawData() ([]byte, error) {
        return ioutil.ReadAll(c.Request.Body)

# Request Info
## URL

    c.Request.URL.Path

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

# Response
## JSON
    c.JSON(http.StatusOK, gin.H{"user": user, "value": value})
## string
    c.String(http.StatusOK, name)

## Html

### LoadHTMLGlob
    func main() {
        router := gin.Default()
        router.LoadHTMLGlob("templates/**/*")
        router.GET("/posts/index", func(c *gin.Context) {
            c.HTML(http.StatusOK, "posts/index.tmpl", gin.H{
                "title": "Posts",
            })
        })
        router.GET("/users/index", func(c *gin.Context) {
            c.HTML(http.StatusOK, "users/index.tmpl", gin.H{
                "title": "Users",
            })
        })
        router.Run(":8080")
    }

templates/posts/index.tmpl， `define-end`不是必须的，只是方便引入?

    {{ define "posts/index.tmpl" }}
    <html><h1>
        {{ .title }}
    </h1>
    </html>
    {{ end }}

### Static
    // /assets/a.js
    r.Static("/assets", "./assets")

### Custom Template renderer
    import "html/template"

    func main() {
        router := gin.Default()
        html := template.Must(template.ParseFiles("file1", "file2"))
        router.SetHTMLTemplate(html)
        router.GET("/raw", func(c *gin.Context) {
            c.HTML(http.StatusOK, "file1")
        })
        router.Run(":8080")
    }

also:

    var html = template.Must(template.New("file1").Parse(` <html> </html> `))

### LoadHTMLFiles

    // store raw.tmpl
    router.LoadHTMLFiles("./testdata/raw.tmpl")

    router.GET("/raw", func(c *gin.Context) {
        c.HTML(http.StatusOK, "raw.tmpl", map[string]interface{}{
            "now": time.Date(2017, 07, 01, 0, 0, 0, 0, time.UTC),
        })
    })

### Dlimiter
	r := gin.Default()
	r.Delims("{[{", "}]}")
	r.LoadHTMLGlob("/path/to/templates")

### Pipe Func
	import "html/template"

    func formatAsDate(t time.Time) string {
        year, month, day := t.Date()
        return fmt.Sprintf("%d%02d/%02d", year, month, day)
    }

    func main() {
        router := gin.Default()
        router.Delims("{[{", "}]}")
        router.SetFuncMap(template.FuncMap{
            "formatAsDate": formatAsDate,
        })
        router.LoadHTMLFiles("./testdata/raw.tmpl")

        router.GET("/raw", func(c *gin.Context) {
            c.HTML(http.StatusOK, "raw.tmpl", map[string]interface{}{
                "now": time.Date(2017, 07, 01, 0, 0, 0, 0, time.UTC),
            })
        })

raw.tmpl

    Date: {[{.now | formatAsDate}]}

## http2 and push
https://gin-gonic.com/docs/examples/http2-server-push/
> pem 生成见ssl-tool.md

    r := gin.Default()
	r.Static("/assets", "./assets")
	r.SetHTMLTemplate(html)

	r.GET("/", func(c *gin.Context) {
		if pusher := c.Writer.Pusher(); pusher != nil {
			// use pusher.Push() to do server push
			if err := pusher.Push("/assets/app.js", nil); err != nil {
				log.Printf("Failed to push: %v", err)
			}
		}
		c.HTML(200, "https", gin.H{
			"status": "success",
		})
	})

	// Listen and Server in https://127.0.0.1:8080
	r.RunTLS(":8080", "./testdata/server.pem", "./testdata/server.key")