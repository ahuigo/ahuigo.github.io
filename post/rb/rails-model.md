---
title: Rails model
date: 2020-06-05
private: true
---
# ruby 
    require 'active_record'
    require 'mysql2' # or 'pg' or 'sqlite3'

    ActiveRecord::Base.establish_connection(
      adapter:  'mysql2', # or 'postgresql' or 'sqlite3'
      database: 'DB_NAME',
      username: 'DB_USER',
      password: 'DB_PASS',
      host:     'localhost'
      port:     5432
    )

    # Note that the corresponding table is 'orders'
    class Order < ActiveRecord::Base
    end

    Order.all.each do |o|
      puts "o: #{o.inspect}"
    end

# Rails model
## select
    User.where(:id => session[:user]).where("status IN ('active', 'confirmed', 'suspended')").first

    row = User.find(7) #where id=7
    rows = User.find([3,7]) #where id in (3,7)

### all
    User.all.each do |o|
      puts "o: #{o.inspect}"
    end

### where
    .where('name LIKE :name OR email LIKE :name OR postcode LIKE :name', :name => t)

## update
    user = User.find_by(name: 'David')
    user.update(name: 'Dave')

## save
    if not user.save
        logger.error 'save error'

    user.save! #如果保存不成功就 异常

## delete
    user.destroy
        user.destoryed?
    User.find(15).destroy
    User.destroy(15)
    User.where(age: 20).destroy_all
    User.destroy_all(age: 20)

# raw sql
## select_all

    // models/User.rb
    recordsResult = User.connection.select_all("SELECT * FROM users WHERE id>'1'")
    recordsResult.each do |row|
        p row['id']
    end

或者转hash

    User.connection.select_all("SELECT * FROM users WHERE id>'1'").to_hash
    # => [
    {"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"},
    {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}
    ]

### Model.find_by_sql
    arrays = User.find_by_sql( "select * from users where id = $1", [[nil, 7]])
    // 可能是空数组[]

## bind
### execute prepare
    st = ActiveRecord::Base.connection.raw_connection.prepare("update table set f1=? where f2=? and f3=?")
    st.execute(f1, f2, f3)
    st.close

### bind - sanitize

    ActiveRecord::Base.connection.execute("update table set f1=#{ActiveRecord::Base.sanitize(f1)}")

### execute

    sql = "Select * from ... your sql query here"
    records_obj= ActiveRecord::Base.connection.execute(sql, )
    records_obj.values

### exec_query

    ActiveRecord::Base.connection.exec_query(
        'SELECT * FROM users WHERE id = $1',
        'SQL',
        [[nil, 7000]],
        prepare: true
    )

    values = ActiveRecord::Base.connection.exec_query("select * from clients")
    [{"id": 1, "name": "user 1"}, {"id": 2, "name": "user 2"}, {"id": 3, "name": "user 3"}]
    p values.rows
    p values.columns
