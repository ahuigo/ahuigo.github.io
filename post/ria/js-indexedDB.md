# IndexedDb 的使用
IndexedDb API 封装的很难用，[IndexedDB使用与出坑指南](https://juejin.im/post/5a9d65916fb9a028e46e257a) ，

对比了各大lib, 发现Dexie 这个封装最好。

# Dexie
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

如果没有open, 也没有curd 操作, 会报错:

    VM393 dexie.js:1541 Another connection wants to delete database 'FriendsAndPetsDB'. Closing db now to resume the delete request

### version
Client Database 与 Server Database 不同，当时修改表结构时，每个Client 表结构都可能不同。所以IndexedDB 引入了database 的版本。所有的js的表结构操作都需要保留, 不能缺失，就是为了不能client migration 时的一致性。

如果版本不全: UpgradeError Dexie specification of currently installed DB version is missing

    //db.version(1).stores({friends: "++id,name"}); ////missing
    db.version(2).stores({friends: "++id,name,shoeSize"}); 

如果表结构已经存在：An index with the specified name already exists.

    db.version(1).stores({friends: "++id,name"});
    db.version(2).stores({friends: "++id,name"}); // exists
    db.version(3).stores({friends: "++id,name,shoeSize,haha"});

### upgrade
Note: Dexie will provide the migration in backround in case a user with version 1 installed loads your version 2-app, but it would need to know the structure (how it looked like) in version 1 in order to do that.

    db.version(1).stores({friends: "++id,name"});
    db.version(2).stores({friends: "++id,name,shoeSize"});
    db.version(3).stores({friends: "++id,shoeSize,firstName,lastName"}).upgrade(tx => {
        // An upgrade function for version 3 will upgrade data based on version 2.
        return tx.friends.toCollection().modify(friend => {
            // Modify each friend:
            friend.firstName = friend.name.split(' ')[0];
            friend.lastName = friend.name.split(' ')[1];
            delete friend.name;
        });
    });

### alter change
    db.version(1).stores({
        foo1: 'id,x,y,z',
        foo2: 'id,x,y,z',
        foo3: 'id,x,y,z'
    });
    // Delete index 'y' on 'foo1':
    db.version(2).stores({
        foo1: 'id,x,z'
    });
    // Add index 'x2' on 'foo2':
    db.version(3).stores({
        foo2: 'id, x, x2, y, z'
    });
    // Drop table 'foo3':
    db.version(4).stores({foo3: null});

## List DB+Table

## Delete DB+Table
    db.delete();
    // Static method
    Dexie.delete('database_name');

## Detect DB changed

    window.addEventListener('storage', function (event) {
        if (event.key === "Dexie.DatabaseNames") {
            console.log("A database was added or removed");
            console.log("Old list: " + event.oldValue);
            console.log("New list: " + event.newValue);
        }
    });

## CRUD

    //add + select
    // put = add+update
    db.friends.put({name: "Nicolas", shoeSize: 8}).then (function(){
        console.log(db.friends.get('Nicolas'));
    })

    // 

## transaction

    db.transaction("rw", db.friends, db.pets, function() {
       ...
    }).catch(function (error) {
        // Log or display the error
    });

### Transaction Lifetime
1. A transaction is auto-committed Before `then/catch`. 
2. So, if you do `setTimeout(cb, 0)` anywhere, don’t expect your transaction to live when the callback comes back! 

## Reference
- http://dexie.org/docs/Tutorial/Design