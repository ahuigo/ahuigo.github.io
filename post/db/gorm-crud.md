---
title: Gorm CRUD
date: 2019-07-19
private:
---
# DDL
## 初始化db
比如

  db, err = gorm.Open("postgres", "host=localhost user=role1 dbname=ahuigo sslmode=disable password=")

## Column Name

    `gorm:"column:beast_id"`
 	`json:"page_size" form:"pageSize" gorm:"-"` //gorm 忽略

## TableName
    type User struct {} // 默认表名是`users`

    // 设置User的表名为`profiles`
    func (User) TableName() string {
        return "profiles"
    }

    func (u User) TableName() string {
        if u.Role == "admin" {
            return "admin_users"
        } else {
            return "users"
        }
    }

设置表名：

    db.Table(name string) *DB
    db.Table("users")
    db.Model(&User{})

### 全局禁用表名复数
    // 全局禁用表名复数
    db.SingularTable(true) // 如果设置为true,`User`的默认表名为`user`,使用`TableName`设置的表名不受影响

### 更改默认表名
您可以通过定义DefaultTableNameHandler对默认表名应用任何规则。

    gorm.DefaultTableNameHandler = func (db *gorm.DB, defaultTableName string) string  {
        return "prefix_" + defaultTableName;
    }

# Create 创建记录

## Creat/newRecord

Creat: 创建真正的record
NewRecord: check if value's primary key is blank(check v.ID, 不会insert 数据)

    p := Product{Code: "L1217", Price: 17}
    fmt.Printf("%#v\n", db.NewRecord(p))    // => 主键为空返回`true`
    if db.NewRecord(p){
        fmt.Printf("%#v\n", p.ID)
        db.Create(&p)                           // 返回 DB
        fmt.Printf("%#v\n", p.ID)               //ID
        fmt.Printf("%#v\n", db.NewRecord(p))    //// => 创建后返回`false`
    } 

