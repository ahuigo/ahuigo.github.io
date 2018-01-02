---
layout: page
title:
category: blog
description:
---
# Preface

# Installation with Composer


	composer require pda/pheanstalk

# Usage Example

	<?php

	// Hopefully you're using Composer autoloading.

	use Pheanstalk\Pheanstalk;

	$pheanstalk = new Pheanstalk('127.0.0.1');

	// ----------------------------------------
	// producer (queues jobs)

	$pheanstalk
	  ->useTube('testtube')
	  ->put("job payload goes here\n");

	// ----------------------------------------
	// worker (performs jobs)

	$job = $pheanstalk
	  ->watch('testtube')
	  ->ignore('default')
	  ->reserve();

	echo $job->getData();

	$pheanstalk->delete($job);

	// ----------------------------------------
	// check server availability

	$pheanstalk->getConnection()->isServiceListening(); // true or false

# Running the tests

There is a section of the test suite which depends on a running beanstalkd at 127.0.0.1:11300, which was previously opt-in via --with-server. Since porting to PHPUnit, all tests are run at once. Feel free to submit a pull request to rectify this.

	# ensure you have Composer set up
	$ wget http://getcomposer.org/composer.phar
	$ php composer.phar install

	$ ./vendor/bin/phpunit
	PHPUnit 4.0.19 by Sebastian Bergmann.

	Configuration read from /Users/pda/code/pheanstalk/phpunit.xml.dist

	................................................................. 65 / 83 ( 78%)
	..................

	Time: 239 ms, Memory: 6.00Mb

	OK (83 tests, 378 assertions)
