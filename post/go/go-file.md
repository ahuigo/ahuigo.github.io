# filepath

  import "path/filepath"
  fileext := filepath.Ext(filename)

# file

## read

  "io/ioutil"
  content, err := ioutil.ReadFile(filename)

  if err != nil {
       fmt.Printf("   404 Not Found!\n")
       w.WriteHeader(http.StatusNotFound)
       return
  }
