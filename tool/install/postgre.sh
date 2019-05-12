# postgresql
rpm -Uvh https://yum.postgresql.org/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
yum install postgresql10-server postgresql10 -y
# Create a new PostgreSQL database cluster:
/usr/pgsql-10/bin/postgresql-10-setup initdb

systemctl start postgresql-10.service
systemctl enable postgresql-10.service
brew services start postgresql
brew postgresql-upgrade-database

## user
sudo -u postgres psql -c 'create user yd'
sudo -u postgres psql -c ' \password yd'

# auth
grep -P '^host' /var/lib/pgsql/10/data/pg_hba.conf |grep '0.0.0.0/0' || echo 'host    all             all             0.0.0.0/0               md5' >>  /var/lib/pgsql/10/data/pg_hba.conf 

## ip port
grep -P "^listen_addresses='*'" /var/lib/pgsql/10/data/postgresql.conf || cat <<'MM' >> /var/lib/pgsql/10/data/postgresql.conf
listen_addresses='*'
port=5432
MM


systemctl restart postgresql-10.service
