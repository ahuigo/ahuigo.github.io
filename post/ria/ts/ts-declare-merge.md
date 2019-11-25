---
title: 声明合并
date: 2019-11-23
private: 
---
# 声明合并

## 函数合并
    function reverse(x: number): number;
    function reverse(x: string): string;
    function reverse(x: number | string): number | string {
        if (typeof x === 'number') {
            return Number(x.toString().split('').reverse().join(''));
        } else if (typeof x === 'string') {
            return x.split('').reverse().join('');
        }
    }

## 接口合并
### 接口属性合并
接口中的属性在合并时会简单的合并到一个接口中：

    interface Alarm {
        price: number;
    }
    interface Alarm {
        weight: number;
    }

相当于：

    interface Alarm {
        price: number;
        weight: number;
    }

### 接口方法合并
    interface Alarm {
        price: number;
        alert(s: string): string;
    }
    interface Alarm {
        weight: number;
        alert(s: string, n: number): string;
    }

## 类合并
与接口合并一样

## 参考
1. https://github.com/xcatliu/typescript-tutorial/blob/master/advanced/declaration-merging.md