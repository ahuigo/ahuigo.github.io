---
title: eslint 命名
date: 2019-12-26
private: true
---
# eslint 命名
https://cn.eslint.org/docs/rules/camelcase

文件名(类用大camelcase)：

    import Ajax from './Ajax.js'
    ajax = new Ajax()

文件名(其它用小camelcase)：配置、数据...

    import config from './config.ts'

常量：

    A_B

变量

    var myFavoriteColor   = "#112C85";
    var _myFavoriteColor  = "#112C85";

函数/成员函数 都用小驼峰, 前缀是动词

    function getName(){

    }
    get/set
    has/is
    can

类属性：

    //私有
    this._name
    //公共
    this.name
    // 
    this.categoryName


注释：

    /**
    * 说明
    * @param name {String} 传入名称
    * @return {Boolean} true:可执行;false:不可执行
    * @author 作者信息 [附属信息：如邮箱、日期]
    * @author 张三 2015/07/21 
    * @version XX.XX.XX
    */
