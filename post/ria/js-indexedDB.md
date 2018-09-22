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
    // Open the database
    db.open().catch(e=>console.error("Open failed: " + e));

Curd will open it automatically and enqueue the operation to execute as soon as the database is finished opening. 
没有 open, 也没有curd 操作, 会报错:

    VM393 dexie.js:1541 Another connection wants to delete database 'FriendsAndPetsDB'. Closing db now to resume the delete request

### populate event
This will only be called in case the `database` is initially created - not when it is upgraded.

Init your DB with some default statuses:

    db.version(1).stores({
        statuses: "++id,name,openess"
    });
    db.on("populate", function() {
        db.statuses.add({id: 1, name: "opened", openess: true});
    });
    db.open()

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

### index

    ++id auto increment
    *to unique key
    index2 normal key

### Detect DB changed

    window.addEventListener('storage', function (event) {
        if (event.key === "Dexie.DatabaseNames") {
            console.log("A database was added or removed");
            console.log("Old list: " + event.oldValue);
            console.log("New list: " + event.newValue);
        }
    });

## List DB+Table
IndexedDB 没有借口，Dexie 是通过`__dbnames` 记录的

    const databases = await Dexie.getDatabaseNames();

    db.tables.forEach(function (table) {
        table.add(...)
    });

## Delete DB+Table
    db.delete();
    // Static method
    Dexie.delete('database_name');

    Dexie.getDatabaseNames((l)=>{
        l.forEach(console.log)
    });

delete table

    db.version(x).stores(tableName:null)

## CRUD

    //add + select
    // put = add+update
    db.friends.put({name: "Nicolas", shoeSize: 8}).then (function(){
        console.log(db.friends.get('Nicolas'));
    })

    //delete
    db.orders
        .where("state").anyOf("finished", "discarded")
        .delete()
        .then(function (deleteCount) {
            console.log( "Deleted " + deleteCount + " objects");
        });

    //query
    db.table.toArray()
    db.table.each(callbackFn);


### collection

    Collection.sortBy()
    Collection.each(row=>{})
    Collection.first()
    Collection.last()

    Collection.toArray() //end

delete

    // 等价
    Collection.delete()
    Collection.modify(function () {delete this.value;});

equal(不是collection), above, below

    db.users.get(2) 
        will give you the user with id 2
    db.users.where('username').equals('usrname').first() 
        - will give you the user with username ‘usrname’
    database.users.where('id').equals(2).delete();

`anyof()`, `between(37, 40)`

    db.relations.where('relation').anyOf('wife', 'husband', 'son', 'daughter') 
        - will give you all family relations.

string:startsWith + IngoreCase

    db.users.where('email').startsWith('david@').distinct()
        - will give you the users that have any of their emails starting with ‘david@’
    db.users.where('name').startsWithIgnoreCase('da') 
        - will give you all users starting with “da”
    db.users.where('address.city').equalsIgnoreCase('malmö') 
        - will give you all users residing in Malmö.

`or()`, `+`, `and()`

    db.relations.where('userId1').equals(2).or('userId2').equals(2) 
        - will give you all relations that user with id 2 has to other users or other users have to user 2
    db.relations.where('[userId1+userId2]').equals([2,3]) 
        - will give you all the relations that user 2 has to user 3
    db.relations.where('[userId1+userId2]').equals([2,3]).or('[userId1+userId2]').equals([3,2]) 
        - will give you all the relations that user 2 has to user 3 or user 3 has to user 2.

    .and(function(friend) { return friend.isCloseFriend; })

limit, distinct:

    .distinct()
    .limit(10)

sortBy

    collection.sortBy(keyPath, callback?)
    collection.sortBy('name')


### Promise

    Table.get()
        db.friends.get(1).then(console.log)
    Table.toArray()
    Table.each()

`ToArray+ then/catch`, `each`

    var arrayPromise = db.friends.where('name').startsWithIgnoreCase('arnold').toArray();
    arrayPromise.then(function(result) { console.log(result.length); });
    arrayPromise.catch(function(err) { console.error(err); });

    // 或则
    db.friends.where('name').startsWithIgnoreCase('arnold').toArray(function(a) {
        console.log(a.length);
    }).catch(function(err) {
        console.error(err);
    });

    db.foo1.where('x').equals('x').each(v=>console.log(v))

