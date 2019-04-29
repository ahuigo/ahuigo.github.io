---
title: Golang Singleton
date: 2019-04-29
---
# Golang Singleton
Non thread Safe: instantiated share by thread, not atomic

    //instantiated and single are private
    type single struct {
            O interface{};
    }

    var instantiated *single = nil

    func New() *single {
            if instantiated == nil {
                    instantiated = new(single);
            }
            return instantiated;
    }

thread safe:

    package singleton
    import "sync"

    type single struct {
            O interface{};
    }

    var instantiated *single
    var once sync.Once

    func New() *single {
            once.Do(func() {
                    instantiated = &single{}
            })
            return instantiated
    }
