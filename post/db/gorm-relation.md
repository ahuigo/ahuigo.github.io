---
title: Gorm Relation
date: 2019-07-20
private:
---
# Gorm Relation
不会真的建立foreign key

## Belongs To
belongs to 会与另一个模型建立一对一关系，因此声明的每一个模型实例都会”属于”另一个模型实例。


    type User struct {
      gorm.Model
      Name string
    }

    // `Profile` belongs to `User`, `UserID` is the foreign key
    type Profile struct {
      gorm.Model
      UserID int
      // User   User // 不需要 
      Name   string
    }

你可以使用 Related 查找 belongs to 关系。

    var profile Profile
    user:=User{Model:gorm.Model{ID:2}, Name:"ahui",}
    db.Model(&user).Related(&profile)
    //// SELECT * FROM profiles WHERE user_id = 111; // 111 is user's ID

## Has One

    type CreditCard struct {
        gorm.Model
        Number string
        UID    string
    }

    type User struct {
        gorm.Model
        Name   string    `sql:"index"`
        CreditCard CreditCard `gorm:"foreignkey:uid;association_foreignkey:name"`
    }

根据User 查找card

    user:=User{Model:gorm.Model{ID:2}, Name:"ahui",}
    var card CreditCard

    db.Model(&user).Related(&card, "CreditCard")
        [SELECT * FROM "credit_cards"  WHERE "credit_cards"."deleted_at" IS NULL AND (("uid" = 'ahui'))
    db.First(&user).Related(&card, "CreditCard")
        1. select user(user.creditCard为空)
        2. select creditCard
        Note: 当First 查询失败时，即不会更新 user, 也不更新card

select user (has one card)

    db.Model(&user).Related(&user.CreditCard, "CreditCard")
    db.First(&user).Related(&user.CreditCard, "CreditCard")
    pf("%+v\n", user)
    pf("%+v\n", card)

### 简化的has one
    type Cat struct {
      ID    int
      Name  string
      Toy   Toy `gorm:"polymorphic:Owner;"`
    }

    type Dog struct {
      ID   int
      Name string
      Toy  Toy `gorm:"polymorphic:Owner;"`
    }

    type Toy struct {
      ID        int
      Name      string
      OwnerID   int
      OwnerType string
    }

## Has Many
    type User struct {
        gorm.Model
        MemberNumber string
        CreditCards  []CreditCard `gorm:"foreignkey:UserMemberNumber;association_foreignkey:MemberNumber"`
        CreditCards  []*CreditCard `gorm:"foreignkey:UserMemberNumber;association_foreignkey:MemberNumber"`
    }

    type CreditCard struct {
        gorm.Model
        Number           string
        UserMemberNumber string
    }

可以用user

    var cards []CreditCard
    user:=User{Model:gorm.Model{ID:23}, MemberNumber:"ahui",}
    db.Create(&user)
    db.Create(&CreditCard{UserMemberNumber:"ahui",})

    //user has no cards
    db.Find(&user).Related(&cards, "CreditCards")//.First(&user)
    pf("user:%+v;\ncards:%+v\n", user, cards)

    //user has cards
    db.First(&user).Related(&user.CreditCards, "CreditCards")//.First(&user)
    pf("user:%+v;\ncards:%+v\n", user, cards)


不可以用users(error):

    db.Where("name < ?", "jinzhu").Find(&users).Related(&cards, "CreditCards")

## Many2Many(inner join)
see: go-lib/gorm/many2many.go

自动创建 user_languages 关系表

    type User struct {
        gorm.Model
        Languages         []*Language `gorm:"many2many:user_languages;"`
    }

Working with Related/Preload

    db.Model(&User{ID:111}).Related(&languages, "Languages")
    //// SELECT * FROM "languages" INNER JOIN "user_languages" ON "user_languages"."language_id" = "languages"."id" WHERE "user_languages"."user_id" = 111

    // Preload Languages when query user
    db.Preload("Languages").First(&user)

### Foreign Keys
    type Person struct {
      IdPerson string             `gorm:"primary_key:true"`
      Accounts []CustomizeAccount `gorm:"many2many:PersonAccount;association_foreignkey:idAccount;foreignkey:idPerson"`
    }

    type Account struct {
      IdAccount string `gorm:"primary_key:true"`
      Name      string
    }

### Jointable ForeignKey
If you want to change join table’s foreign keys, you could use tag association_jointable_foreignkey, jointable_foreignkey


    type Person struct {
      IdPerson string             `gorm:"primary_key:true"`
      Accounts []CustomizeAccount `gorm:"many2many:PersonAccount;foreignkey:idPerson;association_foreignkey:idAccount;association_jointable_foreignkey:account_id;jointable_foreignkey:person_id;"`
    }

    type Account struct {
      IdAccount string `gorm:"primary_key:true"`
      Name      string
    }

### Self-Referencing
To define a self-referencing many2many relationship, you have to change association’s foreign key in the join table.

to make it different with source’s foreign key:

    type User struct {
      gorm.Model
      Friends []*User `gorm:"many2many:friendships;association_jointable_foreignkey:friend_id"`
    }

GORM will create a join table with foreign key user_id and friend_id, and use it to save user’s self-reference relationship.

    DB.Preload("Friends").First(&user, "id = ?", 1)

    DB.Model(&user).Association("Friends").Append(&User{Name: "friend1"}, &User{Name: "friend2"})

    DB.Model(&user).Association("Friends").Delete(&User{Name: "friend2"})

    DB.Model(&user).Association("Friends").Replace(&User{Name: "new friend"})

    DB.Model(&user).Association("Friends").Clear()

    DB.Model(&user).Association("Friends").Count()

# 预加载 
## Preload
    db.Preload("Orders").Find(&users)
    //// SELECT * FROM users;
    //// SELECT * FROM orders WHERE user_id IN (1,2,3,4);

    db.Preload("Orders", "state NOT IN (?)", "cancelled").Find(&users)
    //// SELECT * FROM users;
    //// SELECT * FROM orders WHERE user_id IN (1,2,3,4) AND state NOT IN ('cancelled');

    db.Where("state = ?", "active").Preload("Orders", "state NOT IN (?)", "cancelled").Find(&users)
    //// SELECT * FROM users WHERE state = 'active';
    //// SELECT * FROM orders WHERE user_id IN (1,2) AND state NOT IN ('cancelled');

    db.Preload("Orders").Preload("Profile").Preload("Role").Find(&users)
    //// SELECT * FROM users;
    //// SELECT * FROM orders WHERE user_id IN (1,2,3,4); // has many
    //// SELECT * FROM profiles WHERE user_id IN (1,2,3,4); // has one
    //// SELECT * FROM roles WHERE id IN (4,5,6); // belongs to

## Auto Preloading
Always auto preload associations

    type User struct {
      gorm.Model
      Name       string
      CompanyID  uint
      Company    Company `gorm:"PRELOAD:false"` // not preloaded
      Role       Role                           // preloaded
    }

    db.Set("gorm:auto_preload", true).Find(&users)

## Nested Preloading
嵌套

    db.Preload("Orders.OrderItems").Find(&users)
    db.Preload("Orders", "state = ?", "paid").Preload("Orders.OrderItems").Find(&users)

## Custom Preloading SQL
You could custom preloading SQL by passing in func(db *gorm.DB) *gorm.DB, for example:

    db.Preload("Orders", func(db *gorm.DB) *gorm.DB {
        return db.Order("orders.amount DESC")
    }).Find(&users)
    //// SELECT * FROM users;
    //// SELECT * FROM orders WHERE user_id IN (1,2,3,4) order by orders.amount DESC;


# associations
gorm 会根据关联自动创建、更新：see gorm/association.go

    DB.Create(&user)
    DB.Save(&user)

## 关联跳过
### 跳过自动更新
如果数据库中已存在关联, 你可能不希望对其进行更新。

可以使用 DB 设置, 将 gorm: association_autoupdate 设置为 false

    // Don't update associations having primary key, but will save reference
    db.Set("gorm:association_autoupdate", false).Create(&user)
    db.Set("gorm:association_autoupdate", false).Save(&user)

或者使用 GORM tags gorm:"association_autoupdate:false"

    type User struct {
        gorm.Model
        Name       string
        CompanyID  uint
        // Don't update associations having primary key, but will save reference
        Company    Company `gorm:"association_autoupdate:false"`
    }

### 跳过自动创建
即使你禁用了 AutoUpdating，没有主键的关联仍然会被创建，所有关联的引用也会被保存。

如果你也想跳过，那么你可以通过 DB 的设置，将gorm:association_autocreate设置为false

    // Don't create associations w/o primary key, WON'T save its reference
    db.Set("gorm:association_autocreate", false).Create(&user)
    db.Set("gorm:association_autocreate", false).Save(&user)

或使用 GORM tags GORM: "association_autocreate: false"

    type User struct {
        gorm.Model
        Name       string
        // Don't create associations w/o primary key, WON'T save its reference
        Company1   Company `gorm:"association_autocreate:false"`
    }

### 跳过自动创建及更新
To disable both AutoCreate and AutoUpdate, you could use those two settings together

    db.Set("gorm:association_autoupdate", false).Set("gorm:association_autocreate", false).Create(&user)

    type User struct {
      gorm.Model
      Name    string
      Company Company `gorm:"association_autoupdate:false;association_autocreate:false"`
    }

或使用 GORM Tag gorm: save_associations

    db.Set("gorm:save_associations", false).Create(&user)
    db.Set("gorm:save_associations", false).Save(&user)

    type User struct {
      gorm.Model
      Name    string
      Company Company `gorm:"save_associations:false"`
    }

### 跳过引用的保存
如果你不想保存关联的引用(如`user_languages`)，那么你可以使用下面的技巧

    db.Set("gorm:association_save_reference", false).Save(&user)
    db.Set("gorm:association_save_reference", false).Create(&user)
    或者使用 GORM Tag

    type User struct {
      gorm.Model
      Name       string
      CompanyID  uint
      Company    Company `gorm:"association_save_reference:false"`
    }

## 关联模式
Association Mode contains some helper methods to handle relationship related things easily.

    // user ID 关联ID必需的
    user:=User{ID:1}
    db.Model(&user).Association("Languages")
    // `user` is the source, must contains primary key
    // `Languages` is source's field name for a relationship
    // AssociationMode can only works if above two conditions both matched, check it ok or not:
    // db.Model(&user).Association("Languages").Error

### Related vs Association
二者等价

    user:=User{ID:1}
    db.Model(&user).Association("Languages").Find(&languages)
    db.Model(&user).Related(&languages,  "Languages")
    ////SELECT "languages".* FROM "languages" INNER JOIN "user_languages" ON "user_languages"."language_id" = "languages"."id" WHERE ("user_languages"."user_id" IN ('1'))

## 查找关联
查找匹配的关联

    user:=User{ID:1}
    db.Model(&user).Association("Languages").Find(&languages)

## 添加关联
为many to many，has many添加新的关联关系代替当前的关联关系has one，belongs to

    user:=User{ID:1} 
    db.Model(&user).Association("Languages").Append(Language{Name: "DE"})
        //1. user.Languages = append(user.Languages, languageDE)
        //2. INSERT INTO "languages" ("name") VALUES ('DE') RETURNING "languages"."id"
        //3. INSERT INTO "user_languages" ("user_id","language_id") SELECT '1','37'  WHERE NOT EXISTS (SELECT * FROM "user_languages" WHERE "user_id" = '1' AND "language_id" = '37')
    db.Model(&user).Association("Languages").Append([]Language{languageZH, languageEN})

## 替换关联
Replace current associations with new ones

    db.Model(&user).Association("Languages").Replace([]Language{languageZH, languageEN})
    db.Model(&user).Association("Languages").Replace(Language{Name: "DE"}, languageEN)
        //1. INSERT INTO "languages" ("name") VALUES ('DE') RETURNING "languages"."id"
        //2. INSERT INTO "user_languages" ("language_id","user_id") SELECT '40','1'  WHERE NOT EXISTS (SELECT * FROM "user_languages" WHERE "language_id" = '40' AND "user_id" = '1')
        //3.4. insert languageEN and relation
        //5. DELETE FROM "user_languages"  WHERE ("language_id" NOT IN ('40','41')) AND ("user_id" IN ('1'))
            //不会删除关联对应的languages

## 删除关联
删除关联的引用user_languages，不会删除关联本身 languages

    db.Model(&user).Association("Languages").Delete([]Language{languageZH, languageEN})
    db.Model(&user).Association("Languages").Delete(Language{ID:3})
        //languageEn 需要指定ID
        //DELETE FROM "user_languages"  WHERE ("user_id" = '1') AND ("language_id" IN ('3'))

## 清空关联
清空对关联的引用，不会删除关联本身

    db.Model(&user).Association("Languages").Clear()
        // DELETE FROM "user_languages"  WHERE ("user_id" IN ('1'))

## 关联的数量
返回关联的数量

    db.Model(&user).Association("Languages").Count()
        //SELECT count(*) FROM "languages" INNER JOIN "user_languages" ON "user_languages"."language_id" = "languages"."id" WHERE ("user_languages"."user_id" IN ('1'))