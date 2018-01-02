# Preface
Go has a lightweight test framework composed of the go test command and the testing package.

1. test framework composed of the `go test` command and the `testing` package.
2. file with a name ending in `_test.go` that contains functions named `TestXXX` with signature `func (t *testing.T)`
3. if the function calls a failure function such as `t.Error or t.Fail`

## Your first library
see go/hello

## go test
Add a test to the stringutil package by creating the file ``$GOPATH/src/github.com/user/stringutil/reverse_test.go` containing the following Go code.

  package stringutil

  import "testing"

  func TestReverse(t *testing.T) {
  	cases := []struct {
  		in, want string
  	}{
  		{"Hello, world", "dlrow ,olleH"},
  		{"Hello, 世界", "界世 ,olleH"},
  		{"", ""},
  	}
  	for _, c := range cases {
  		got := Reverse(c.in)
  		if got != c.want {
  			t.Errorf("Reverse(%q) == %q, want %q", c.in, got, c.want)
  		}
  	}
  }

Then run the test with go test:

  $ go test github.com/user/stringutil
  ok  	github.com/user/stringutil 0.165s

As always, if you are running the go tool from the package directory, you can omit the package path:

  $ go test
  ok  	github.com/user/stringutil 0.165s
