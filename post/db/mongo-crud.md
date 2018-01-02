# index
By default, mongo has no index at all(include `_id`, it does not occur in the condition)

    $ db.COLLECTION_NAME.ensureIndex({KEY:1}) asc
    $ db.COLLECTION_NAME.ensureIndex({KEY:-1}) desc

ensureIndex() 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）。

    >db.col.ensureIndex({"title":1,"description":-1})

To create an index in php:

    $collection->ensureIndex( array( "i" => 1 ) );  // create an ascending index on "i"
    $collection->ensureIndex( array( "i" => -1, "j" => 1 ) );  // index on "i" descending, "j" ascending

## Index params
ensureIndex() 接收可选参数，可选参数列表如下：

    Parameter	Type	Description
    background	Boolean	建索引过程会阻塞其它数据库操作，background可指定以后台方式创建索引，即增加 "background" 可选参数。 "background" 默认值为false。
    unique	Boolean	建立的索引是否唯一。指定为true创建唯一索引。默认值为false.
    name	string	索引的名称。如果未指定，MongoDB的通过连接索引的字段名和排序顺序生成一个索引名称。
    dropDups	Boolean	在建立唯一索引时是否删除重复记录,指定 true 创建唯一索引。默认值为 false.
    sparse	Boolean	对文档中不存在的字段数据不启用索引；这个参数需要特别注意，如果设置为true的话，在索引字段中不会查询出不包含对应字段的文档.。默认值为 false.
    expireAfterSeconds	integer	指定一个以秒为单位的数值，完成 TTL设定，设定集合的生存时间。
    v	index version	索引的版本号。默认的索引版本取决于mongod创建索引时运行的版本。
    weights	document	索引权重值，数值在 1 到 99,999 之间，表示该索引相对于其他索引字段的得分权重。
    default_language	string	对于文本索引，该参数决定了停用词及词干和词器的规则的列表。 默认为英语
    language_override	string	对于文本索引，该参数指定了包含在文档中的字段名，语言覆盖默认的language，默认值为 language.

### Background
在后台创建索引：

    db.values.ensureIndex({open: 1, close: 1}, {background: true})

## drop indexes

    db.collection.dropIndex(index)
    db.collection.dropIndex({index:1, index2:-1})

## show indexes

    db.collection.getIndexes(); //php: $db->col->getIndexInfo();
    {
        "v" : 1,
        "name" : "uid_1_ctime_-1",
        "key" : {
            "uid" : 1,
            "ctime" : -1
        },
        "ns" : "test.a"
    }

