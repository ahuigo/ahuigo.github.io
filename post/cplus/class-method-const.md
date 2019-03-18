---
title: class const
date: 2019-03-16
private:
---
# class const
https://stackoverflow.com/questions/751681/meaning-of-const-last-in-a-function-declaration-of-a-class

    #include <iostream>

    class MyClass
    {
    private:
        int counter;
    public:
        void Foo()
        { 
            std::cout << "Foo" << std::endl;    
        }

        void Foo() const
        {
            std::cout << "Foo const" << std::endl;
        }

    };

    int main()
    {
        MyClass cc;
        const MyClass& ccc = cc;
        cc.Foo();
        ccc.Foo();
    }

This will output

    Foo
    Foo const

so:

    void Foo()
    {
        counter++; //this works
        std::cout << "Foo" << std::endl;    
    }

    void Foo() const
    {
        counter++; //this will not compile
        std::cout << "Foo const" << std::endl;
    }
