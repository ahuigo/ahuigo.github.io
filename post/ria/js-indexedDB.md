# IndexedDb 的使用
IndexedDb API 封装的很难用，[IndexedDB使用与出坑指南](https://juejin.im/post/5a9d65916fb9a028e46e257a) ，

对比了各大lib, 发现Dexie 这个封装最好。

## Create Database+Table

    <script src="https://unpkg.com/dexie@latest/dist/dexie.js"></script>
    var db = new Dexie("Memory");
    // db.verno
    db.version(1).stores({
        tasks: 'name,index1',
        friends: '++id,name',
    });

In case open() hasn’t been called, it will open it automatically and enqueue the operation to execute as soon as the database is finished opening. 

    // Open the database
    db.open().catch(e=>console.error("Open failed: " + e));

## CRUD

    put = add+update
    db.friends.put({name: "Nicolas", shoeSize: 8}).then (function(){
        console.log(db.friends.get('Nicolas'));
    })


## Reference
- http://dexie.org/docs/Tutorial/Design