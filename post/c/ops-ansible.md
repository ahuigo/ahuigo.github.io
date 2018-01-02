# Ansible
Ansible 是一个比Puppet, Chef 更轻量的provisioning 工具，不需要启动daemon进程。这点跟跟pssh差不多，但是比pssh更加强大。

	$ yum install -y ansible
	$ ansible --version
	  ansible 2.0.0.2
	    config file = /etc/ansible/ansible.cfg
	    configured module search path = Default w/o overrides

# directory
/etc/ansible:

	hosts
	group-vars/

# basic run

	$ ansible all -s -m apt -a 'pkg=nginx state=installed update_cache=true'
	all - Use all defined servers from the inventory file
	-m ping - Use the "ping" module, which simply runs the ping command and returns the results
	-s - Use "sudo" to run the commands
	-k - Ask for a password rather than use key-based authentication
	-u vagrant - Log into servers using user vagrant


# inventory

    -i PATH, --inventory=PATH
       The PATH to the inventory, which defaults to /etc/ansible/hosts.
       Alternatively you can use a *comma separated list* of hosts or single host with traling comma

cat /etc/ansible/hosts

	host0.example.org ansible_host=192.168.33.10 ansible_user=root
	host1.example.org ansible_host=192.168.33.11 ansible_user=root
	host2.example.org ansible_host=192.168.33.12 ansible_user=root

## sshpass

	[all:vars]
	ansible_user=admin


# module
Try ping module

    ansible -m ping all -i step-01/hosts
    ansible -m ping all -u admin

The output should look like this:

    host0.example.org | success >> {
        "changed": false,
        "ping": "pong"
    }

    host1.example.org | success >> {
        "changed": false,
        "ping": "pong"
    }

Modules that take arguments pass them via -a switch. Let's see a few other modules.

## shell module
Shell module

    ansible -i step-02/hosts -m shell -a 'uname -a' host0.example.org

Output should look like:

    host0.example.org | success | rc=0 >>
    Linux host0.example.org 3.2.0-23-generic-pae #36-Ubuntu SMP Tue Apr 10 22:19:09 UTC 2012 i686 i686 i386 GNU/Linux

## Copy module
Lets say we want to copy our /etc/motd to /tmp of our target node:

    ansible -i step-02/hosts -m copy -a 'src=/etc/motd dest=/tmp/' host0.example.org

Output should look similar to:

    host0.example.org | success >> {
        "changed": true,
        "dest": "/tmp/motd",
        "src": "/root/.ansible/tmp/ansible-1362910475.9-246937081757218/motd",
    }

## Many hosts, same command
all is a shortcut meaning 'all hosts found in inventory file'. It would return:

    ansible -i step-02/hosts -m shell -a 'grep DISTRIB_RELEASE /etc/lsb-release' all

## Many more facts: setup
if we wanted more information (ip addresses, RAM size, etc...).

    ansible -i step-02/hosts -m setup host0.example.org

replies with lots of information:

    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.0.60"
        ],
        "ansible_all_ipv6_addresses": [],
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "01/01/2007",
        "ansible_bios_version": "Bochs"
        },
        ---snip---

You may also filter returned keys,let's say you want to know how much memory

    ansible -i step-02/hosts -m setup -a 'filter=ansible_memtotal_mb' all:

    host2.example.org | success >> {
        "ansible_facts": {
            "ansible_memtotal_mb": 187
        },

BTW, when using the setup module, you can use `*` in the `filter=` expression. It will act like a shell glob.

# hosts

## Selecting hosts
We saw that all means 'all hosts', but ansible provides a lot of other ways to select hosts:

1. *host0.example.org:host1.example.org* would run on host0.example.org and host1.example.
2. `host*.example.org` would run on all hosts starting with 'host' and ending with '.example.org'

Pattern：

	:::shell
	ansible <pattern_goes_here> -m <module_name> -a <arguments>

pattern可以直接指定某一机器地址或hosts中的组名，同时指定多个组或者多个ip使用:分割：

	all
	*
	192.168.1.*

	用!表示非：
	v1:!v2   #表示在v1分组中，但是不在v2中的hosts

	用&表示交集部分：
	webservers:&dbservers  #表示在webservers分组中，同时也在dbservers分组中的hosts:w

	v1[0]
	v1[0:100]

	也可以用~开头来使用正则：
	~(web|db).*\.example\.com
	~v\d

## Grouping hosts
Hosts in inventory* can be grouped arbitrarily.

    [debian]
    host0.example.org
    host1.example.org

This can even be expressed shorter:

    [debian]
    host[0:2].example.org

If you wish to use child groups:

    [ubuntu]
    host0.example.org

    [debian]
    host[1:2].example.org

    [linux:children]
    ubuntu
    debian

# Setting variables
You can assign variables to hosts in several places: inventory file, host vars files, group vars files, etc...

When using *ansible-playbook* command , variables can also be set with *--extra-vars (or -e)* command line switch.
ansible-playbook command will be covered in the next step.

    [ubuntu]
    host0.example.org ansible_host=192.168.0.12 ansible_port=2222

Ansible will look for additional variables definitions in group and host variable files.

    group_vars/linux
    group_vars/ubuntu
    host_vars/host0.example.org

Now that we know the basics of modules, inventories and variables, let's explore the real power of Ansible with playbooks.

# Ansible playbooks
Playbook concept is very simple: it's just a series of ansible commands (tasks),
These tasks are targeted at a specific set of hosts/groups.

The necessary files for this step should have appeared magically and you don't even have to type them.

## Apache example (a.k.a. Ansible's "Hello World!")
We assume we have the following inventory file (let's name it hosts):

    [web]
    host1.example.org

Lets build a playbook that will install apache on machines in the web group.

    - hosts: web
      tasks:
        - name: Installs apache web server
          apt: pkg=apache2 state=installed update_cache=true

Here, we're using the apt module that can install debian packages. We also ask this module to update the package cache.

> We also added a name for this task. While this is not necessary, it's very informative when the playbook runs, so it's highly recommended.

You can run the playbook (lets call it *apache.yml*):

    ansible-playbook -i step-04/hosts -l host1.example.org step-04/apache.yml

`-l` limits the run only to *host1.example.org and apache.yml* is our playbook. output:
