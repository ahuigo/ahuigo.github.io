---
title: egg model
date: 2018-10-04
---
# egg model
https://eggjs.org/zh-cn/tutorials/sequelize.html

1.config/plugin.js 中引入 egg-sequelize 插件

    $ npm install --save egg-sequelize mysql2
    exports.sequelize = {
        enable: true,
        package: 'egg-sequelize'
    }


2.在 config/config.default.js 中编写 sequelize 配置

    config.sequelize = {
        dialect: 'mysql',
        host: '127.0.0.1',
        port: 3306,
        database: 'egg-sequelize-doc-default',
    };

## mongo model
app/model/users.js example

    "use strict";
    module.exports = (app) => {
        const mongoose = app.mongoose;
        return mongoose.model('Users', new mongoose.Schema({
            userName: String,
            password: String,
            sex:String,//性别
            name:String,//姓名
            isAdmin:Boolean,//是否是管理员
        }, {
            versionKey: false,
            timestamps: true
        }));
    };

Use(注意大写`Users`！！):

    await this.ctx.model.Users.findOne({ userName, password });

sqlite,mysql,postgre 类似

## curd

### create insert
    db.owners.create({  
      name: 'Loren',
      role: 'admin'
    })
    .then(newUser => {
      console.log(`New user ${newUser.name}, with id ${newUser.id} has been created.`);
    });

### update:

    db.pets.findOne({  
      name: 'Max'
    })
    .then(pet => {
      pet.updateAttributes({
        name: 'Maxy-boi-boi'
      });
    });

等价

    const newData = {  
      name: 'Maxy-boi-boi'
    };
    
    db.pets.update(newData, {where: { name: 'Max' } })  
    .then(updatedMax => {
      console.log(updatedMax)
    })

### delete

    db.pets.destory({  
      where: { name: 'Max' }
    })
    .then(deletedPet => {
      console.log(`Has the Max been deleted? 1 means yes, 0 means no: ${deletedPet}`);
    });

see:
https://github.com/eggjs/egg-sequelize