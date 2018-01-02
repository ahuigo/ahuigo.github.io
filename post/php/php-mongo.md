# extensions
用mongodb extensions, 不用过时的mongo ext

# php

    $connection = new MongoClient( "mongodb://example.com" )

## timeout
Here's documentation for setting the timeout on a cursor.

    $cursor = $collection->find()->timeout(-1);

The command method does not return a cursor it returns an array.

If you take a look at the documentation for the command method, you'll see that it's actually just a wrapper for the following:

    public function command($data) {
        return $this->selectCollection('$cmd')->findOne($data);
    }
    $value = $db->command(
        array('distinct' => $collection, 'key' => 'uid', 'query' => $criteria),
        array('socketTimeoutMS' => 10000000000)
    );

### prevent MongoDB::command() from blocking?

    try {
        $db->command(array(...), array("timeout" => 1)); // timeout after 1ms
    } catch (MongoCursorTimeoutException $e) {
        // do nothing
    }

## get a database

    $db = $connection->dbname;
    $connection->listDBs();

## Getting A Collection
Getting a collection has the same syntax as getting a database:

    $db = $connection->baz;

    // select a collection:
    $collection = $db->foobar;

    // or, directly selecting a database and collection:
    $collection = $connection->baz->foobar;

### count

    $collection->count();

## insert document

    $doc = array(
        "name" => "MongoDB",
        "list" => [1,2,3],
        "count" => 1,
        "info" => (object)array( "x" => 203, "y" => 102),
    );
    $collection->insert($doc);

According to the docs the array you pass to insert will be amended with an _id field:

    $db->collection->insert($content);
    $newDocID = $content['_id'];_

## Finding Documents using MongoCollection::findOne()
To show that the document we inserted, we can do a simple MongoCollection::findOne()

    $document = $collection->findOne();
    var_dump( $document );

find a single document in a collection by some condition and limiting the returned fields.

    $users = $mongo->my_db->users;
    $user = $users->findOne(array('username' => 'jwage'), array('password'));
    print_r($user);

## count collection

    echo $collection->count();

## Using a Cursor to Get All of the Documents
mongo

    >db.COLLECTION_NAME.find().limit(NUMBER)
    db.collection.find().skip(offset).limit(10)

php

    $cursor = $collection->find();
    foreach ( $cursor as $id => $value ) {
        echo "$id: ";
        var_dump( $value );
    }

## query

    $query = array( 'i' => 71 );
    $cursor = $collection->find( $query );

    while ( $cursor->hasNext() ) {
        var_dump( $cursor->getNext() );
    }

if we wanted to get all documents where "i" > 50, we could write:

   $query = array( "i" => array('$gt' => 50 ) ); //note the single quotes around '$gt'
   $cursor = $collection->find($query);

### sort + limit
last 10 inserted doc:

    $col->find()->sort(array('_id'=>-1))->limit(3);
