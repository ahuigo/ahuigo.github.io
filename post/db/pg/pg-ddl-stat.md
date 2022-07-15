---
title: pg stat
date: 2022-07-12
private: true
---
# sql status
## find running sql
find long runing sql

    SELECT
        pid,
        now() - pg_stat_activity.query_start AS duration,
        query,
        state
    FROM pg_stat_activity
    WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';

    // output 
    pid   |       duration      | query   | state
    31861 | 4days 08:16:37.5026 | SELECT * FROM "dis" | active

If state is `idle` you don’t need to worry about it(they will be cleaned by postgres master)
We should care `active` queries instead of.

## terminate sql
Since we find the pid of long runnning sql, let's kill it:

    // safe
    SELECT pg_cancel_backend(31861);

 After server  seconds of executing this `pg_cancel_backend` command,  if you find the process is stuck, you can kill it by running:

    // Be carefully!
    // it kill with -9 in PostgreSQL. It will terminate the entire process which can lead to a full database restart in order to recover consistency.
    SELECT pg_terminate_backend(31861);


> Note: the `pg_cancel_backend` is safer than `pg_terminate_backend`.



