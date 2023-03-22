---
title: reflect compose
date: 2023-03-19
private: true
---
# reflect compose
## trace compose example
demo: golib/reflect/compose_test.go

What is `trace.compose(oldTrace)` doing?
    
    // net/http/httptrace/trace.go:179
    tv := reflect.ValueOf(trace *ClientTrace).Elem()
	ov := reflect.ValueOf(old *ClientTrace).Elem()
    for i := 0; i < tv.Type().NumField(); i++ {
        tf := tv.Field(i)
        of := ov.Field(i)

        //filter function
        if tf.Type().Kind()!=reflect.Func{continue} 

        //filter nil
        if of.IsNil(){continue} 
        if tf.IsNil() {
			tf.Set(of)
			continue
		}


        // makeCopy: (Otherwise it creates a recursive call cycle )
        tfCopy := reflect.ValueOf(tf.Interface())

        // wrap
        newFunc := reflect.MakeFunc(tf.Type(), func(args []reflect.Value) []reflect.Value {
			tfCopy.Call(args)
			return of.Call(args)
		})
		tv.Field(i).Set(newFunc)
    }
