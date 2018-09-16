# egg model
https://eggjs.org/zh-cn/tutorials/sequelize.html

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

Use(注意大写！！):

    await this.ctx.model.Users.findOne({ userName, password });

## sqlite,mysql,postgre
plugin.js

    exports.sequelize = {
        enable: true,
        package: 'egg-sequelize'
    }

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