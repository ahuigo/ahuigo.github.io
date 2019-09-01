---
title: gonic
date: 2019-04-22
private:
---
# Request bind
## required
Required 限制了，不能传`0`，`""` 空字符等等！！！

    struct{
        PackageType int    `form:"package_type" binding:"required"`
    }

## Uri args
### one uri param
	r.GET("/user/:name", func(c *gin.Context) {
    name := c.Param("name")
    name := c.Params.ByName("name")


## ShoudBindUri

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

## bind struct: (get+post)
> Note: 注意bind 成员需要大写！
同时包含post+get(post优先)

    type StructA struct {
        FieldA string `form:"field_a"`
    }
    type StructB struct {
        NestedStruct StructA
        FieldB string `form:"field_b"`
    }

    var b StructB
    c.Bind(&b)
    $ curl "http://localhost:8080/getb?field_a=hello&field_b=world"
    {"a":{"FieldA":"hello"},"b":"world"}

### get+post：shoudBind(post优先)

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

### get only: showBindQuery
    c.ShouldBindQuery(&fakeForm) 

## map
### get map:QueryMap 
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
### post map:PostFormMap
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

## cookie
    cookie, err := c.Cookie("gin_cookie")
    if err != nil {
        cookie = "NotSet"
        c.SetCookie("gin_cookie", "test", 3600, "/", "localhost", false, true)
    }

# Response
## JSON
    c.JSON(http.StatusOK, gin.H{"user": user, "value": value})
## string
    c.String(http.StatusOK, name)