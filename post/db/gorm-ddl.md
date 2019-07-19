---
title: Gorm ddl 操作
date: 2019-07-07
private:
---
# Gorm Migrate
自动迁移仅仅会创建表，缺少列和索引，并且不会改变现有列的类型或删除未使用的列以保护数据。

    db.AutoMigrate(&User{})

    db.AutoMigrate(&User{}, &Product{}, &Order{})

    // 创建表时添加表后缀
    db.Set("gorm:table_options", "ENGINE=InnoDB").AutoMigrate(&User{})

# Table
## hasTable 检查表是否存在
    // 检查模型`User`表是否存在
    db.HasTable(&User{})
    db.HasTable("users")

## 1.2.3. 创建表
    // 为模型`User`创建表
    db.CreateTable(&User{})
    // 创建表`users'时将“ENGINE = InnoDB”附加到SQL语句
    db.Set("gorm:table_options", "ENGINE=InnoDB").CreateTable(&User{})

## 1.2.4. 删除表
    // 删除模型`User`的表
    db.DropTable(&User{})

    // 删除表`users`
    db.DropTable("users")

    // 删除模型`User`的表和表`products`
    db.DropTableIfExists(&User{}, "products")

## 列
### 修改列
修改列的类型为给定值

    // 修改模型`User`的description列的数据类型为`text`
    db.Model(&User{}).ModifyColumn("description", "text")

### 1.2.6. 删除列
    // 删除模型`User`的description列
    db.Model(&User{}).DropColumn("description")

### 1.2.7. 添加外键
    // 添加主键
    // 1st param : 外键字段
    // 2nd param : 外键表(字段)
    // 3rd param : ONDELETE
    // 4th param : ONUPDATE
    db.Model(&User{}).AddForeignKey("city_id", "cities(id)", "RESTRICT", "RESTRICT")


# curd
## Create 创建记录

    p := Product{Code: "L1217", Price: 17}
    fmt.Printf("%#v\n", db.NewRecord(p))    // => 主键为空返回`true`
    fmt.Printf("%#v\n", p.ID)
    db.Create(&p)                           // 返回 DB
    fmt.Printf("%#v\n", db.NewRecord(p))    //// => 创建后返回`false`
    fmt.Printf("%#v\n", p.ID)

### 默认值

    type Animal struct {
        ID   int64
        Name string `gorm:"default:'galeone'"`
        Age  int64
    }

`empty column` NOTE: all fields having a zero value, like 0, '', false or other zero values, won’t be saved into the database but will use its default value. 

    var animal = Animal{Age: 99, Name: ""}
    db.Create(&animal)
    // INSERT INTO animals("age") values('99');
    // SELECT name from animals WHERE ID=111; // 返回主键为 111
    // animal.Name => 'galeone'

If you want to avoid this, consider using a pointer type or scanner/valuer, e.g:

    // Use pointer value
    type User struct {
        gorm.Model
        Name string
        Age  *int `gorm:"default:18"`
    }

    // Use scanner/valuer
    type User struct {
        gorm.Model
        Name string
        Age  sql.NullInt64 `gorm:"default:18"`
    }

### 在Hooks中设置字段值
If you want to update a field’s value in BeforeCreate hook, you can use scope.SetColumn, for example:

    func (user *User) BeforeCreate(scope *gorm.Scope) error {
        scope.SetColumn("ID", uuid.New())
        return nil
    }

### 扩展创建选项
为Instert语句添加扩展SQL选项

    db.Set("gorm:insert_option", "ON CONFLICT").Create(&product)
    // INSERT INTO products (name, code) VALUES ("name", "code") ON CONFLICT;

## Read 
### 查询
    //通过主键查询第一条记录
    db.First(&user)
    //// SELECT * FROM users ORDER BY id LIMIT 1;

    // 随机取一条记录
    db.Take(&user)
    //// SELECT * FROM users LIMIT 1;

    // 通过主键查询最后一条记录
    db.Last(&user)
    //// SELECT * FROM users ORDER BY id DESC LIMIT 1;

    // 拿到所有的记录
    db.Find(&users)
    //// SELECT * FROM users;

    // 查询指定的某条记录(只可在主键为整数型时使用)
    db.First(&user, 10)
    //// SELECT * FROM users WHERE id = 10;

insert-update: FirstOrCreate

    // Unfound
    db.FirstOrCreate(&user, User{Name: "non_existing"})
    //// INSERT INTO "users" (name) VALUES ("non_existing");
    //// user -> User{Id: 112, Name: "non_existing"}

    // Found
    db.Where(User{Name: "Jinzhu"}).FirstOrCreate(&user)
    //// user -> User{Id: 111, Name: "Jinzhu"}

### Where
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

#### Struct & Map

    // Struct
    db.Where(&User{Name: "jinzhu", Age: 20}).First(&user)
    //// SELECT * FROM users WHERE name = "jinzhu" AND age = 20 LIMIT 1;

    // Map
    db.Where(map[string]interface{}{"name": "jinzhu", "age": 20}).Find(&users)
    //// SELECT * FROM users WHERE name = "jinzhu" AND age = 20;

    // Slice of primary keys
    db.Where([]int64{20, 21, 22}).Find(&users)
    //// SELECT * FROM users WHERE id IN (20, 21, 22);

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
Get how many records for a model

    db.Where("name = ?", "jinzhu").Or("name = ?", "jinzhu 2").Find(&users).Count(&count)
    //// SELECT * from USERS WHERE name = 'jinzhu' OR name = 'jinzhu 2'; (users)
    //// SELECT count(*) FROM users WHERE name = 'jinzhu' OR name = 'jinzhu 2'; (count)

    db.Model(&User{}).Where("name = ?", "jinzhu").Count(&count)
    //// SELECT count(*) FROM users WHERE name = 'jinzhu'; (count)

    db.Table("deleted_users").Count(&count)
    //// SELECT count(*) FROM deleted_users;

NOTE When use Count in a query chain, it has to be the last one, as it will overwrite SELECT columns

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

## Result

### rows()
### Scan(&rows)
Scan results into another struct.

    type Result struct {
        Name string
        Age  int
    }

    var result Result
    db.Table("users").Select("name, age").Where("name = ?", 3).Scan(&result)


## Pluck
Query single column from a model as a map, if you want to query multiple columns, you should use Scan instead

    var ages []int64
    db.Find(&users).Pluck("age", &ages)

    var names []string
    db.Model(&User{}).Pluck("name", &names)

    db.Table("deleted_users").Pluck("name", &names)

    // Requesting more than one column? Do it like this:
    db.Select("name, age").Find(&users)

# 索引
idx

    // 为`name`列添加索引`idx_user_name`
    db.Model(&User{}).AddIndex("idx_user_name", "name")

    // 为`name`, `age`列添加索引`idx_user_name_age`
    db.Model(&User{}).AddIndex("idx_user_name_age", "name", "age")

UniqueIndex

    // 添加唯一索引
    db.Model(&User{}).AddUniqueIndex("idx_user_name", "name")

    // 为多列添加唯一索引
    db.Model(&User{}).AddUniqueIndex("idx_user_name_age", "name", "age")

RemoveIndex

    // 删除索引
    db.Model(&User{}).RemoveIndex("idx_user_name")

# Ref