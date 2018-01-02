# Fabric
Refer: https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/0014323392805925d5b69ddad514511bf0391fe2a0df2b0000

## install Fabric
pip3 install fabric3

## ssh password
1. interactive:
```s
    -I, --initial-password-prompt
    $ fab -I task
```
2. password within code:
```python
    from fabric import env
    env.hosts = ['user1@host1:port1', 'host2']
    env.passwords = {'user1@host1:port1': 'password1', 'host2': 'password2'}
    env.password = 'passwd' # 共用相同密码
```
3. password via shell args:
    `fab -p PASSWORD`
4. via ssh authorized:
    ` /usr/bin/ssh-copy-id [-i [~/.ssh/id_rsa.pub ]] [user@]machine `

For more: `fab -h`
```s
    -f PATH, --fabfile=PATH 
        default is fabfile.py
```

## fabfile.py
### Config
```python
# fabfile.py
import os, re
from datetime import datetime

# 导入Fabric API:
from fabric.api import *

# 服务器登录用户名:
env.user = 'michael'
# sudo用户为root:
env.sudo_user = 'root'
# 服务器地址，可以有多个，依次部署:
env.hosts = ['192.168.0.3']

# 服务器MySQL用户名和口令:
db_user = 'www-data'
db_password = 'www-data'
```

### local
执行本地命令打包:
1. local('mkdir new_path')
2. lcd/cd: change local/remote path

```python
_TAR_FILE = 'dist-awesome.tar.gz'
def build():
    includes = ['static', 'templates', 'transwarp', 'favicon.ico', '*.py']
    excludes = ['test', '.*', '*.pyc', '*.pyo']
    local('rm -f dist/%s' % _TAR_FILE)
    with lcd(os.path.join(os.path.abspath('.'), 'www')):
        cmd = ['tar', '--dereference', '-czvf', '../dist/%s' % _TAR_FILE]
        cmd.extend(['--exclude=\'%s\'' % ex for ex in excludes])
        cmd.extend(includes)
        local(' '.join(cmd))
```
运行一下：
```s
$ fab build
$ fab -f fabfile.py build
```

### remote work
1. run(cmd), 
2. sudo(cmd)
2. put(localfile, remote_path)
3. cd(remote_new_path)

```python
_REMOTE_TMP_TAR = '/tmp/%s' % _TAR_FILE
_REMOTE_BASE_DIR = '/srv/awesome'

def deploy():
    newdir = 'www-%s' % datetime.now().strftime('%y-%m-%d_%H.%M.%S')
    # 删除已有的tar文件:
    run('rm -f %s' % _REMOTE_TMP_TAR)
    # 上传新的tar文件:
    put('dist/%s' % _TAR_FILE, _REMOTE_TMP_TAR)
    # 创建新目录:
    with cd(_REMOTE_BASE_DIR):
        sudo('mkdir %s' % newdir)
    # 解压到新目录:
    with cd('%s/%s' % (_REMOTE_BASE_DIR, newdir)):
        sudo('tar -xzvf %s' % _REMOTE_TMP_TAR)
    # 重置软链接:
    with cd(_REMOTE_BASE_DIR):
        sudo('rm -f www')
        sudo('ln -s %s www' % newdir)
        sudo('chown www-data:www-data www')
        sudo('chown -R www-data:www-data %s' % newdir)
    # 重启Python服务和nginx服务器:
    with settings(warn_only=True):
        sudo('supervisorctl stop awesome')
        sudo('supervisorctl start awesome')
        sudo('/etc/init.d/nginx reload')
```
