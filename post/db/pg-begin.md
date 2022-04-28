---
title: postgreal 
date: 2021-10-28
private: true
---
# help commmand
    Help
    \? [commands]          show help on backslash commands
    \? options             show help on psql command-line options
    \? variables           show help on special variables
    \h [NAME]              help on syntax of SQL commands, * for all commands

    \sf[+]  FUNCNAME       show a function's definition
    \df[anptw][S+] [PATRN] list [only agg/normal/procedures/trigger/window] functions
    \dF[+]  [PATTERN]      list text search configurations

# Pg display

    \h help
    \x vertical display
    \c show connected to database and user 

# Pg performance
https://blog.crunchydata.com/blog/five-tips-for-a-healthier-postgres-database-in-the-new-year

1. Set a statement timeout
    1. ALTER DATABASE mydatabase SET statement_timeout = '60s';
1. Ensure you have query tracking
CREATE EXTENSION pg_stat_statements;
2. Log slow running queries
3. Improve your connection management(connection pool )
4. Find your goldilocks range for indexes
