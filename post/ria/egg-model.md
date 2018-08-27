# egg model

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

Use:

    await this.ctx.model.Users.findOne({ userName, password });

## sqlite,mysql,postgre
plugin.js

    exports.sequelize = {
        enable: true,
        package: 'egg-sequelize'
    }

see:
https://github.com/eggjs/egg-sequelize