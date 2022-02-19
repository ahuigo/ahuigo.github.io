---
title: anti sniffer 反爬虫
date: 2022-02-19
private: true
---
# anti sniffer反爬虫

## 字体反爬
### ttf 替换
选择一些比较重要的汉字或字符， 替换成 `&#xed12`之类的编码

    <div style="font-family:'cfont';src:url('font.ttf')">
        你&#xed12谁？
    </div>

为这些编码字符制作相应的字体`font.ttf`. 选择的字体不要太多，否则ttf文件过大

破解: 
1. 通过fonttools（python工具）将ttf文件转成ttx文件(xml), 找到编码对应的unicode

改进：
1. 放弃unicode编码，采用非字符编码或自定义编码
1. 将字体作变形，增加图像识别难度
## 将文字换成图片
1. 变形、扭曲

## 验证码
人机验证+ip限制

## 
