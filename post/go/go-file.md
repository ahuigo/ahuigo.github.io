---
title: golang 的file api
date: 2018-09-27
---
# Directory Api

## pathinfo
extinfo 

    import "path/filepath"
    fileext :=copy filepath.Ext(filename)

dir + file:

    dir := filepath.Dir(path)
    dir, file := filepath.Split(path)

abs

    filepath.Abs(exec.LookPath(os.Args[0]))。

## glob match
    import (
        "fmt"
        "path/filepath"
    )

    func main() {
        ///不支持**
        fmt.Println(filepath.Match("/home/catch/**", "/home/catch/foo/bar")) 
        //output: false <nil>

## os path
### path ext

    import (
        "fmt"
        "os"
        "path/filepath"
    )

    func main() {
        ex, err := os.Executable()
        if err != nil { panic(err) }
        exPath := filepath.Dir(ex)
        fmt.Println(exPath)
    }
### rename and move
    Original_Path := "./GeeksforGeeks.txt"
    New_Path := "./new_folder/gfg.txt"
    e := os.Rename(Original_Path, New_Path)
    if e != nil {
        log.Fatal(e)
    }
### Getwd: 
func Getwd() (pwd string, err error)

    import (
        "fmt"
        "os"
    )

    func main() {
        pwd, err := os.Getwd()
        if err != nil {
            fmt.Println(err)
            os.Exit(1)
        }
        fmt.Println(pwd)
    }

#### change dir
    home, _ := os.UserHomeDir()
    err := os.Chdir(filepath.Join(home, "goproject2"))

#### IsAbs
	if filepath.IsAbs(rel) {
		return rel
	}
### path exists
    if _, err := os.Stat("/path/to/whatever"); os.IsNotExist(err) {
        // path/to/whatever does not exist
    }

### mkdir
    err = os.Mkdir(path, os.ModeDir)
	os.Mkdir("tmp", 0700)

recursive:

    os.MkdirAll(folderPath, os.ModePerm)

## tmp
### tempFile
    // 生成随机的文件名，不会自动Remove
    file, err := ioutil.TempFile("dir", "prefix")
    if err != nil {
        log.Fatal(err)
    }
    defer os.Remove(file.Name())

    fmt.Println(file.Name()) // For example "dir/prefix054003078"

### tempDir
    dir, err := ioutil.TempDir("dir", "prefix")
    if err != nil {
        log.Fatal(err)
    }
    defer os.RemoveAll(dir)

# File Api

## open
    f, err := os.Open("/tmp/dat")
    f.Close()

### file attr
    // Name就是path/to/file
    f.Name()
    (f *File) Stat() (FileInfo, error)
    (f *File) Sync() error

## read
read:

    b1 := make([]byte, 5)
    n1, err := f.Read(b1)

### seek
    o2, err := f.Seek(6, 0)
    // There is no built-in rewind, but `Seek(0, 0)`
    _, err = f.Seek(0, 0)


### readFile

    "io/ioutil"
    content, err := ioutil.ReadFile(filename)

### ReadAtLeast

    b3 := make([]byte, 2)
    n3, err := io.ReadAtLeast(f, b3, 2)

### readline
	scanner := bufio.NewScanner(f) //f:io.Reader
	for scanner.Scan() {
		lineText = scanner.Text()
	}

### buffer read(copy)
    var b bytes.Buffer
    io.Copy(os.Stdout, &b)

## write

### writeFile
with bytes

    bytes := []byte("hello\ngo\n")
    err := ioutil.WriteFile("/tmp/dat1", bytes, 0644)

### Write
#### Write bytes

    f, err := os.Create("/tmp/dat2")
    defer f.Close()
    d2 := []byte{115, 111, 109, 101, 10}
    n2, err := f.Write(d2)
    fmt.Printf("wrote %d bytes\n", n2)

write bytes to stdout

    os.Stdout.Write(bytes[:])

#### Write buffer
write to stdout with bytes

    f := bufio.NewWriter(os.Stdout)
    defer f.Flush()
    f.Write(b)

#### WriteString

    // A `WriteString` is also available.
    n3, err := f.WriteString("writes\n")
    fmt.Printf("wrote %d bytes\n", n3)

### sync

    // Issue a `Sync` to flush writes to stable storage.
    f.Sync()

    // `bufio` provides buffered writers in addition
    // to the buffered readers we saw earlier.
    w := bufio.NewWriter(f)
    n4, err := w.WriteString("buffered\n")
    fmt.Printf("wrote %d bytes\n", n4)

    // Use `Flush` to ensure all buffered operations
    w.Flush()

## Copy
### copy via io.Copy
    func copy(src, dst string) (int64, error) {
        sourceFileStat, err := os.Stat(src)
        if err != nil {
                return 0, err
        }

        if !sourceFileStat.Mode().IsRegular() {
                return 0, fmt.Errorf("%s is not a regular file", src)
        }

        source, err := os.Open(src)
        if err != nil {
                return 0, err
        }
        defer source.Close()

        destination, err := os.Create(dst)
        if err != nil {
                return 0, err
        }
        defer destination.Close()
        nBytes, err := io.Copy(destination, source)
        return nBytes, err
    }
### 自定义copy reader 
定义

    type rot13Reader struct {
		r io.Reader
	}
	func (r *rot13Reader) Read(b []byte) (int, error){
			n, err:= (*r).r.Read(b)
			return n, err
	}

也可使用(只是多此一举)：

    _, err = io.Copy(out, &file)
    _, err = io.Copy(io.stdout, &file)
    
	func main() {
		s := strings.NewReader("Lbh penpxrq gur pbqr!")
		r := rot13Reader{s}
		io.Copy(os.Stdout, &r) //write to os.Stdout
	}


## stdin, stdout

    io.stdout
    os.Stdout