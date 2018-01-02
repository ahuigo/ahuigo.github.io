# log

    /var/log/mariadb/mariadb.log

## Plugin 'InnoDB' init function returned error

    InnoDB: Error: checksum mismatch in data file ./ibdata1
    160707 23:30:14 InnoDB: Could not open or create data files.
    160707 23:30:14 InnoDB: If you tried to add new data files, and it failed here,
    160707 23:30:14 InnoDB: you should now edit innodb_data_file_path in my.cnf back
    160707 23:30:14 InnoDB: to what it was, and remove the new ibdata files InnoDB created
    160707 23:30:14 InnoDB: in this failed attempt. InnoDB only wrote those files full of
    160707 23:30:14 InnoDB: zeros, but did not yet use them in any way. But be careful: do not
    160707 23:30:14 InnoDB: remove old data files which contain your precious data!
    160707 23:30:14 [ERROR] Plugin 'InnoDB' init function returned error.
    160707 23:30:14 [ERROR] Plugin 'InnoDB' registration as a STORAGE ENGINE failed.
    160707 23:30:14 [Note] Plugin 'FEEDBACK' is disabled.
    160707 23:30:14 [ERROR] Can't open the mysql.plugin table. Please run mysql_upgrade to create it.
    160707 23:30:14 [ERROR] Unknown/unsupported storage engine: InnoDB
    160707 23:30:14 [ERROR] Aborting

soloved:

    [mysqld]
    innodb_data_file_path=ibdata1:50M;ibdata2:50M:autoextend

The full syntax for a data file specification includes the file name, its size, and several optional attributes:

    file_name:file_size[:autoextend[:max:max_file_size]]
    innodb_data_home_dir =
    innodb_data_file_path = /ibdata/ibdata1:10M:autoextend

Suppose that this data file, over time, has grown to 988MB. Below is the configuration line after adding another auto-extending data file:

    innodb_data_home_dir =
    innodb_data_file_path = /ibdata/ibdata1:988M;/disk2/ibdata2:50M:autoextend
