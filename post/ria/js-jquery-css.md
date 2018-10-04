---
title: Css
date: 2018-10-04
---
# Css

## ClassName

	.addClass(ClassName);
	.hasClass(ClassName);
	.removeClass(ClassName);
	.removeClass();//all
	.toggleClass(ClassName);

## Css Attribute

	.css(propertyname); //return Attribute value
	.css(propertyname, value); //set Attribute value
	.css(propertyname, value); //set Attribute value
	.css({'k1':'v1', 'k2':'v2'}); //set Attribute value
    div.css('color', ''); // 清除CSS属性

## size

	node.width() ;//不包括内边距、边框或外边距）。
	height()
	innerWidth() //包括padding
	innerHeight()
	outerWidth() //包括border. outerWidth(true)则包括border & margin
	outerHeight()

# 效果

其中： callback 是当动画100% 完成后，才执行

## hide

	node.hide()
	node.show()
	node.toggle()

## 淡入/淡出

### fadeIn

	node.fadeIn(speed, callback)
		speed:
			null
			'slow'/'fast'
			3000 //3000ms
		callback:
			function(){....} //没有参数

### fadeOut

	node.fadeOut(speed, callback)

### fadeToggle

	node.fadeToggle(speed, callback)

### fadeTo
$(selector).fadeTo(speed,opacity,callback);
	opacity: 透明度
		0~1

## slide滑动
	$(selector).slideDown(speed,callback);
	$(selector).slideUp(speed,callback);
	$(selector).slideToggle(speed,callback);

## animation动画
必选的css属性. css3也有相应的动画效果: -webkit-animation: myAnimation speed;

    //callback 一般用来恢复原状态
	$(selector).animate({params},speed,callback);
		params:
			{left:'250px',
				height:'+=150px',//相对值
				marginLeft:'10px' //必须使用 Camel 标记法书写所有的属性名，比如，必须使用 paddingLeft 而不是 padding-left，使用 marginRight 而不是 margin-right，等等。
			}

## 串行动画promise

    // 动画效果：slideDown - 暂停 - 放大 - 暂停 - 缩小
    div.slideDown(2000)
    .delay(1000)
    .animate({
        width: '256px',
        height: '256px'
    }, 2000)
    .delay(1000)
    .animate({
        width: '128px',
        height: '128px'
    }, 2000);

## stop
停止动画/淡入淡出

	$(selector).stop(stopAll,goToEnd);
		stopAll:
			default:false
			false/true;//是否清除所有动画队列
		goToEnd:
			default:false
			false/true;//是否立即完成当前动画

## 动画没有效果
因为jQuery动画的原理是逐渐改变CSS的值
1. 很多不是block性质的DOM元素，对它们设置height根本就不起作用
2. jQuery没实现background-color的动画效果，可以使用CSS3的transition