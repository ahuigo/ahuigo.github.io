---
title: js-time
category: blog
date: 2018-10-04
---
# Date Format
> https://zh.wikipedia.org/wiki/ISO_8601

The only format in the spec is a simplified version of ISO-8601:

	2004-05-03T17:30:08+08:00
	2004-05-03T17:30:08; // chomre safari 默认0时区(更大), firefox 则默认是当前东8时区(更小: 这才是准确的)

	2004-05-03T17:30:08+8:00;//invalid date
	2018-03-06T09:30:08.000Z; //忽略时区

If you change the space to a T, you'll be in spec:

	var dateString = "2015-12-31 00:00:00";
	var d = new Date(dateString.replace(' ', 'T'));

# moment
https://github.com/you-dont-need/You-Dont-Need-Momentjs#string--format--locale
moment 一般，date-fns 更好

	moment('20180101').valueOf(); // getTime():
	moment().format('MMMM Do YYYY, HH:mm:ss a'); // January 1st 2018, 10:36:01 pm
	moment().format('YYYY-MM-DD HH:MM:SS');

	moment("20111031", "YYYYMMDD").fromNow(); // 6 years ago
	moment().subtract(10, 'days').calendar(); // 12/22/2017

# date-fns

# timer
You need to give JavaScript a reference to the interval:

	var t = setTimeout(function() {
		timer(counter + 1);
	}, 3000);

Then you can clear it like so:

	$("#stop").click(function () {
	   clearTimeout(t);
	});

## sleep

    async sleep(ms){
        return new Promise(resolve=>setTimeout(resolve, ms))
    }

# Date

## yesterday

	var date = new Date();
	date ; //# => Fri Apr 01 2011 11:14:50 GMT+0200 (CEST)
	date.setDate(date.getDate() - 1);

## get

	$d = new Date("October 13, 1975 11:13:00");
	$d = new Date(miliseconds);

	//date & time
	new Date()		2018-03-06T16:30:28.521Z 非local时间 (node js)
	new Date()		"Mon Apr 28 2014 23:25:02 GMT+0800 (CST)"(chrome)

	Date(); 		"Mon Apr 28 2014 23:25:02 GMT+0800 (CST)"
	.toString(); 	"Mon Apr 28 2014 23:25:02 GMT+0800 (CST)"
	.toUTCString();	"Mon, 28 Apr 2014 15:25:02 GMT" //UTC & GMT 是一样的(除了精度上有区别)
	.toGMTString();	"Mon, 28 Apr 2014 15:25:02 GMT"
	.toLocaleString(); "4/28/2014 11:25:02 PM"

	//date part
	.getDate(); //1~31 getUTCDate()
	.getMonth(); //0~11 getUTCMonth()
	.getFullYear(); //四位数字	getUTCFullYear()
	//day
	.getDay(); //一周中的某天0~6(0是星期天)

	//time part
	.getHours()	返回 Date 对象的小时 (0 ~ 23)。 getUTCHours()
	.getMinutes()	返回 Date 对象的分钟 (0 ~ 59)。	getUTCMinutes()
	.getSeconds()	返回 Date 对象的秒数 (0 ~ 59)。 getUTCSeconds()
	.getMilliseconds()	返回 Date 对象的毫秒(0 ~ 999)。getUTCMilliseconds()

	//unixstimestamp in miliseconds
	.valueOf()
	.getTime()	返回 1970 年 1 月 1 日至今的毫秒数。
	Date.parse("Jul 8, 2005 0:0:32"); //返回指定时间的毫秒数
	.UTC()	根据世界时返回 1970 年 1 月 1 日 到指定日期的毫秒数。

	//unixstimestamp in seconds
	new Date().getTime()/1000 | 0
	+new Date/1000 | 0

short:

	Date.prototype.formatMMDDYYYY = function(){
		return (this.getMonth() + 1) +
				"/" +  this.getDate() +
				"/" +  this.getFullYear();
	}
	Date.prototype.format = function(d){
		var d = this;
        let month = (d.getMonth()+1+'').padStart(2, '0')
        let date = ('0'+d.getDate()).slice(-2)
		return d.getFullYear()+'-' + month+'-' + d.getDate()+' ' + d.getHours()+':' + d.getMinutes()+':' + d.getSeconds()+''
	}
    (new Date()).format()

## compare

	d1 > d2

## set

	//day
	.setDate()	设置 Date 对象中月的某一天 (1 ~ 31)。

	//Month
	.setMonth()	设置 Date 对象中月份 (0 ~ 11)。

	//Year
	.setFullYear()	设置 Date 对象中的年份（四位数字）。 setYear()	使用 setFullYear() 方法代替。

	//Hours & Minutes & Seconds
	.setHours()	设置 Date 对象中的小时 (0 ~ 23)。
	.setMinutes()	设置 Date 对象中的分钟 (0 ~ 59)。
	.setSeconds()	设置 Date 对象中的秒钟 (0 ~ 59)。
	.setMilliseconds()	设置 Date 对象中的毫秒 (0 ~ 999)。

	//add time
	d.setSeconds(d.getSeconds() + 10);

    /**
    years	y
    quarters	Q
    months	M
    weeks	w
    days	d
    hours	h
    minutes	m
    seconds	s
    milliseconds	ms
    */
	Date.prototype.unitWeight = {
        ms:1,
        s:1000,
        m:60000,
        h:3600000,
        d:86400*1000,
        M:30*86400*1000,
        y:365*86400*1000,
    }
	Date.prototype.add = function(n, unit='s'){
        let weight = this.unitWeight[unit]
		this.setTime(this.getTime() + (n* weight));
		return this;
	}
	Date.prototype.diff = function(d, unit='s'){
        let weight = this.unitWeight[unit]
		return (this.getTime() - d.getTime())/weight;
	}

	// unix timestamp
	.setTime(millisec)	以毫秒设置 Date 对象。d.setTime(77771564221)
	new Date(millisec)	以毫秒设置 Date 对象. new Date(77771564221)

str to time

	new Date("October 13, 1975 11:13:00");
	new Date("2016-01-01 11:13:00");
	new Date("2016-01-01 11:13:00");
	new Date("2016-06-03") === new Date(2016, 05,04,00,00,00);

	(new Date("2016-1-1")).getDay();

UTC to miliseconds

	Date.UTC(1970, 9, 21)