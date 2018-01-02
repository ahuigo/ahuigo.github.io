# Example
https://github.com/andreiz/php-zookeeper/blob/master/examples/Zookeeper_Example.php

    $zk = new Zookeeper('ip:port,ip:port/path');
    $brokersPath = '/brokers/ids';
    $ids = $zk->getChildren($brokersPath);
    //$res = $zk->get($node);
    $brokers = array();
    foreach ($ids as $id) {
         $path = $brokersPath . "/{$id}";
         $val = $zk->get($path);
         $val = json_decode($val, true);
         $brokers[] = $val['host'] . ":" . $val['port'];
    }