## explain index
mongodb 同样只支持最左索引, ctime 就不行:

    db.collection.find({uid:{'$gt':1}}).explain()
    //$cursor->explain()
        "indexBounds" : {
            "uid" : [
                [
                    1,
                    1.7976931348623157e+308
                ]
            ],
            "ctime" : [
                [
                    {
                        "$maxElement" : 1
                    },
                    {
                        "$minElement" : 1
                    }
                ]
            ]

# insert

    use test
    db.users.insert({"k":"v"})

insert multiple:

    db.users.insert([{"k":"v"}])

\_id is 12 bytes hexadecimal number unique for every document in a collection. 12 bytes are divided as follows

    \_id: ObjectId(4 bytes timestamp, 3 bytes machine id, 2 bytes process id, 3 bytes incrementer)

# update
1. The update() method *update* values in the existing document
2. while the save() method *replaces*(insert) the existing document with the document(`_id`) passed in save() method.

严格的类型匹配

    db.COLLECTION_NAME.update(SELECTIOIN_CRITERIA, UPDATED_DATA)
    db.mycol.update({n:'1'},{$set:{n:2}})
    db.mycol.update({'title':'old'},{$set:{'title':'New'}})

To update multiple:

    db.mycol.update({'title':'old'},{$set:{'title':'New'}}, {multi:true})

The save() method replaces the existing document with the new document passed in save() method

    db.COLLECTION_NAME.save({_id:ObjectId(),NEW_DATA})

# delete
Syntax:
Basic syntax of remove() method is as follows

    db.COLLECTION_NAME.remove(DELLETION_CRITTERIA)

Following example will remove all the documents whose title is 'MongoDB Overview' and num is 1

    db.mycol.remove({'title':'MongoDB Overview', 'num':1})

Remove only one

    db.COLLECTION_NAME.remove(DELETION_CRITERIA,1)

Remove All documents, If you don't specify deletion criteria,

    db.mycol.remove()

# select

## group


    db.fruit.group( {
                 key: { category: 1},
                 cond: { _id: { $gt: 2 } },
                 reduce: function(obj, prev) {
                    prev.items.push(obj.name);
                    prev.count++;
                 },
                 initial: { items : [] ,count:0}
               }
            );

结果:

    [ { "category" : "fruit",
            "items" : [
                "banana"
            ],
            "count" : 1
        },
        { "category" : "veggie",
            "items" : [
                "corn",
                "broccoli"
            ],
            "count" : 2
        }
    ]

php

    $keys = array("category" => 1);
    $initial = array("items" => array(),'count'=>0);
    $reduce = "function (obj, prev) { " .
                  "prev.items.push(obj.name); " .
                  "prev.count++;" .
              "}";
    $condition = array('condition' => array("_id" => array( '$gt' => 2)));
    $g = $collection->group($keys, $initial, $reduce, $condition);

### aggregate group

    db.fruit.aggregate([
         { $match: { _id: {$gt:0} } },
         { $group: { _id: "$category", count: { $sum: 1 } } },
         { $sort: { count: -1 } }
       ]);
    { "_id" : "fruit", "count" : 3 }
    { "_id" : "veggie", "count" : 2 }

## mapReduce
syntax:

    db.collection.mapReduce(
       function() {emit(key,value);},  //map function
       function(key,values) {return reduceFunction}, {   //reduce function
          out: collection,
          query: document,
          sort: document,
          limit: number
       }
    )

Now, we will use a mapReduce function on our posts collection to select all the active posts, group them on the basis of user_name and then count the number of posts by each user:

    db.posts.mapReduce(
       function() { emit(this.user_id,1); },
       function(key, values) {return Array.sum(values)}, {
          query:{status:"active"},
          out:"post_total"
       }

The above mapReduce query outputs the following result −

       {
          "result" : "post_total",
          "timeMillis" : 9,
          "counts" : {
             "input" : 4,
             "emit" : 4,
             "reduce" : 2,
             "output" : 2
          },
          "ok" : 1,
       }

To see the result of this mapReduce query use the find:

    db.posts.mapReduce(
       function() { emit(this.user_id,1); },
       function(key, values) {return Array.sum(values)}, {
          query:{status:"active"},
          out:"post_total"
       }
    ).find()

    { "_id" : "tom", "value" : 2 }
    { "_id" : "mark", "value" : 2 }

### mapReduce in php
This will sum all values in the news field to new collection called news created in command by adding ("out" => "news").

    $map = new MongoCode('function() {
               var total = 0;
               for (count in this.news) {
               total +=  this.news[count];
               }
               emit(this._id, {id: this.id, total: total});
           }');
    $reduce = new MongoCode('function(key, values) {
               var result = {id: null, total: 0};
               values.forEach(function(v) {
               result.id = v.id;
               result.total = v.total;
                });
               return result;
           }');

    $sales = $db->command(array(
       'mapreduce' => 'mycollection', // collection name
       'map' => $map,
       'reduce' => $reduce,
       'query' => array('table' => 'people'),
       "out" => "news" // new collection name
    ));

Get all users with at least on "sale" event, and how many times each of these users has had a sale.

    // sample event document
    $events->insert(array("user_id" => $id,
        "type" => $type,
        "time" => new MongoDate(),
        "desc" => $description));

    // construct map and reduce functions
    $map = new MongoCode("function() { emit(this.user_id,1); }");
    $reduce = new MongoCode("function(k, vals) { ".
        "var sum = 0;".
        "for (var i in vals) {".
            "sum += vals[i];".
        "}".
        "return sum; }");

    $sales = $db->command(array(
        "mapreduce" => "events",
        "map" => $map,
        "reduce" => $reduce,
        "query" => array("type" => "sale"),
        "out" => array("merge" => "eventCounts")));

    $users = $db->selectCollection($sales['result'])->find();

    foreach ($users as $user) {
        echo "{$user['_id']} had {$user['value']} sale(s).\n";
    }

## group
group 好像不支持: multiple subitem
但支持: reduce item + finalize

    SELECT ord_dt, sku, SUM(amount) as total FROM orders WHERE ord_dt > '01/01/2012' GROUP BY ord_dt, sku
    db.orders.group(
       {
         key: { ord_dt: 1, 'sku': 1 },
         cond: { ord_dt: { $gt: new Date( '01/01/2012' ) } },
         reduce: function( curr, result ) {
                     result.total += curr.amount;
                 },
         initial: { total : 0 }
       }
    )

group by keyf:
The following example groups by the calculated day_of_week field:

    db.orders.group(
    {
         keyf: function(doc) {
                   return { day_of_week: doc.ord_dt.getDay() };
               },
         cond: { ord_dt: { $gt: new Date( '01/01/2012' ) } },
        reduce: function( curr, result ) {
                    result.total += curr.item.qty;
                    result.count++;
                },
        initial: { total : 0, count: 0 },
        finalize: function(result) {
                      var weekdays = [
                           "Sunday", "Monday", "Tuesday",
                           "Wednesday", "Thursday",
                           "Friday", "Saturday"
                          ];
                      result.day_of_week = weekdays[result.day_of_week];
                      result.avg = Math.round(result.total / result.count);
                  }
        }
    )

## find
To query mongo

    db.COLLECTION_NAME.find()

To display the results in a formatted way

    db.COLLECTION_NAME.find().pretty();

check how mongodb works with your query

    db.collection.find(...).explain()

### Return the Specified Fields and the _id Field Only
In the result set, only the item and qty fields and, by default, the _id field return in the matching documents. specify column

    db.inventory.find( { type: 'food' }, { item: 1, qty: 1 } )

### count

    db.test.find().count()

### Equality

    Operation	Syntax	Example	RDBMS Equivalent
    Equality
        {<key>:<value>}	db.mycol.find({"by":"tutorials point"}).pretty()	where by = 'tutorials point'
    Less Than
        {<key>:{$lt:<value>}}	db.mycol.find({"likes":{$lt:50}}).pretty()	where likes < 50
    Less Than Equals
    	{<key>:{$lte:<value>}}	db.mycol.find({"likes":{$lte:50}}).pretty()	where likes <= 50
    Greater Than
    	{<key>:{$gt:<value>}}	db.mycol.find({"likes":{$gt:50}}).pretty()	where likes > 50
    Greater Than Equals
    	{<key>:{$gte:<value>}}	db.mycol.find({"likes":{$gte:50}}).pretty()	where likes >= 50
    Not Equals
    	{<key>:{$ne:<value>}}	db.mycol.find({"likes":{$ne:50}}).pretty()	where likes != 50

### find And

    where key1=value1 and key2=value2
    db.mycol.find({key1:value1, key2:value2}).pretty()

### filter results
Following example will display the title of the document while quering the document.

    >db.mycol.find({},{"title":1,_id:0})
    {"title":"MongoDB Overview"}
    {"title":"NoSQL Overview"}
    {"title":"Tutorials Point Overview"}

Please note `_id` field is always displayed while executing `find()` method, if you don't want this field,
then you need to set it as 0

### find or

    db.mycol.find(
        { $or: [
             {key1: value1}, {key2:value2}
          ]
        }
    )

where likes>10 AND (by = 'tutorials point' OR title = 'MongoDB Overview'):

    db.mycol.find({"likes": {$gt:10}, $or: [{"by": "tutorials point"}, {"title": "MongoDB Overview"}]}).pretty()

## aggregate, 聚合
集合计算每个作者所写的文章数，使用 aggregate()计算结果如下：

     db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$sum : 1}}}])
    {
       "result" : [
          {
             "_id" : "w3cschool.cc",
             "num_tutorial" : 2
          },
          {
             "_id" : "Neo4j",
             "num_tutorial" : 1
          }
       ],
       "ok" : 1
    }_

以上实例类似sql语句： select by_user, count(1) from mycol group by by_user

在上面的例子中，我们通过字段by_user字段对数据进行分组，并计算by_user字段相同值的总和。
