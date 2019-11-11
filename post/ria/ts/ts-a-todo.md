---
title: ts todo
date: 2019-11-11
private: 
---
# ts todo
    function buildName({firstName = 'Tom', lastName=''}:{firstName:string, lastName:string}={}) {
        return firstName + ' ' + lastName;
    }