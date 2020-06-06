---
title: Rails model
date: 2020-06-05
private: true
---
# Rails model
## select
    User.where(:id => session[:user]).where("status IN ('active', 'confirmed', 'suspended')").first

## save
    if not user.save
        logger.error 'save error'

    user.save! #如果保存不成功就 异常

## delete
    user.destroy
    User.find(15).destroy
    User.destroy(15)
    User.where(age: 20).destroy_all
    User.destroy_all(age: 20)