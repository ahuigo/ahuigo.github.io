---
title: gorm model
date: 2021-04-02
private: true
---
# gorm model
https://gorm.io/docs/models.html#embedded_struct

    // gorm.Model definition
    type Model struct {
      ID        uint           `gorm:"primaryKey"`
      CreatedAt time.Time
      UpdatedAt time.Time
      DeletedAt gorm.DeletedAt `gorm:"index"`
    }

## Field-Level Permission
GORM allows you to change the field-level permission with tag, so you can make a field to be read-only, write-only, create-only, update-only or ignored

    type User struct {
      Name string `gorm:"<-:create"` // allow read and create
      Name string `gorm:"<-:update"` // allow read and update
      Name string `gorm:"<-"`        // allow read and write (create and update)
      Name string `gorm:"<-:false"`  // allow read, disable write permission
      Name string `gorm:"->"`        // readonly (disable write permission unless it configured )
      Name string `gorm:"->;<-:create"` // allow read and create
      Name string `gorm:"->:false;<-:create"` // createonly (disabled read from db)
      Name string `gorm:"-"`  // ignore this field when write and read with struct
    }

## Creating/Updating Time/Unix (Milli/Nano) Seconds Tracking
GORM use CreatedAt, UpdatedAt to track creating/updating time by convention, and GORM will set the current time when creating/updating if the fields are defined

To use fields with a different name, you can configure those fields with tag autoCreateTime, autoUpdateTime

    type User struct {
      CreatedAt time.Time // Set to current time if it is zero on creating
      UpdatedAt int       // Set to current unix seconds on updaing or if it is zero on creating
      Updated   int64 `gorm:"autoUpdateTime:nano"` // Use unix nano seconds as updating time
      Updated   int64 `gorm:"autoUpdateTime:milli"`// Use unix milli seconds as updating time
      Created   int64 `gorm:"autoCreateTime"`      // Use unix seconds as creating time
    }

## Embedded Struct
For a normal struct field, you can embed it with the tag embedded, for example:

    type Author struct {
      Name  string
      Email string
    }

    type Blog struct {
      ID      int
      Author  Author `gorm:"embedded"`
      Upvotes int32
    }
    // equals
    type Blog struct {
      ID    int64
      Name  string
      Email string
      Upvotes  int32
    }

And you can use tag embeddedPrefix to add prefix to embedded fields’ db name, for example:

    type Blog struct {
      ID      int
      Author  Author `gorm:"embedded;embeddedPrefix:author_"`
      Upvotes int32
    }
    // equals
    type Blog struct {
      ID          int64
      AuthorName  string
      AuthorEmail string
      Upvotes     int32
    }