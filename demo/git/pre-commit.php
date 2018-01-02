#!/usr/bin/php
<?php
$fileList = `git diff-index --cached --name-only --diff-filter=ACMR HEAD|grep '\.php$'`;
$errors = '';
foreach(explode("\n", $fileList) as $file){
	if(trim($file)){
		$error = `php -l "$file" 2>&1 | grep "Parse error" `;
		if($error){
			$errors .= $error;
		}
	}
}
if(empty($errors)){
	exit(0);//成功(0 是没有错误)，就提交
}else{
	echo "$errors";
	exit(1);//失败，就不提交
}
