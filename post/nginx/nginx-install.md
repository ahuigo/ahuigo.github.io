# install

    brew install openresty/brew/openresty

# start
如果想以非deamon 方式启动()：

    //nginx.conf
    daemon off;

或者在命令行中启动

    $ nginx    -p `pwd`/ -c conf/redis.conf -g 'daemon off;'
    $ nginx -s reload   -p `pwd`/ -c conf/redis.conf -g 'daemon off;'