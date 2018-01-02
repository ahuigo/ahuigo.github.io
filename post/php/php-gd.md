---
layout: page
title:	php gd
category: blog
description: 
---
# Preface

# GD

	<?php
	header("Content-type: image/png");
	$im = @imagecreate(100, 50)
		or die("Cannot Initialize new GD image stream");
	$background_color = imagecolorallocate($im, 255, 255, 255);
	$text_color = imagecolorallocate($im, 233, 14, 91);
	imagestring($im, 1, 5, 5,  "A Simple Text String", $text_color);
	imagepng($im);
	imagedestroy($im);
	?>

## png 

	header("Content-type: image/png");
	$string = $_GET['text'];
	$im     = imagecreatefrompng("images/button1.png");
	$orange = imagecolorallocate($im, 220, 210, 60);
	$px     = (imagesx($im) - 7.5 * strlen($string)) / 2;
	imagestring($im, 3, $px, 9, $string, $orange);
	imagepng($im);
	imagedestroy($im);

