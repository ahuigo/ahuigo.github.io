
# Time

## yesterday
http://se2.php.net/manual/en/datetime.formats.relative.php

    $today              = strtotime('00:00:00');
    $today              = strtotime('00:00');
    $today              = strtotime('0:0');
    $yesterday          = strtotime('-1 day', $today);

modifier:

    $hour = 12;
    $today              = strtotime("today $hour:00");
    $yesterday          = strtotime("yesterday $hour:00");
    $dayBeforeYesterday = strtotime("yesterday -1 day $hour:00");

php7

    $today = new \DateTime();
    $yesterday = (clone $today)->modify('-1 day');
    $dayBefore = (clone $yesterday)->modify('-1 day');

## timestamp

### get

	time(viod);//get current timestamp
	getlastmod(void);// 返回当前php文件的modifier timestamp

### mktime

	mktime($hours,$minutes,$secs,$month, $day, $year); //make timestamp
	strtotime('-2 days');
	strtotime('Next Monday');

### strtotime
last week:

	today is 10151106 Friday
	echo date("Ymd", strtotime("last monday"));
		20151102
	echo date("Ymd", strtotime("last week"));
		20151026

last day of last month:
first day of last month:

	echo date("Ymd", strtotime('-1 month', strtotime('20160531')));
		20160501
	echo date("Ymd", strtotime("last day of last month", strtotime('20160531')));
		20160401
	echo date("Ymd", strtotime("first day of last month", strtotime('20160531')));
		20160430

## locale

	setlocal(LC_ALL, 'zh_CN.utf8');

## date

	date('Y-m-d')
	echo date('Y-m-d', strtotime('+2 days'));

## DateTime
> http://wulijun.github.io/php-the-right-way/#date_and_time

	$date = new DateTime;
	$date = DateTime::createFromFormat('d.m.Y','13.7.1999');

	echo $date->format('Y-m-d H:i:s');

计算时间一般需要DateInterval 类，.add .sub 都使用其作为参数, .diff 返回的值就是DateInterval：
Refer to [DateInterval](http://jp2.php.net/manual/zh/dateinterval.construct.php)

	$start = new DateTime();
	// create a copy of $start and add one month and 6 days
	$end = clone $start;
	$end->add(new \DateInterval('P1M6D'));

	$diff = $end->diff($start);
	echo "Difference: " . $diff->format('%m month, %d days (total: %a days)') . "\n";

## gettimestamp

	DateTime::createFromFormat('Y年m月d日','2015年8月9日').getTimestamp()

## checkdate

	function validateDate($date, $format = 'Y-m-d H:i:s') {
		$d = DateTime::createFromFormat($format, $date);
		return $d && $d->format($format) == $date;
	}
