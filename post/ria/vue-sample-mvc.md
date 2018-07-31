---
layout: page
title:
category: blog
description:
---
# Preface
30行代码实现Javascript中的MVC

作者：ralph_zhu

时间：2016-02-15 14:30

原文：http://www.cnblogs.com/front-end-ralph/p/5190442.html

```js
function Model(value) {
    this._value = typeof value === 'undefined' ? '': value;
    this._listeners = [];
}
Model.prototype.set = function(value) {
    var self = this;
    self._value = value;
    setTimeout(function() {
        self._listeners.forEach(function(listener) {
            listener.call(self, value);
        });
    });
};
Model.prototype.watch = function(listener) {
    this._listeners.push(listener);
};
Model.prototype.bind = function(node) {
    this.watch(function(value) {
        node.innerHTML = value;
    });
};
function Controller(callback) {
    var models = {};
    var views = Array.prototype.slice.call(document.querySelectorAll('[bind]'), 0);
    views.forEach(function(view) {
        var modelName = view.getAttribute('bind'); 
        (models[modelName] = models[modelName] || new Model()).bind(view);
    });
    callback.call(this, models);
}
```
```js
// html: <span bind="hour"></span> : <span bind="minute"></span> : <span bind="second"></span>

controller: new Controller(function(models) {
    function setTime() {
        var date = new Date();
        models.hour.set(date.getHours());
        models.minute.set(date.getMinutes());
        models.second.set(date.getSeconds());
    }
    setTime();
    setInterval(setTime, 1000);
});

```