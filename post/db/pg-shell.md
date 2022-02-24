---
title: shell pg
date: 2019-04-15
private:
---
# shell pg
    psql -U ahui db2 -c 'select * from ahui;'

## execute sql file

    $ psql db < sql.sql 
    $ psql -U username dbname -f sql.sql >/dev/null
    $ cat sql.sql | psql db 


# pipe
## copy: save file

    COPY tablename TO '/tmp/output.csv' DELIMITER ',' CSV HEADER;
    \copy (select name,date_order from purchase_order) to '/home/ankit/Desktop/result.csv' cvs header;

## pipe to file
    db=>\o out.txt
    db=>\dt
    db=> select * from t
    db=> select * from t2

    db=>\o out2.txt
    db=>\o -- 不带参数，表示停止写


# pager
vi ~/.psqlrc 或 pg shell:

    \pset pager off

bash shell:

    psql -P pager=off <other params>