### error

    if err := db.Create(data).Error; err != nil {

## 默认值

    type Animal struct {
        ID   int64
        Name string `gorm:"default:'galeone'"`
        Age  int64
    }

### `empty column` 
NOTE: all fields having a zero value, like 0, '', false or other zero values, won’t be saved into the database but will use its default value. 

    var animal = Animal{Age: 99, Name: ""}
    db.Create(&animal)
    // INSERT INTO animals("age") values('99');
    // SELECT name from animals WHERE ID=111; // 返回主键为 111
    // animal.Name => 'galeone'

avoid this: consider using a `pointer type` or scanner/valuer, e.g:

    // Use pointer value
    type User struct {
        gorm.Model
        Name string
        Age  *int `gorm:"default:18"`
    }

    // Use scanner/valuer
    import "database/sql"
    type User struct {
        gorm.Model
        Name string
        Age  sql.NullInt64 `gorm:"default:18"`  //sql.NullInt64{Int64:18, Valid:true}}
    }

## 在Hooks中设置字段值
If you want to update a field’s value in BeforeCreate hook, you can use scope.SetColumn, for example:

    func (user *User) BeforeCreate(scope *gorm.Scope) error {
        scope.SetColumn("ID", uuid.New())
        return nil
    }

## 扩展创建选项
为Instert语句添加扩展SQL选项

    db.Set("gorm:insert_option", "ON CONFLICT").Create(&product)
    // INSERT INTO products (name, code) VALUES ("name", "code") ON CONFLICT;

## INSERT + update
    Set("gorm:insert_option", "ON CONFLICT (user_id, date) DO UPDATE SET completion = excluded.completion").Create(&user)

# Read 
对于Count来说，先设置表名

    db = db.Model(&User{})
    db.Where(&query).Count(&total)

## Where
Plain SQL

    // Get first matched record
    db.Where("name = ?", "jinzhu").First(&user)
    //// SELECT * FROM users WHERE name = 'jinzhu' limit 1;

    // Get all matched records
    db.Where("name = ?", "jinzhu").Find(&users)
    //// SELECT * FROM users WHERE name = 'jinzhu';

    // <>
    db.Where("name <> ?", "jinzhu").Find(&users)

    // IN
    db.Where("name IN (?)", []string{"jinzhu", "jinzhu 2"}).Find(&users)

    // LIKE
    db.Where("name LIKE ?", "%jin%").Find(&users)

    // AND
    db.Where("name = ? AND age >= ?", "jinzhu", "22").Find(&users)

    // Time
    db.Where("updated_at > ?", lastWeek).Find(&users)

    // BETWEEN
    db.Where("created_at BETWEEN ? AND ?", lastWeek, today).Find(&users)

### Multiple where

    // Time
    db.Where("updated_at > ?", lastWeek)
    .Where("created_at > ?", lastYear).Find(&users)

### Chain 链
    db = db.Model(&user)
        .Where("username like ?", "%"+username+"%")
	    .Where(&user)

上面的带where条件的db，可以重复使用

    db.Count(&total)
    db.Find(&users).Error
    db.Offset((page - 1) * size).Limit(size).Find(&users).Error

### Struct & Map & slice

    // Struct
    db.Where(&User{Name: "jinzhu", Age: 20}).First(&user)
    //// SELECT * FROM users WHERE name = "jinzhu" AND age = 20 LIMIT 1;

    // Map
    db.Where(map[string]interface{}{"name": "jinzhu", "age": 20}).Find(&users)
    //// SELECT * FROM users WHERE name = "jinzhu" AND age = 20;

    // Slice of primary keys
    db.Where([]int64{20, 21, 22}).Find(&users)
    //// SELECT * FROM users WHERE id IN (20, 21, 22);

#### ignore zero/''/false
提示 当通过结构体进行查询时，GORM将会只通过非零值字段查询，这意味着如果你的字段值为0，''， false 或者其他 零值时，将不会被用于构建查询条件，例如：

    db.Where(&User{Name: "jinzhu", Age: 0}).Find(&users)
    //// SELECT * FROM users WHERE name = "jinzhu";

You could consider to use pointer type or scanner/valuer to avoid this.

    // Use pointer value
    type User struct {
        gorm.Model
        Name string
        Age  *int
    }

    // Use scanner/valuer
    type User struct {
        gorm.Model
        Name string
        Age  sql.NullInt64
    }

### Not
Works similar like Where

    db.Not("name", "jinzhu").First(&user)
    //// SELECT * FROM users WHERE name <> "jinzhu" LIMIT 1;

    // Not In
    db.Not("name", []string{"jinzhu", "jinzhu 2"}).Find(&users)
    //// SELECT * FROM users WHERE name NOT IN ("jinzhu", "jinzhu 2");

    // Not In slice of primary keys
    db.Not([]int64{1,2,3}).First(&user)
    //// SELECT * FROM users WHERE id NOT IN (1,2,3);

    db.Not([]int64{}).First(&user)
    //// SELECT * FROM users;

    // Plain SQL
    db.Not("name = ?", "jinzhu").First(&user)
    //// SELECT * FROM users WHERE NOT(name = "jinzhu");

    // Struct
    db.Not(User{Name: "jinzhu"}).First(&user)
    //// SELECT * FROM users WHERE name <> "jinzhu";

### Or
    db.Where("role = ?", "admin").Or("role = ?", "super_admin").Find(&users)
    //// SELECT * FROM users WHERE role = 'admin' OR role = 'super_admin';

    // Struct
    db.Where("name = 'jinzhu'").Or(User{Name: "jinzhu 2"}).Find(&users)
    //// SELECT * FROM users WHERE name = 'jinzhu' OR name = 'jinzhu 2';

    // Map
    db.Where("name = 'jinzhu'").Or(map[string]interface{}{"name": "jinzhu 2"}).Find(&users)
    //// SELECT * FROM users WHERE name = 'jinzhu' OR name = 'jinzhu 2';

### Inline Condition
Works similar like Where.

When using with Multiple Immediate Methods, won’t pass those conditions to later immediate methods.

    // Get by primary key (only works for integer primary key)
    db.First(&user, 23)
    //// SELECT * FROM users WHERE id = 23 LIMIT 1;
    // Get by primary key if it were a non-integer type
    db.First(&user, "id = ?", "string_primary_key")
    //// SELECT * FROM users WHERE id = 'string_primary_key' LIMIT 1;

    // Plain SQL
    db.Find(&user, "name = ?", "jinzhu")
    //// SELECT * FROM users WHERE name = "jinzhu";

    db.Find(&users, "name <> ? AND age > ?", "jinzhu", 20)
    //// SELECT * FROM users WHERE name <> "jinzhu" AND age > 20;

    // Struct
    db.Find(&users, User{Age: 20})
    //// SELECT * FROM users WHERE age = 20;

    // Map
    db.Find(&users, map[string]interface{}{"age": 20})
    //// SELECT * FROM users WHERE age = 20;

### Extra Querying option
    // Add extra SQL option for selecting SQL
    db.Set("gorm:query_option", "FOR UPDATE").First(&user, 10)
    //// SELECT * FROM users WHERE id = 10 FOR UPDATE;

## FirstOrInit (not creat record)
Get first matched record, or initalize a new one with given conditions (only works with struct, map conditions)

    // Unfound
    db.FirstOrInit(&user, User{Name: "non_existing"})
    //// user -> User{Name: "non_existing"}

    // Found
    db.Where(User{Name: "Jinzhu"}).FirstOrInit(&user)
    //// user -> User{Id: 111, Name: "Jinzhu", Age: 20}
    db.FirstOrInit(&user, map[string]interface{}{"name": "jinzhu"})
    //// user -> User{Id: 111, Name: "Jinzhu", Age: 20}

### Attrs
Initalize struct with argument if record not found

    // Unfound
    db.Where(User{Name: "non_existing"}).Attrs(User{Age: 20}).FirstOrInit(&user)
    //// SELECT * FROM USERS WHERE name = 'non_existing';
    //// user -> User{Name: "non_existing", Age: 20}

    db.Where(User{Name: "non_existing"}).Attrs("age", 20).FirstOrInit(&user)
    //// SELECT * FROM USERS WHERE name = 'non_existing';
    //// user -> User{Name: "non_existing", Age: 20}

    // Found
    db.Where(User{Name: "Jinzhu"}).Attrs(User{Age: 30}).FirstOrInit(&user)
    //// SELECT * FROM USERS WHERE name = jinzhu';
    //// user -> User{Id: 111, Name: "Jinzhu", Age: 20}

### Assign
Assign argument to struct regardless it is found or not

    // Unfound
    db.Where(User{Name: "non_existing"}).Assign(User{Age: 20}).FirstOrInit(&user)
    //// user -> User{Name: "non_existing", Age: 20}

    // Found
    db.Where(User{Name: "Jinzhu"}).Assign(User{Age: 30}).FirstOrInit(&user)
    //// SELECT * FROM USERS WHERE name = jinzhu';
    //// user -> User{Id: 111, Name: "Jinzhu", Age: 30}

## FirstOrCreate (creat record)
Get first matched record, or create a new one with given conditions (only works with struct, map conditions)

    // Unfound
    db.FirstOrCreate(&user, User{Name: "non_existing"})
    //// INSERT INTO "users" (name) VALUES ("non_existing");
    //// user -> User{Id: 112, Name: "non_existing"}

    // Found
    db.Where(User{Name: "Jinzhu"}).FirstOrCreate(&user)
    //// user -> User{Id: 111, Name: "Jinzhu"}

### Attrs
Assign struct with argument if record not found and create with those values

    // Unfound
    db.Where(User{Name: "non_existing"}).Attrs(User{Age: 20}).FirstOrCreate(&user)
    //// SELECT * FROM users WHERE name = 'non_existing';
    //// INSERT INTO "users" (name, age) VALUES ("non_existing", 20);
    //// user -> User{Id: 112, Name: "non_existing", Age: 20}

    // Found
    db.Where(User{Name: "jinzhu"}).Attrs(User{Age: 30}).FirstOrCreate(&user)
    //// SELECT * FROM users WHERE name = 'jinzhu';
    //// user -> User{Id: 111, Name: "jinzhu", Age: 20}

### Assign
Assign it to the record regardless it is found or not, and save back to database.

    // Unfound
    db.Where(User{Name: "non_existing"}).Assign(User{Age: 20}).FirstOrCreate(&user)
    //// SELECT * FROM users WHERE name = 'non_existing';
    //// INSERT INTO "users" (name, age) VALUES ("non_existing", 20);
    //// user -> User{Id: 112, Name: "non_existing", Age: 20}

    // Found
    db.Where(User{Name: "jinzhu"}).Assign(User{Age: 30}).FirstOrCreate(&user)
    //// SELECT * FROM users WHERE name = 'jinzhu';
    //// UPDATE users SET age=30 WHERE id = 111;
    //// user -> User{Id: 111, Name: "jinzhu", Age: 30}

## Advanced Query
### SubQuery
SubQuery with *gorm.expr

    db.Where("amount > ?", DB.Table("orders").Select("AVG(amount)").Where("state = ?", "paid").QueryExpr()).Find(&orders)
    // SELECT * FROM "orders"  WHERE "orders"."deleted_at" IS NULL AND (amount > (SELECT AVG(amount) FROM "orders"  WHERE (state = 'paid')));

### Select
Specify fields that you want to retrieve from database, by default, will select all fields

    db.Select("*").Find(&users)
    db.Select("name, age").Find(&users)
    //// SELECT name, age FROM users;

    db.Select([]string{"name", "age"}).Find(&users)
    //// SELECT name, age FROM users;

    db.Table("users").Select("COALESCE(age,?)", 42).Rows()
    //// SELECT COALESCE(age,'42') FROM users;

### Order
Specify order when retrieve records from database, set reorder (the second argument) to true to overwrite defined conditions

    db.Order("age desc, name").Find(&users)
    //// SELECT * FROM users ORDER BY age desc, name;

    // Multiple orders
    db.Order("age desc").Order("name").Find(&users)
    //// SELECT * FROM users ORDER BY age desc, name;

    // ReOrder
    db.Order("age desc").Find(&users1).Order("age", true).Find(&users2)
    //// SELECT * FROM users ORDER BY age desc; (users1)
    //// SELECT * FROM users ORDER BY age; (users2)

### Limit
Specify the max number of records to retrieve

    db.Limit(3).Find(&users)
    //// SELECT * FROM users LIMIT 3;

    // Cancel limit condition with -1
    db.Limit(10).Find(&users1).Limit(-1).Find(&users2)
    //// SELECT * FROM users LIMIT 10; (users1)
    //// SELECT * FROM users; (users2)

### Offset
Specify the number of records to skip before starting to return the records

    db.Offset(3).Find(&users)
    //// SELECT * FROM users OFFSET 3;

    // Cancel offset condition with -1
    db.Offset(10).Find(&users1).Offset(-1).Find(&users2)
    //// SELECT * FROM users OFFSET 10; (users1)
    //// SELECT * FROM users; (users2)

### Count
Return how many records for a model

    err := db.Where("name = ?", "jinzhu").Or("name = ?", "jinzhu 2").Find(&users).Count(&count)
    //// SELECT * from USERS WHERE name = 'jinzhu' OR name = 'jinzhu 2'; (users)
    //// SELECT count(*) FROM users WHERE name = 'jinzhu' OR name = 'jinzhu 2'; (count)

    err := db.Model(&User{}).Where("name = ?", "jinzhu").Count(&count)
    //// SELECT count(*) FROM users WHERE name = 'jinzhu'; (count)

    err := db.Table("deleted_users").Count(&count)
    //// SELECT count(*) FROM deleted_users;

NOTE When use Count in a query chain, it has to be the last one, as it will overwrite SELECT columns

    db.Table("users").Offset(40).Limit(20).Find(&users).Offset(-1).Count(&total)
    db.Model(&User{}).Offset(40).Limit(20).Find(&users).Offset(-1).Count(&total)
### Group & Having

    rows, err := db.Table("orders").Select("date(created_at) as date, sum(amount) as total").Group("date(created_at)").Rows()
    for rows.Next() {
        ...
    }

    rows, err := db.Table("orders").Select("date(created_at) as date, sum(amount) as total").Group("date(created_at)").Having("sum(amount) > ?", 100).Rows()
    for rows.Next() {
        ...
    }

    type Result struct {
        Date  time.Time
        Total int64
    }
    db.Table("orders").Select("date(created_at) as date, sum(amount) as total").Group("date(created_at)").Having("sum(amount) > ?", 100).Scan(&results)

### Joins
Specify Joins conditions

    rows, err := db.Table("users").Select("users.name, emails.email").Joins("left join emails on emails.user_id = users.id").Rows()
    for rows.Next() {
        ...
    }

    db.Table("users").Select("users.name, emails.email").Joins("left join emails on emails.user_id = users.id").Scan(&results)

    // multiple joins with parameter
    db.Joins("JOIN emails ON emails.user_id = users.id AND emails.email = ?", "jinzhu@example.org").Joins("JOIN credit_cards ON credit_cards.user_id = users.id").Where("credit_cards.number = ?", "411111111111").Find(&user)
### Raw
    // Raw SQL
    db.Raw("SELECT name, age FROM users WHERE name = ?", 3).Scan(&result)

	s.Exec("DELETE FROM users")

### Specify table
    s.Table("tableName").find(&users)

## Result
### First Take Last

    //通过主键查询第一条记录
    db.First(&user)
    //// SELECT * FROM users ORDER BY id LIMIT 1;

    // 查询指定的某条记录(只可在主键为整数型时使用)
    db.First(&user, 10)
    db.Firse(&User{ID:10})
    //// SELECT * FROM users WHERE id = 10;

    // 随机取一条记录
    db.Take(&user)
    //// SELECT * FROM users LIMIT 1;

    // 通过主键查询最后一条记录
    db.Last(&user)
    //// SELECT * FROM users ORDER BY id DESC LIMIT 1;

### Find(&rows) Find(&row) 可以带where
    // 拿到所有的记录
    db.Find(&users)
    //// SELECT * FROM users;

    // Cancel limit condition with -1
    db.Limit(10).Find(&users1).Limit(-1).Find(&users2)
    //// SELECT * FROM users LIMIT 10; (users1)
    //// SELECT * FROM users; (users2)

    db.Where(User{id:1}).Find(&users)

### Scan(&rows row var)
Scan results into another struct.

    type Result struct {
        Name string
        Age  int
    }

    var result Result
    db.Table("users").Select("name, age").Where("name = ?", 3).Scan(&result)

这样也可以的

    Scan(&field)
    Scan(&user)
    Scan(&users)

### Row
    func (s *DB) Row() *sql.Row

### Rows()
    rows, err := db.Table("orders").Select("date(created_at) as date, sum(amount) as total").Group("date(created_at)").Rows()
    for rows.Next() {
        var name string
        if err := rows.Scan(&name); err != nil {
            log.Fatal(err)
        }
        names = append(names, name)
    }

### Pluck
Query single column from a model as a map, if you want to query multiple columns, you should use Scan instead

    var ages []int64
    db.Find(&users).Pluck("age", &ages)

    var names []string
    db.Model(&User{}).Pluck("name", &names)

    db.Table("deleted_users").Pluck("name", &names)

    // Requesting more than one column? Do it like this:
    db.Select("name, age").Find(&users)

# Update
## Specify Primary Key(不能用`Model(&User{}).Save(&user)`)

    db.Model(User{ID:1}).Updates(User{Name: "hello", Age: 18}).RowsAffected
    db.Model(User{}).Updates(User{ID:1, Name: "hello", Age: 18}).RowsAffected

默认更新全部

    db.Model(User{}).Updates(User{Name: "hello", Age: 18}).RowsAffected //all

## Save 更新所有字段
Save 会根据primary_key 自动创建/更新record
Save会更新所有字段，即使你没有赋值

    db.First(&user)

    user.Name = "jinzhu 2"
    user.Age = 100
    db.Save(&user) //user 必须有一个primary_key 可以不必是ID
    //// UPDATE users SET name='jinzhu 2', age=100, birthday='2016-01-01', updated_at = '2013-11-17 21:34:10' WHERE id=111;

## Update 更新修改字段
如果你只希望更新指定字段，可以使用Update或者Updates (Update 的底层是Updates)

    ```go
    // Update single attribute if it is changed
    db.Model(&user).Update("name", "hello")
    //// UPDATE users SET name='hello', updated_at='2013-11-17 21:34:10' WHERE id=111;

    // Update single attribute with combined conditions
    db.Model(&user).Where("active = ?", true).Update("name", "hello")
    //// UPDATE users SET name='hello', updated_at='2013-11-17 21:34:10' WHERE id=111 AND active=true;

    // Update multiple attributes with `map`, will only update those changed fields
    db.Model(&user).Updates(map[string]interface{}{"name": "hello", "age": 18, "actived": false})
    //// UPDATE users SET name='hello', age=18, actived=false, updated_at='2013-11-17 21:34:10' WHERE id=111;

    // Update multiple attributes with `struct`, will only update those changed & non blank fields
    db.Model(&user).Updates(User{Name: "hello", Age: 18})
    //// UPDATE users SET name='hello', age=18, updated_at = '2013-11-17 21:34:10' WHERE id = 111;
    ```

WARNING when update with struct, GORM will only update those fields that with non blank value

    ```go
    // For below Update, nothing will be updated as "", 0, false are blank values of their types
    db.Model(&user).Updates(User{Name: "", Age: 0, Actived: false})
    ```

### update interface

    user:=User{ID:1} //where id=1

    // Update multiple attributes with `map`, will only update those changed fields
    db.Model(&user).Updates(map[string]interface{}{"name": "hello", "age": 18, "actived": false})
    //// UPDATE users SET name='hello', age=18, actived=false, updated_at='2013-11-17 21:34:10' WHERE id=111;


## Update Selected Fields
If you only want to update or ignore some fields when updating, you could use `Select`, `Omit`

    ```go
    db.Model(&user).Select("name").Updates(map[string]interface{}{"name": "hello", "age": 18, "actived": false})
    //// UPDATE users SET name='hello', updated_at='2013-11-17 21:34:10' WHERE id=111;

    db.Model(&user).Omit("name").Updates(map[string]interface{}{"name": "hello", "age": 18, "actived": false})
    //// UPDATE users SET age=18, actived=false, updated_at='2013-11-17 21:34:10' WHERE id=111;
    ```

## Update Columns w/o Hooks
Above updating operations will perform the model's `BeforeUpdate`, `AfterUpdate` method, update its `UpdatedAt` timestamp, save its `Associations` when updating, if you don't want to call them, you could use `UpdateColumn`, `UpdateColumns`

    ```go
    // Update single attribute, similar with `Update`
    db.Model(&user).UpdateColumn("name", "hello")
    //// UPDATE users SET name='hello' WHERE id = 111;

    // Update multiple attributes, similar with `Updates`
    db.Model(&user).UpdateColumns(User{Name: "hello", Age: 18})
    //// UPDATE users SET name='hello', age=18 WHERE id = 111;
    ```

## Batch Updates
Note: Hooks won’t run when do batch updates

    ```go
    db.Table("users").Where("id IN (?)", []int{10, 11}).Updates(map[string]interface{}{"name": "hello", "age": 18})
    //// UPDATE users SET name='hello', age=18 WHERE id IN (10, 11);

    // Update with struct only works with none zero values, or use map[string]interface{}
    db.Model(User{}).Updates(User{Name: "hello", Age: 18})
    //// UPDATE users SET name='hello', age=18;

    // Get updated records count with `RowsAffected`
    db.Model(User{}).Updates(User{Name: "hello", Age: 18}).RowsAffected
    ```

## Update with Raw SQL Expression

    ```go
    DB.Model(&product).Update("price", gorm.Expr("price * ? + ?", 2, 100))
    //// UPDATE "products" SET "price" = price * '2' + '100', "updated_at" = '2013-11-17 21:34:10' WHERE "id" = '2';

    DB.Model(&product).Updates(map[string]interface{}{"price": gorm.Expr("price * ? + ?", 2, 100)})
    //// UPDATE "products" SET "price" = price * '2' + '100', "updated_at" = '2013-11-17 21:34:10' WHERE "id" = '2';

    DB.Model(&product).UpdateColumn("quantity", gorm.Expr("quantity - ?", 1))
    //// UPDATE "products" SET "quantity" = quantity - 1 WHERE "id" = '2';

    DB.Model(&product).Where("quantity > 1").UpdateColumn("quantity", gorm.Expr("quantity - ?", 1))
    //// UPDATE "products" SET "quantity" = quantity - 1 WHERE "id" = '2' AND quantity > 1;
    ```

## Change Values In Hooks
If you want to change updating values in hooks using `BeforeUpdate`, `BeforeSave`, you could use `scope.SetColumn`, for example:

    ```go
    func (user *User) BeforeSave(scope *gorm.Scope) (err error) {
        if pw, err := bcrypt.GenerateFromPassword(user.Password, 0); err == nil {
            scope.SetColumn("EncryptedPassword", pw)
        }
    }
    ```

## Extra Updating option

    ```go
    // Add extra SQL option for updating SQL
    db.Model(&user).Set("gorm:update_option", "OPTION (OPTIMIZE FOR UNKNOWN)").Update("name", "hello")
    //// UPDATE users SET name='hello', updated_at = '2013-11-17 21:34:10' WHERE id=111 OPTION (OPTIMIZE FOR UNKNOWN);
    ```


 # Delete
 ## 删除记录
WARNING: GORM will use the `primary key`(not unique) to delete the record, if the primary key field is blank, GORM will delete all records for the model

    // Delete an existing record
    db.Delete(&email)
    //// DELETE from emails where id=10;

    // Add extra SQL option for deleting SQL
    db.Set("gorm:delete_option", "OPTION (OPTIMIZE FOR UNKNOWN)").Delete(&email)
    //// DELETE from emails where id=10 OPTION (OPTIMIZE FOR UNKNOWN);

## where delete
    db.Where(Email{email:"a@a.com"}).Delete(Email{})

## Batch Delete
Delete all matched records

    db.Where("email LIKE ?", "%jinzhu%").Delete(Email{})
    //// DELETE from emails where email LIKE "%jinzhu%";

    db.Delete(Email{}, "email LIKE ?", "%jinzhu%")
    //// DELETE from emails where email LIKE "%jinzhu%";

## Soft Delete
If a model has a `DeletedAt` field, it will get a soft delete ability automatically!

    db.Delete(&user)
    //// UPDATE users SET deleted_at="2013-10-29 10:23" WHERE id = 111;

    // Batch Delete
    db.Where("age = ?", 20).Delete(&User{})
    //// UPDATE users SET deleted_at="2013-10-29 10:23" WHERE age = 20;

    // Soft deleted records will be ignored when query them
    db.Where("age = 20").Find(&user)
    //// SELECT * FROM users WHERE age = 20 AND deleted_at IS NULL;

## Delete record permanently(Unsoped)

    // Find soft deleted records with Unscoped
    db.Unscoped().Where("age = 20").Find(&users)
    //// SELECT * FROM users WHERE age = 20;

    // Delete record permanently with Unscoped
    db.Unscoped().Delete(&order)
    //// DELETE FROM orders WHERE id=10;

# 原生SQL
## Exec & Raw
Run Raw SQL, which is not chainable with other methods

    db.Exec("DROP TABLE users;")
    db.Exec("UPDATE orders SET shipped_at=? WHERE id IN (?)", time.Now(), []int64{11,22,33})

    // Scan
    type Result struct {
        Name string
        Age  int
    }

    var result Result
    db.Raw("SELECT name, age FROM users WHERE name = ?", 3).Scan(&result)

## sql.Row & sql.Rows
Get query result as `*sql.Row or *sql.Rows`

### sql.Row

    row := db.Table("users").Where("name = ?", "jinzhu").Select("name, age").Row() // (*sql.Row)
    row.Scan(&name, &age)

### sql.Rows
    rows, err := db.Model(&User{}).Where("name = ?", "jinzhu").Select("name, age, email").Rows() // (*sql.Rows, error)
    defer rows.Close()
    for rows.Next() {
        ...
        rows.Scan(&name, &age, &email)
        ...
    }

    // Raw SQL
    rows, err := db.Raw("select name, age, email from users where name = ?", "jinzhu").Rows() // (*sql.Rows, error)
    defer rows.Close()
    for rows.Next() {
        ...
        rows.Scan(&name, &age, &email)
        ...
    }

### Scan sql.Rows into model
    rows, err := db.Model(&User{}).Where("name = ?", "jinzhu").Select("name, age, email").Rows() // (*sql.Rows, error)
    defer rows.Close()

    for rows.Next() {
        var user User
        // ScanRows scan a row into user
        db.ScanRows(rows, &user)

        // do something
    }

# Transaction
	db := db1.Begin()
    db.Rollback()
    db.Commit()
