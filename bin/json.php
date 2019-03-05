#!/usr/bin/env php
<?php
$json = file_get_contents('php://stdin');
$a =json_decode(trim($json), true);
#var_dump($a);
if($a){
	if(isset($argv[1])){
		print_r($a[$argv[1]]);
	}else
		print_r($a);
}else{
	echo $json;
}
