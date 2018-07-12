# JSON
## serial json

    JSON.stringify(xiaoming, null, '  ');
    JSON.stringify(xiaoming, null, 2);


第二个参数，控制如何筛选对象的键值，第三个参数控制缩进

    JSON.stringify(xiaoming, ['name', 'skills'], '  ');
    JSON.stringify(xiaoming, s=>s.toUpperCase(), '  ');

toJSON 控制序列行为: 

    var xiaoming = {
        name: '小明',
        age: 14,
        toJSON: function () {
            return { // 只输出name和age，并且改变了key：
                'Name': this.name,
                'Age': this.age
            };
        }
    };

    JSON.stringify(xiaoming); // '{"Name":"小明","Age":14}'

## Parse

    var obj = JSON.parse('{"name":"小明","age":14}', function (key, value) {
        if (key === 'name') {
            return value + '同学';
        }
        return value;
    });
    console.log(obj); // {name: '小明同学', age: 14}