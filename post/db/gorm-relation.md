---
title: Gorm Relation
date: 2019-07-20
private:
---
# Gorm Relation
不会真的建立foreign key

# Belongs To
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

    type User struct {
        gorm.Model
        Languages         []*Language `gorm:"many2many:user_languages;"`
    }

    type Language struct {
        ID   int    `gorm:"primary_key"`
        Name string
        UserId int
        Users             []*User     `gorm:"many2many:languages;association_jointable_foreignkey:user_id;jointable_foreignkey:user_id;"` 
            /*
            association_jointable_foreignkey: 
                JOIN ON language.user_id=users.id
            jointable_foreignkey: 
                Where language.user_id in (2)
            HasMany:
                association_foreignkey:ID;foreignkey:ID;
            */
    }

    var users []User
    language := Language{}

    db.Create(&Language{Name:"en"})
    db.Create(&Language{Name:"zh",UserId:2})
    db.Create(&User{})
    //db.First(&language, "id = ?", 2)
    language = Language{ID:2}

    db.Model(&language).Related(&users,  "Users")
    //SELECT "users".* FROM "users" INNER JOIN "languages" ON "languages"."user_id" = "users"."id" WHERE "users"."deleted_at" IS NULL AND (("languages"."user_id" IN ('2')))

    pf("user:%+v;\n:language:%+v\n", users, language)

Working with Many To Many

    db.Model(&user).Related(&languages, "Languages")
    //// SELECT * FROM "languages" INNER JOIN "user_languages" ON "user_languages"."language_id" = "languages"."id" WHERE "user_languages"."user_id" = 111

    // Preload Languages when query user
    db.Preload("Languages").First(&user)

### Foreign Keys
    type CustomizePerson struct {
      IdPerson string             `gorm:"primary_key:true"`
      Accounts []CustomizeAccount `gorm:"many2many:PersonAccount;association_foreignkey:idAccount;foreignkey:idPerson"`
    }

    type CustomizeAccount struct {
      IdAccount string `gorm:"primary_key:true"`
      Name      string
    }

### Jointable ForeignKey
If you want to change join table’s foreign keys, you could use tag association_jointable_foreignkey, jointable_foreignkey


    type CustomizePerson struct {
      IdPerson string             `gorm:"primary_key:true"`
      Accounts []CustomizeAccount `gorm:"many2many:PersonAccount;foreignkey:idPerson;association_foreignkey:idAccount;association_jointable_foreignkey:account_id;jointable_foreignkey:person_id;"`
    }

    type CustomizeAccount struct {
      IdAccount string `gorm:"primary_key:true"`
      Name      string
    }

### Self-Referencing
To define a self-referencing many2many relationship, you have to change association’s foreign key in the join table.

to make it different with source’s foreign key, which is generated using struct’s name and its primary key, for example:

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
