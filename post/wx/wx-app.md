---
title: Wx app
date: 2018-10-04
---
# Wx app

# Page.js
    page({
        data:{
            latitue:..
            longitude:..
        },
        onload:(options)=>{
            this.setData({options:options, latitude:xx})
        },
        onReady:..
    })

## wx.showToast({title:xx,icon:'loading'})