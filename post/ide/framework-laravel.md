---
layout: page
title:	laravel 使用
category: blog
description: 
---
# Preface
最近在看一款优雅的php 框架 —— laravel, 做个小结。

# install

	composer create-project laravel/laravel learnlaravel5 5.0.22
	├── app
	├── bootstrap
	├── config
	├── database
	├── public
	├── resources
	├── storage
	├── tests
	└── vendor

# Config
- config 包含了配置项，而大部分配置项位于Config/app 目录:
- .env 配置了开发与线上环境的环境变量，它会覆盖`$_ENV`变量

## env

	//在Application 中获取当前环境
	$environment = $app->environment();//develepment,local,product

## 项目命令空间
项目默认的命名是`App`, 你可以通过以下命令修改默认的命名空间, 比如`Blog`:

	php artisan app:name Blog

## config/app.php

	debug => env('APP_DEBUG'), //.env
	'aliases' => [
		'App' => 'Illuminate\Support\Facades\App',

## 查看当前

# Route
查看路由文件 `app/Http/routes.php` 的代码：

	Route::get('/', 'WelcomeController@index');

	Route::get('home', 'HomeController@index');

	Route::controllers([
		'auth' => 'Auth\AuthController',
		'password' => 'Auth\PasswordController',
	]);

我们在`app/Http/routes.php` 的末尾添加以下代码：

	Route::group(['prefix' => 'admin', 'namespace' => 'Admin'], function()
	{
	  Route::get('/', 'AdminHomeController@index');
	});

这表示创建了一个路由组。

1. `'prefix' => 'admin'` 表示这个路由组的 url 前缀是 /admin，也就是说中间那一行代码 `Route::get('/'` 对应的链接不是 http://fuck.io:88/ 而是 http://fuck.io:88/admin ，如果这段代码是 `Route::get('fuck'` 的话，那么 URL 就应该是 http://fuck.io:88/admin/fuck 。

2. `'namespace' => 'Admin'` 表示下面的 `AdminHomeController@index` 不是在 `\App\Http\Controllers\AdminHomeController@index` 而是在 `\App\Http\Controllers\Admin\AdminHomeController@index`，加上了一个命名空间的前缀

# Controllers
使用 Artisan 非常方便地构建控制器：

	php artisan make:controller Admin/AdminHomeController

得到 `learnlaravel5/app/Http/Controllers/Admin/AdminHomeController.php` 文件。

在 `class AdminHomeController extends Controller {` 上面增加一行：

	use App\Page;

修改 index() 的代码如下：

	public function index() {
	  return view('AdminHome')->withPages(Page::all());
	}

控制器中文文档：http://laravel-china.org/docs/5.0/controllers


# DB
`.env`，打开这个文件，编辑下面四项，修改为正确的信息：

	DB_HOST=localhost
	DB_DATABASE=laravel5
	DB_USERNAME=root
	DB_PASSWORD=password

`config/database.php`:

	'unix_socket'=> '/tmp/mysql.sock',

创建数据库迁移：

	php artisan migrate

# Model
[深入Eloquent ORM](http://lvwenhan.com/laravel/421.html)， 运行一下命令：

	php artisan make:model Article
	php artisan make:model Page

`database/migrations/` 下改 ***_create_articles_table.php ：

	Schema::create('articles', function(Blueprint $table) {
		$table->increments('id');
		$table->string('title');
		$table->string('slug')->nullable();
		$table->text('body')->nullable();
		$table->string('image')->nullable();
		$table->integer('user_id');
		$table->timestamps();
	});

然后执行：

	php artisan migrate

## seed 数据填充
`database/seeds/` 下新建 `PageTableSeeder.php` 文件，内容如下：

	use Illuminate\Database\Seeder;
	use App\Page;

	class PageTableSeeder extends Seeder {

	  public function run() {
		DB::table('pages')->delete();

		for ($i=0; $i < 10; $i++) {
		  Page::create([
			'title'   => 'Title '.$i,
			'slug'    => 'first-page',
			'body'    => 'Body '.$i,
			'user_id' => 1,
		  ]);
		}
	  }

	}

然后修改同一级目录下的 `DatabaseSeeder.php`中：

	// $this->call('UserTableSeeder');
	这一句为
	$this->call('PageTableSeeder');

然后运行命令进行数据填充：

	composer dump-autoload
	php artisan db:seed

# config
/app/config 下

	Config::set('database.default', 'sqlite');
	Config::get('app.timezone');

app/config/local 也环境名同名


# debug
laravel 的debug 模式在`.env`

	APP_DEBUG=true

# 生命周期
	bootstrap/start.php applications
		Foundation/start.php
			$app->booted()	
					app/start/global.php
						log
						app/filter
							App::before after finish shutdown
					app/start/local.php 环境
					app/start/routes.php
					artisan.php
	$app->run
		StackedHttpKernel->handle
			Illuminate\Cookie\Guard->handle
				Illuminate\Cookie\Queue->handle
					Illuminate\Session\Middleware->handle
						$app->handle()->boot->bootApplication->fireAppCallbacks
