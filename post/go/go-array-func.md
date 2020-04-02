---
title: go array func
date: 2020-04-02
private: true
---
# go array func

# array

## in_array
    func arrayIndex(a string, list []string) (int) {
        for i, b := range list {
            if b == a {
                return i
            }
        }
        return -1
    }
