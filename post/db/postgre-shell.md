---
title: shell pg
date: 2019-04-15
private:
---
# shell pg


## execute sql file

    $ psql db -f sql.sql >/dev/null
    $ psql db < sql.sql 
    $ cat sql.sql | psql db 

# pager
vi ~/.psqlrc(pg shell)

    \pset pager off

bash shell:

    psql -P pager=off <other params>