#### exception

    db.friends.where('name').startsWithIgnoreCase('arnold').toArray(function(a) {
        console.log(a.length);
    }).catch(DOMError, function(e) {
        console.error("DOMError occurred: " + err);
    }).catch(TypeError, function(e) {
        console.error("TypeError occurred: " + err);
    }).catch(function(err) {
        console.error("Unknown error occurred: " + err);
    }).finally(function(){
        console.log("Finally the query succeeded or failed.");
    });


### CRUD Hooks (CREATE, READ, UPDATE, DELETE)
常常用来做序列化、反序列化.
delete hook 

    db.[tableName].hook('reading').unsubscribe(yourListenerFunction)

Hook Create 

    db.[tableName].hook('creating', function (primKey, obj, transaction) {
        // You may do additional database operations using given transaction object.
        // You may also modify given obj
        // You may set this.onsuccess = function (primKey){}. Called when autoincremented key is known.
        // You may set this.onerror = callback if create operation fails.
        // If returning any value other than undefined, the returned value will be used as primary key
    });

Hook Update:

    db.emails.hook("updating", function (modifications, primKey, obj, trans) {
        //modify price, while keep other fields' value
        return {price: modifications.price+10}
    })
    db.emails.put({price:5, author:'ahuigo'})

Hook READ:

    db.[tableName].hook('reading', function (obj) {
        // You may return another object or modify existing object.
    });

## transaction
http://dexie.org/docs/Tutorial/Best-Practices

    db.transaction("rw", db.friends, db.pets, function() {
        db.friends.add({name: "Måns", isCloseFriend: 1}); // unhandled promise = ok!
        db.friends.add({name: "Nils", isCloseFriend: 1}); // unhandled promise = ok!
        db.friends.add({name: "Jon", isCloseFriend: 1});  // unhandled promise = ok!
        db.pets.add({name: "Josephina", kind: "dog"});    // unhandled promise = ok!
        // If any of the promises above fails, transaction will abort and it's promise
        // reject.

        // Since we are in a transaction, we can query the table right away and
        // still get the results of the write operations above.
        var promise = db.friends.where("isCloseFriend").equals(1).toArray();

        // Make the transaction resolve with the last promise result return promise;
    }).then(function (closeFriends) {
        // Transaction complete.
        console.log("My close friends: " + JSON.stringify(closeFriends));
    }).catch(function (error) {
        // Log or display the error.
        console.error(error);
        // Notice that when using a transaction, it's enough to catch
        // the transaction Promise instead of each db operation promise.
    });

### Avoid using other async APIs inside transactions
IndexedDB will commit a transaction as soon as it isn’t used within a tick
1. A transaction is auto-committed Before `then/catch`. 
2. So, if you do `setTimeout(cb, 0)` anywhere, don’t expect your transaction to live when the callback comes back! 

In case you really need to call a short-lived async-API, Dexie 2.0 can actually keep your transaction alive for you if you use Dexie.waitFor().

    // It will then just be equaivalent to Promise.resolve().
    Dexie.waitFor(promise, timeout=60000)
    function sleep (ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    await db.transaction('rw', db.friends, async ()=> {
        await Dexie.waitFor(sleep(100)); // Sleeps 100 milliseconds
        await db.friends.put({id: 1, name: "Åke"});
        await Dexie.waitFor(sleep(100)); // Sleeps 100 milliseconds
        let theMan = await db.friends.get(1);
        alert (`I still got the man: ${theMan.name}`);
    });


## Define Class(IDE 补全)
### mapToClass

    import Dexie from 'dexie';
    var db = new Dexie("FriendsDB");
    db.version(1).stores({
        friends: "++id,name,shoeSize,address.city"
    });

    class Friend {
        log() {
            console.log(JSON.stringify(this));
        }
    }

    db.friends.mapToClass(Friend); //IDE 关键
    db.friends.where("name").startsWithIgnoreCase("d").each(function(friend) {
        assert(friend instanceof Friend); //IDE 关键
        friend.log();
    })

### defineClass()
    var db = new Dexie("MyAppDB");
    db.version(1).stores({
        folders: "++id,&path",
    });

    // Notice
    var Folder = db.folders.defineClass({
        id: Number,
        path: String,
        description: String
    });
    Folder.prototype.save = function () {
        return db.folders.put(this);
    }
    new Folder({....}).save()

## Reference
- http://dexie.org/docs/Tutorial/Design