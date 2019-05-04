---
title: IndexedDb 的使用之Dexie
date: 2018-10-04
---
# IndexedDb 的使用之Dexie
IndexedDb API 封装的很难用，[IndexedDB使用与出坑指南](https://juejin.im/post/5a9d65916fb9a028e46e257a) ，

对比了各大lib, 发现Dexie 这个封装最好。

    import Dexie from 'dexie';

    const db = new Dexie('ReactSampleDB');
    db.version(1).stores({ todos: '++id' });

    export default db;

# DDL
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
        db.statuses.bulkAdd([{id: 1, name: "opened", openess: true},...]);
    });
    db.open()

## Alter Version
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

Note:
1. Upgrade: Not yet support for changing primary key.(要先删除table) `++id` 变`id` 都不行
Refer to: https://github.com/dfahlander/Dexie.js/issues/88

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

## primary key 
out of line: '' empty key

    db.version(1).stores({
        simple: ''
    });
    db.simple.add({name:'ahui'}, 2); // insert
    db.simple.put('three', 3); // insert    

out of line: '++' auto increment

    db.version(2).stores({
        simple: '++,name'
    });
    db.simple.add('one', 1);
    db.simple.put({name:'ahui', skill:'code'}, 2); // update

inline: key in object

    db.version(1).stores({
     objects: '++id,name'
    });
 
    db.objects.put({id: 'one', name: 'ahuigo'}); 

inline: key with dot notation(deep level)

    db.version(1).stores({
        objects: 'pk.id'
    });
    db.objects.add({data: 'one', pk: {id: 1, ts: 1928198298}});
    db.objects.add({data: 'two', pk: {id: 2, ts: 1928198299}});

Composite keys

    db.version(1).stores({
        objects: '[first+last]'
    });
    
    db.objects.add({first: '1', last: 1, data: 'test'}); //insert
    db.objects.put({first: '2', last: 2, data: 'test2'}); //insert
    const result = await db.objects.get(['2',2]);
    // {first: "2", last: 2, data: "test22"

## indexes
4种:

    property : hold duplicates
    &property : Unique index.
    *property : Multi-entry index(array)
    [property1+property2] : Compound index
        where('[properties.tsunami+properties.mag]')

e.g. 

    db.version(1).stores({
        contacts: '++id,name,&email,*hobbies,[postCode+city]'
    });
    db.contacts.add({
        name: 'John',
        email: 'john@test.com',
        hobbies: ['Reading', 'Traveling', 'Cycling'],
        postCode: 11111,
        city: 'BigCity'
    });
    // use multi-entry index
    const contact = await db.contacts.where('hobbies').equals('Cycling').first();

## Detect DB changed

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
    // Static method
    Dexie.delete('database_name');
    db.delete();

    Dexie.getDatabaseNames((l)=>{
        l.forEach(console.log)
    });

delete table

    db.version(x).stores(tableName:null)

# CURD

## add

    //add
    db.contacts.bulkAdd([{id:1, ....}, {id:2, ....},  ......  ,{id:100, ....} ]);

    // put = add+update
    db.friends.put({name: "Nicolas", shoeSize: 8}).then (function(){
        console.log(db.friends.get('Nicolas'));
    })

## update
put: insert+update

    db.objects.put({first:'1',last:1, data:2})

update(partial update): given primarty key as first

    db.friends.update(2, {name: "ahui"}).then(isUpdated=>{}) 
    // 区分'1' vs 1 
    db.objects.update({first:'1',last:1},{a:[1,2,3]})

modify(partial update): based on query

    db.inspections.where('id').equals(id).modify({a:[1,2,3]}) );
    db.inspections.where('id').equals(id).modify(x => {x.a.push(6); delete x.age;});

modify: override via ref.value

    db.contacts.where('name').equals('Jane').modify((contact, ref) => {
        ref.value = {id: 1, name: 'Sarah', hobbies: ['Reading']}; //pk(id) 不能变
    });
    // delete record
    delete ref.value

## delete
delete on query

    db.contacts.where('name').equals('Jane').delete()
        .then(function (deleteCount) {
            console.log( "Deleted " + deleteCount + " objects");
        });

delete on pk

    db.objects.delete(2)
    // {first:'1',last:2}
    db.objects.delete(['1',2])

批量删除

    db.contacts.bulkDelete([1,2]);

clear all:

    Table.clear()

## Read
pk:

    const contact = await db.contacts.get(1);

each:

    //each
    db.contacts.each(contact => console.log(contact));

    // reverse:
    db.contacts.reverse().each(contact => console.log(contact));
 
toArray:

    const all = await db.contacts.toArray();

### distinct:

    .distinct().limit(10)

### orderBy:

    const allOrderedByAge = await db.contacts.orderBy('age').toArray();

### limit, offset

    db.contacts.reverse().limit(1)
    db.contacts.offset(1000).limit(2)
    table.first()
    table.last()

### count

    db.contacts.count()

### where
`where(<indexes>)` accept indexed only. 

`':id'` allows you to create queries with the primary key. 

    db.contacts.where(':id').below(3).

equal:

    db.users.where('username').equals('usrname').first() 
        - will give you the user with username ‘usrname’
    database.users.where('id').equals(2).delete();

shortland equals:

    db.contacts.where({firstName: 'Ryan', age: 35}).toArray();

compound indexes 组合索引

    db.objects.where('[first+last]').equals(['1',1])

string:startsWith + IngoreCase

    db.users.where('email').startsWith('david@').distinct()
    db.users.where('name').startsWithIgnoreCase('da') 
    // dot indexes(多层)
    db.users.where('address.city').equalsIgnoreCase('malmö') 

above(), aboveOrEqual(), below(), belowOrEqual():

    db.contacts.where('age').aboveOrEqual(35).toArray();

between:

    // [27, 35)
    where('age').between(27, 35)
    // (27, 35]
    where('age').between(27, 35, false, true)

`anyOf()`, `noneOf`

    .where('relation').anyOf('wife', 'husband', 'son', 'daughter') 
    .where('relation').noneOf('wife', 'husband', 'son', 'daughter') 

`or()`, `and()`

    db.relations.where('userId1').equals(2).or('userId2').equals(2) 
        - will give you all relations that user with id 2 has to other users or other users have to user 2
    .and(function(friend) { return friend.isCloseFriend; })

pk:

    db.relations.where('[userId1+userId2]').equals([2,3]) 
        - will give you all the relations that user 2 has to user 3
    db.relations.where('[userId1+userId2]').equals([2,3]).or('[userId1+userId2]').equals([3,2]) 
        - will give you all the relations that user 2 has to user 3 or user 3 has to user 2.

### Key results
primary key values

    await db.contacts.where('age').above(30).primaryKeys();
    // [1, 5, 6, 2]

keys() and uniqueKeys() return the index value

    const result = await db.contacts.where('age').above(30).uniqueKeys(); 
    // [32, 35, 40, 47]
    const result = await db.contacts.orderBy('hobbies').keys();

eachPrimaryKey, eachKey, eachUniqueKey

    db.contacts.where('age').above(30).eachPrimaryKey(pk => console.log(pk));



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

### transaction level
('rw!', 'rw?', 'r!', 'r?')

    ! : Always start a new top level transaction
    ? : Reuse parent transaction when they are compatible otherwise start a new top-level transaction

### abort

    Dexie.currentTransaction.abort(); 

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
- https://golb.hplar.ch/2018/01/IndexedDB-programming-with-Dexie-js.html