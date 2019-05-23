---
title: react framework
date: 2019-05-23
---
# react framework
前端框架优化
KISS 原则:
1. 解耦：正交原则
2. KISS原则: 
   1. 可复用
   2. 组件化（UI、类库）
3. 调试: 测试
4. 高性能：
   1. 性能瓶颈
   2. 

## 文件结构

    src/
        conf/                   提供各种配置
            global.js 
        util/   非UI工具库
            file/
                mfile.js    文件库：提供文件下载、上传、格式转换
            geo/            geo 库
                geoosm.js   提供
                ...
            http.js         提供xhr/fetch 基础功能支持
                支持多种格式：json, osm/geojson, form-data
                支持辅助error提示: 依赖error 的ui 组件
        api/
            momenta-client.js
        components/               UI 工具库
            notice.jsx            通知组件
            table.jsx
        api/
            task.js
        store/      

        views/
            hr/             人力资源管理:
                staff       人员CRUD 
                staff-role  角色管理: 作业人员、运营人员、管理人员
                role-auth   权限管理: 每种角色的权限
            devices/        设备管理
                千寻帐号、OTA、设备状态、密钥管理 ....
            production/     生产管理:骨架线、地理围栏、任务、统计
                skeleton    骨架线管理
                workorder   任务CRUD及管理:
                external-task/              外页任务
                    external-manager        外页任务：创建、领取、展示
                    external-monitor        外页数据监控
                    external-statistic      外页数据分析
            data-colletion/             数据采集
                upload-monitor     数据上传监控            
                
                可用性和
                        资料调用
                        推荐信息展示
                        历史建图展示
            workorder   任务CRUD

            

## css 加载



## 编码规范
使用 Airbnb React 规范 
https://github.com/airbnb/javascript/tree/master/react

## 渐近式重构
不支持的功能: 

    console.warn('XXXX module is deprecated')

## 组件
### table 组件

## 脚手架

## 测试
单元测试 jasmine
UI 测试 
