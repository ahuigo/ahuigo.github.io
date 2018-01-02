---
layout: page
title:
category: blog
description:
---
# Preface

# io

## Read
The io package specifies the io.Reader interface, which represents the read end of a stream of data.

	r := strings.NewReader("Hello, Reader!")
	b := make([]byte, 8);//buffer
	for {
		n, err := r.Read(b);// auto check len(b)
		fmt.Printf("n = %v err = %v b = %v\n", n, err, b)
		fmt.Printf("b[:n] = %q\n", b[:n])
		if err == io.EOF {
			break
		}
	}

Error:

	nil
	io.EOF

### io.Copy

		io.Copy(os.Stdout, &r)
			r.Read(buf []byte)

### wrap Read

	import (
		"io"
		"os"
		"strings"
	)

	type rot13Reader struct {
		r io.Reader
	}
	func (r *rot13Reader) Read(b []byte) (int, error){
		for {
			n, err:= (*r).r.Read(b)
			return n, err
		}
	}


	func main() {
		s := strings.NewReader("Lbh penpxrq gur pbqr!")
		r := rot13Reader{s}
		io.Copy(os.Stdout, &r)
	}
