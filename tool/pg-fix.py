import subprocess
import re

PORT = 5432
TABLENAME = 'table_name'
DBNAME = 'dbname'
def getBadIdViaVacuum():
    print("ViaVacuum analyze ....")
    cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres  {DBNAME} -p {PORT} -c "VACUUM analyze {TABLENAME}"'
    print(cmd)
    code, out = subprocess.getstatusoutput(cmd)
    # ERROR:  uncommitted xmin 1471825177 from before xid cutoff 1875544701 needs to be frozen

    m = re.search(r'xmin (\d+)', out)
    if not m:
        return
    xmin=m.group(1)

    cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres  {DBNAME} -p {PORT} -c "select id from {TABLENAME} where xmin={xmin}"'
    print(cmd)
    code, out = subprocess.getstatusoutput(cmd)
    print(out, type(out))
    # ERROR:  uncommitted xmin 1471825177 from before xid cutoff 1875544701 needs to be frozen

    m = re.search(r'(\d+)', out)
    return (m.group(1))

def checkBadId(i,j):
    if i+1>=j:
        return i
    m = (i+j)//2
    cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c "select * from {TABLENAME} order by id limit {j-m} offset {m}" > /dev/null ||  echo "error" '
    cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c "select * from {TABLENAME} where id<{j} and id>={m}" > /dev/null ||  echo "error" '
    print(cmd)
    code, out = subprocess.getstatusoutput(cmd)
    if 'missing chunk number 0' in out:
        return checkBadId(m,j)
    else:
        return checkBadId(i,m)

def getBadId():
    for i in range(0, 200*2):
        j = i*5000
        cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c "select * from {TABLENAME} where id>={j} and id<{j+5000}" > /dev/null ||  echo "error" '
        print(cmd)
        code, out = subprocess.getstatusoutput(cmd)
        if 'missing chunk number 0' in out:
            print("checkbad Id:", j,j+5000)
            Id = checkBadId(j, j+5000)
            print("bad Id:", Id)
            return Id
    # ERROR:  uncommitted xmin 1471825177 from before xid cutoff 1875544701 needs to be frozen

    #m = re.search(r'(\d+)', out)
    #return (m.group(1))


def fixId(Id):
    cmd = f"psql -h prod-pg.hdmap.mmtdev.com -U postgres  {DBNAME} -p {PORT} -c 'update {TABLENAME} set private_key='\\''none'\\'' where id={Id}'"
    code, out = subprocess.getstatusoutput(cmd)
    print(out, type(out))

def delDuplicatedId(Id):
    cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c "select updated_at from {TABLENAME} where check_id=\'{Id}\'"'
    print(cmd)
    code, out = subprocess.getstatusoutput(cmd)
    print(out, type(out))
    m=re.search(r'2020-.+\+08', out)
    if m:
        updated_at =  m.group(0)
        cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c "delete from {TABLENAME} where check_id=\'{Id}\' and updated_at=\'{updated_at}\' "'
        code, out = subprocess.getstatusoutput(cmd)
        print(out)

def reindexTable():
    # redinxe table
    while True:
        break
        cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c "REINDEX table {TABLENAME}" > /dev/null ||  echo "error" '
        code, out = subprocess.getstatusoutput(cmd)
        print(out)
        m=re.search(r'\(([^\)]+)\) is duplicated.', out)
        if m:
            Id =  m.group(1)
            delDuplicatedId(Id)
        else:
            break

    # reindex pg_toast
    print('reindex pg_toast')
    cmd = f"psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c 'select reltoastrelid::regclass from pg_class where relname='\\''{TABLENAME}'\\' "
    code, out = subprocess.getstatusoutput(cmd)
    print('reidnex toast1:',out)

    m = re.search(r'pg_toast.pg_toast_(\d+)', out)
    if m:
        pg_toast = (m.group(0))
        cmd = f'psql -h prod-pg.hdmap.mmtdev.com -U postgres {DBNAME} -p {PORT} -c "REINDEX table {pg_toast}" '
        print(cmd)
        code, out = subprocess.getstatusoutput(cmd)
        print('reidnex toast2',out)


def fixIds():
    #reindexTable()
    while True:
        print('start fix....')
        #Id = getBadIdViaVacuum()
        Id = getBadId()
        if not Id:
            break;
        else:
            print(f'fix id: {Id}')
            quit()
            fixId(Id)

fixIds()
