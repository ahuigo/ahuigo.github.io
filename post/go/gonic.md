---
title: gonic
date: 2019-04-22
---
# gonic time
time.Time accept format

    2002-10-02T10:00:00-05:00
    2002-10-02T15:00:00Z
    2002-10-02T15:00:00.05Z

# debug
Required 限制了，不能传0，"" 空字符等等！！！

    struct{
        PackageType int    `form:"package_type" binding:"required"`
    }

# gonic bind

## bind: query

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

shoudBind query:

    type myForm struct {
        querya string `form:"a"`
    }
    c.ShouldBind(&fakeForm)
    c.ShouldBindQuery(&fakeForm) 
    $ curl -X GET "localhost:8085/testing?a=1

### QueryMap and PostFormMap
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

## ShoudBindUri

    type Person struct {
        ID string `uri:"id" binding:"required,uuid"`
        Name string `uri:"name" binding:"required"`
    }
    route.GET("/:name/:id", func(c *gin.Context) {
		var person Person
		if err := c.ShouldBindUri(&person);

or 

    router.GET("/user/:name", func(c *gin.Context) {
		name := c.Param("name")

## Multipart/Urlencoded + form-data
curl  "https://httpbin.org/post"  -d 'file=go&bucket=bucketpath&a=1

    type LoginForm struct {
        User     string `form:"user" binding:"required"`
        Password string `form:"password" binding:"required"`
    }

    if c.ShouldBindWith(&form, binding.Form)
    if c.ShouldBind(&form) == nil 

Test it with:

    $ curl -v --form user=user --form password=password http://localhost:8080/login

## query('name') + PostForm('name')
or:

    id := c.Query("id") // shortcut for c.Request.URL.Query().Get("id")
    page := c.DefaultQuery("page", "0")
    name := c.PostForm("name")
    nick := c.DefaultPostForm("nick", "anonymous")

## Multipart/file(form-data)
    // 'Content-Type: multipart/form-data; boundary=---xxx'
    curl  "https://httpbin.org/post"  -F 'file=@a.txt' -F 'key=value'

via bind

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


via multiparForm()

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

single FromFile

    // single file
    file, _ := c.FormFile("file")
    log.Println(file.Filename)

### open file
fileHeader

    // getFileHeader
    fileHeader := c.FormFile("upload")
    fileHeader *FileHeader
        content, Filename
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


## Body Stream
https://github.com/gin-gonic/gin/pull/857/files

    func (c *Context) GetRawData() ([]byte, error) {
        return ioutil.ReadAll(c.Request.Body)

# Response
    c.JSON(http.StatusOK, gin.H{"user": user, "value": value})
