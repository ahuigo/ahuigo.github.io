---
title: syncronous function
date: 2018-10-04
---
# syncronous function 
    function gen(){
        $count = 0;
        $arg1 = 'xx';
        return function() use($arg1, &$count){
            $count++;
        }
    }