---
title: postgresql connect
date: 2020-07-30
private: true
---
# postgresql 中断connect
postgresql drop db有时报:

    ERROR:  database "pilot" is being accessed by other users
    DETAIL:  There is 1 other session using the database.

解决方法是：https://stackoverflow.com/questions/17449420/postgresql-unable-to-drop-database-because-of-some-auto-connections-to-db

You can prevent future connections:

    REVOKE CONNECT ON DATABASE <thedb> FROM public;
    (and possibly other users/roles; see \l+ in psql)

You can then terminate all connections to this db except your own:

    SELECT pid, pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = current_database() AND pid <> pg_backend_pid();

You'll now be able to drop the DB.

    drop database <thedb>

After you're done dropping the database, restore the access

    GRANT CONNECT ON DATABASE <thedb> TO public;