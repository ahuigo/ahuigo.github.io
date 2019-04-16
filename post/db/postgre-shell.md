---
title: shell pg
date: 2019-04-15
private:
---
# shell pg


## execute sql file

    $ psql db -f sql.sql >/dev/null

# pager
vi ~/.psqlrc(pg shell)

    \pset pager off

bash shell:

    psql -P pager=off <other params>



