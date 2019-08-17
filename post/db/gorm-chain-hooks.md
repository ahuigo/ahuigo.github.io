---
title: Gorm chain and hooks
date: 2019-08
private:
---
# Gorm Chain
## Method Chaining
Gorm implements method chaining interface:

    db, err := gorm.Open("postgres", "user=gorm dbname=gorm sslmode=disable")

    // create a new relation
    tx := db.Where("name = ?", "jinzhu")

    // add more filter
    if someCondition {
        tx = tx.Where("age = ?", 20)
    } else {
        tx = tx.Where("age = ?", 30)
    }

    if yetAnotherCondition {
        tx = tx.Where("active = ?", 1)
    }

Query won’t be generated until a immediate method, which could be useful in some cases.

## Immediate Methods
Immediate methods are those methods that will generate SQL query and send it to database

    Create, First, Find, Take, Save, UpdateXXX, Delete, Scan, Row, Rows…

Here is an immediate methods example based on above chain:

    tx.Find(&user)
    //Generates
    SELECT * FROM users where name = 'jinzhu' AND age = 30 AND active = 1;

## Scopes
Scope is build based on the method chaining theory.
With it, you could extract some generic logics, to write more reusable libraries.

    func AmountGreaterThan1000(db *gorm.DB) *gorm.DB {
        return db.Where("amount > ?", 1000)
    }

    func PaidWithCreditCard(db *gorm.DB) *gorm.DB {
        return db.Where("pay_mode_sign = ?", "C")
    }

    func PaidWithCod(db *gorm.DB) *gorm.DB {
        return db.Where("pay_mode_sign = ?", "C")
    }

    func OrderStatus(status []string) func (db *gorm.DB) *gorm.DB {
        return func (db *gorm.DB) *gorm.DB {
            return db.Scopes(AmountGreaterThan1000).Where("status IN (?)", status)
        }
    }

    db.Scopes(AmountGreaterThan1000, PaidWithCreditCard).Find(&orders)
    // Find all credit card orders and amount greater than 1000

    db.Scopes(AmountGreaterThan1000, PaidWithCod).Find(&orders)
    // Find all COD orders and amount greater than 1000

    db.Scopes(AmountGreaterThan1000, OrderStatus([]string{"paid", "shipped"})).Find(&orders)
    // Find all paid, shipped orders that amount greater than 1000

## Multiple Immediate Methods
When using multiple immediate methods with GORM, later immediate method will reuse before immediate methods’s query conditions (excluding inline conditions)

    db.Where("name LIKE ?", "jinzhu%").Find(&users, "id IN (?)", []int{1, 2, 3}).Count(&count)
        //1. SELECT * FROM users WHERE name LIKE 'jinzhu%' AND id IN (1, 2, 3)
        //2. SELECT count(*) FROM users WHERE name LIKE 'jinzhu%'

# Hooks
## Creating an object
Available hooks for creating

    // begin transaction
    BeforeSave
    BeforeCreate
    // save before associations
    // update timestamp `CreatedAt`, `UpdatedAt`
    // save self
    // reload fields that have default value and its value is blank
    // save after associations
    AfterCreate
    AfterSave
    // commit or rollback transaction

Code Example:

    func (u *User) BeforeSave() (err error) {
        if u.IsValid() {
            err = errors.New("can't save invalid data")
        }
        return
    }

    func (u *User) AfterCreate(scope *gorm.Scope) (err error) {
        if u.ID == 1 {
        scope.DB().Model(u).Update("role", "admin")
    }
        return
    }

NOTE Save/Delete operations in GORM are running in transactions by default, so changes made in that transaction are not visible until it is commited. If you would like access those changes in your hooks, you could accept current transaction as argument in your hooks, for example:

    func (u *User) AfterCreate(tx *gorm.DB) (err error) {
        tx.Model(u).Update("role", "admin")
        return
    }

## Updating an object
Available hooks for updating

    // begin transaction
    BeforeSave
    BeforeUpdate
    // save before associations
    // update timestamp `UpdatedAt`
    // save self
    // save after associations
    AfterUpdate
    AfterSave
    // commit or rollback transaction

Code Example:

    func (u *User) BeforeUpdate() (err error) {
        if u.readonly() {
            err = errors.New("read only user")
        }
        return
    }

    // Updating data in same transaction
    func (u *User) AfterUpdate(tx *gorm.DB) (err error) {
        if u.Confirmed {
            tx.Model(&Address{}).Where("user_id = ?", u.ID).Update("verfied", true)
        }
        return
    }

## Deleting an object
Available hooks for deleting

    // begin transaction
    BeforeDelete
    // delete self
    AfterDelete
    // commit or rollback transaction

Code Example:

    // Updating data in same transaction
    func (u *User) AfterDelete(tx *gorm.DB) (err error) {
        if u.Confirmed {
            tx.Model(&Address{}).Where("user_id = ?", u.ID).Update("invalid", false)
        }
        return
    }

## Querying an object
Available hooks for querying

    // load data from database
    // Preloading (eager loading)
    AfterFind

Code Example:

    func (u *User) AfterFind() (err error) {
        if u.MemberShip == "" {
            u.MemberShip = "user"
        }
        return
    }