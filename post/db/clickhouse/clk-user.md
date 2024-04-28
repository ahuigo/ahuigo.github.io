---
title: clickhoust user
date: 2024-02-02
private: true
---
# clickhoust user

    GRANT SELECT(timestamp, env, serviceName, httpCode, count) ON mydb.mytable TO 'user1';

# permission
## grant privilege/role to user/role
    GRANT  privilege[(column_name [,...])]  ON {db.table|db.*|*.*|table|*} TO {user | role | CURRENT_USER} ;
    GRANT  role [,...] TO {user | another_role | CURRENT_USER} 

## grant ALL
    GRANT ALL ON *.* TO default WITH GRANT OPTION
    GRANT ALL ON mydb.* TO default WITH GRANT OPTION
    GRANT ALL ON mydb.mytable TO user1;

## grant table
    GRANT SELECT(timestamp, env, serviceName, httpCode, count) ON mydb.mytable TO 'user1'