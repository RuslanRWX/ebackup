
## ebackup.sh is an easy backup script for Linux/Unix OS   

- [Introduction](#introduction)
- [Description](#description)

Action:
1. [Installation](#1-installation)

    1.1 [Before installation](#11-before-installation)
    
    1.2 [Clone project from Github repository](#)
    
    1.2 [Go to directory and list files](#)
2. [Configuration by using the script](#)
3. [Edit the main configuration file](#)
   
   3.1 [ebackup.conf](#)
   
   3.2 [files.txt](#)
   
   3.3 [files.exclude.txt](#) 
   
   3.4 [exclude.mysqldb.txt](#) 
4. [Testing script](#)
   4.1 [Test to proper connect](#)
5. [Featches](#) 
   
   5.1 [Start backup](#)
   
   5.2 [Start full backup](#)
   
   5.3 [Check status](#)
   
   5.4 [Check status of archives](#)
   
   5.5 [Check rsync errors](#)
   
   5.6 [Clean](#)
   
   5.7 [Backup and check MySQL](#)
6. [Backup](#backup)
   
   6.1 [Backup without sent data to a backup server](#) 
   
   6.2 [MySQL Check](#)
   
   6.3 [Execute command on the remote backup server](#) 
   
   6.4 [Configuration option](#) 
   
   6.5 [Rotation](#) 
7. [Troubleshooting](#trableshooting) 
- [Rsync error](#)
- [Error mysql](#)
- [SSH error](#) 


## Introduction

The *ebackup.sh* is an easy backup script written in Shell (sh) for Linux/Unix operating systems. The ebackup is easy for configuration and installing. The source of script is broken into functions, therefore, you can add your own function without a big effort. 

## Description
The *ebackup.sh* is created based on Rsync and should be installed on machines that you want to back up. The *ebackup.sh* is connected to a remote backup server through SSH, therefore, you need access to some user and that user has to have command-line interpreter. For working properly, command-line interpreter have to be SH or Bash. For example, default shell on [FreeBSD](#https://www.freebsd.org/) could be csh, in that case the *ebackup.sh* script wouldn’t work as expected. 


>Note: I highly recommend use sh or bash on a remote backup server.

 
Abilities:
 - Full backup of file system
 - Incremental backup of file system
 - Check of backup status
 - Dumping of [MySQL](#https://www.mysql.com/) and [MongoDB](#https://www.mongodb.com/)
 - Execution of commands on a remote backup server
 - Logging output and rotating log files.

You can see more features by following command: 
```bash
Start with:
	-backup       - Incremental backup
	-backup-full  - Full backup
	-status       - Show status
	-check        - Check backup, return 0 - everything OK, 1 - something wrong  (for zabbix)
	-check-l      - Check last backup
	-check-rsync  - Check rsync errors, return 0 - everthing Ok, 1 - something wrong (for zabbix) 
	-check-rsync-l - Check rsync errors, full errors
	-clean        - Clean backup files
	-backup-mysql - Start mysqldump and send to a backup server
	-mysql-check  - Start mysqlcheck
	-mysql-dump   - Start only mysqldump ( without sending a backup files to a backup server)
	-command      - Execute remote command on a backup server, example:/home/ruslan/ruslan/BUILD.git/ebackup/ebackup.sh -command "ls -al"
	-com          - Same as -command, example:/home/ruslan/ruslan/BUILD.git/ebackup/ebackup.sh -com "cd ~/enigma; ls -al"
	-ssh-keygen   - Create authentication key  
	-configure    - Configure or reconfigure your config file 
	-rotate       - Rotate log files

ebackup.conf - configuration file
files.txt - the file defines directories that you want to bacup
files.exclude.txt - the file defines exclude directories
exclude.mysqldb.txt - the script backups all of a databases but you can exclude some of it

```


---
## 1. Installation



#### 1.1 Before installation 

>Note: You have to have a remote backup server to store your archives.


You should install [Git](#https://git-scm.com/) if you haven’t yet.
For  [Debian-based](#https://www.debian.org/) distribution, such as Debian, Ubuntu, try apt:
```bash
apt update && apt install git
```

For [RHEL-based](#https://www.redhat.com/) distribution, such as CentOS, Red Hat, Fedora, try yum:
```bash
yum install git 
```

>Note: If you haven’t got backup server, the simplest way to deal with this problem is to get a backup service with SSH access,  https://host4.biz/ru/hosting/backup-hosting or other backup hosting provider.   
Limit count of backup copies depends on a storage capacity on the remote backup server.


Now start installation and configuration 
#### 1.2 Clone project from GitHub repository: 

>Note: Create a directory where you want to store script, for example in your home directory:
```bash cd & mkdir bin & cd bin```  

Git clone:
```bash
git clone https://github.com/ruslansvs2/ebackup.git 
```

#### 1.3 Go to directory and list files
```bash
cd ebackup && ls -la
-rw-r--r--  1 ruslan ruslan   768 Aug 25 23:21 ebackup.conf
-rwxrwxr-x  1 ruslan ruslan 13380 Aug 25 23:27 ebackup.sh
-rw-r--r--  1 ruslan ruslan    38 Nov 26  2014 exclude.mysqldb.txt
-rw-r--r--  1 ruslan ruslan    20 Nov 26  2014 files.exclude.txt
-rw-r-----  1 ruslan ruslan    18 Nov 26  2014 files.txt
-rw-rw-r--  1 ruslan ruslan  1156 Nov 24  2014 .my.cnf
-rw-rw-r--  1 ruslan ruslan  1686 Nov 20  2018 README.md
-rw-rw-r--  1 ruslan ruslan  5323 Nov 19  2017 zbx_export_templates.xml
```

The directory contains eight files:

ebackup.sh - backup script.
ebackup.conf - main configuration file.
files.txt - the file which defines directories that you want to back up.
files.exclude.txt - the file which defines excluded directories.
exclude.mysqldb.txt - the script backs up all of a databases. However, in this file you can exclude some of them.
Zbx_export_templates.xml - Zabbix template file.

---
## 2. Configuration by using the script  
With the following command you should configure your *ebackup.sh* script. You can also configure it by editing the *ebackup.conf* file:

```
#./ebackup.sh  -configure
Start configuration. You can see your backup configuration file after that
	|->  IP or domain of backup server: 127.0.0.1
	|->  User for a remote backup server: test
	|->  How many days you want to keep the backup files ?:[15] 3
	|->  Do you want to configure :[YES] yes
		|->  This output of df -h command can help you choose a storage for databases backup:
Filesystem      Size  Used Avail Use% Mounted on
udev            3,9G     0  3,9G   0% /dev
tmpfs           790M   19M  772M   3% /run
/dev/sda2        19G   15G  3,3G  82% /
tmpfs           3,9G   31M  3,9G   1% /dev/shm
tmpfs           5,0M  4,0K  5,0M   1% /run/lock
tmpfs           3,9G     0  3,9G   0% /sys/fs/cgroup
/dev/sda3       199G  139G   51G  74% /home
/dev/sda1       188M  3,4M  184M   2% /boot/efi
cgmfs           100K     0  100K   0% /run/cgmanager/fs
tmpfs           790M   52K  790M   1% /run/user/1000
	|->  Backup path for MySQL dump :[/var/db-backup/] 
	|->  Do you want to start mysqlcheck before dumping:[NO] no
	|->  Would you like to configure access to MySQL? (~/.my.cnf):[YES] yes
create my.cnf
User for mysqldump [root]: root
Password for user: test
Port default [3306]: 
Host default [localhost]: 
We have saved your old .my.cnf file, you can find it there: ~/.my.cnf.back
	|->  Do you want to back up MongoDB:[NO] 
	|->  Do you want to create ssh-key?:[YES] 
ssh-key is YES
Generating public/private rsa key pair.
/home/ruslan/.ssh/id_rsa already exists.
Overwrite (y/n)? n
Enter password for test@127.0.0.1
test@127.0.0.1's password: 
        |->  Do you want to create backup cron task?:[YES] y
Cron task job is y
Each line of a crontab file represents a job, and looks like this::
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of the month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
│ │ │ │ │                                   7 is also Sunday on some systems)
│ │ │ │ │
│ │ │ │ │
* * * * * 
Add job to the crontab file (/etc/crontab), enter a timestamp in cron format, default [1 1 * * *]: 
Success !!!
````
You will find it in /etc/crontab

```
tail -1 /etc/crontab
1 1 * * * root /home/user/ebackup/ebackup.sh -backup >> /dev/null 2>&1
```
 
Now let’s have a closer look at the configuration process.  

```|-> IP or domain of backup server: 127.0.0.1```  - In this step, you have to add your remote backup server  
You can specify IP or hostname of backup server. In my example, I added localhost as a remote backup server.
 
```|->  User for remote server: test``` -  username witch exists on a remote backup server that you have access to. 

```|-> How many days you want to keep the backup files ?:[15] 3``` - In this step, you should define how many copies you want to keep on a backup server.


```|->  Do you want to configure a MySQL backup:[YES] yes```  - if you have a [MySQL](#https://www.mysql.com/) server, you can back up your databases using this script. The script uses *[mysqldump](#https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html)* client utility, its parameters you can configure in configuration file. The answer should be “yes” or “YES”. 

```This output of df -h command can help you choose a storage for databases backup:``` - This output can help you choose a directory for backup databases.

```Backup path for MySQL dump :[/var/db-backup/]``` - choose a directory for MySQL dump files 

```Do you want to start mysqlcheck before dumping:[NO] no ``` - This can be useful for MyISAM data storage engine. If you don’t use it then leave the parameter as NO.

```Would you like to configure access to MySQL? (~/.my.cnf):[YES] yes```  --  You can configure access to MySQL server on the fly. You have to be prepared input username and password of a MySQL user. If you had a local configuration file ~/.my.cnf for mysql-client it will be saved as ~/.my.cnf.back.  

```Do you want to back up MongoDB:[NO]  ``` - If you have *[MongoDB](#https://www.mongodb.com/)*, you can back up databases by setting this parameter to YES. The script will be using a *[mongodump](#https://docs.mongodb.com/manual/reference/program/mongodump/)* tool to create a backup.  

```Do you want to create ssh-key?:[YES]``` - This step is a little bit specific, you can create *ssh-key* for having access to a remote backup server. You need to be prepared to input user’s password of the remote backup server. If you already have *ssh-key*, the script will ask you to overwrite it: 

```/home/ruslan/.ssh/id_rsa already exists.
Overwrite (y/n)? n
```
I didn’t want to lose my key. After that, the script will add your public key to the remote backup server. 

```Do you want to create backup cron task?:[YES]  y ``` - In this last question, the script can add the backup task to your cron.   

```Add job to the crontab file (/etc/crontab), enter a timestamp in cron format, default [1 1 * * *]: ```- set your proper time to back up.  


You can now check all the settings in the main configuration file: 

```bash

#cat ebackup.conf 
# Copyright (c) 2014 Ruslan Variushkin,  email:ruslan@host4.biz
#
###################################### Version 2.2.4 #######################################################
# Directory on backup server
dir=`hostname`
# Backup server 
bksrv=127.0.0.1
# User on backup server
bkusr=test
# SSH port
Port=22
# Path for mysqldump
dbbackuppath=/var/db-backup/
# Number of days of keeping backups  
Days=3
# Suffix for backup file
SUFFIX=`date +"%Y-%m-%d-%H%M%S"`
# File pid 
Pid=/var/run/backup.pid
# Dump mysql YES|NO
MySQL=yes
# Mysqlcheck and repair (only for MyISAM)
MySQLCheck=NO
# Mysqldump Keys 
MysqldumpKey='--opt  --routines'
# Dump MongoDB
MongoDB=no
# Log file
Log=/var/log/backup.log
# Rotation of log files YES|NO 
rotate=YES
# Number of logs to keep
rotateQu=7
```
---
## 3. Edit the main configuration file 

#### 3.1 ebackup.conf 
Let’s have a look at the *ebackup.conf* file and edit it.
>Note: In section 2 we showed how to make changes in this file in interactive mode by using -configure flag (./ebackup.sh -configure). You can use this way if it is easier for you. 

Use vim or other command line editor to make changes.
```
vim ebackup.conf 
```

| Variable         | Description                                                                                                                                     |                  
|----------------- |-----------------------------------------------------------------------------------------------------------------------------------------------  |
|dir               | Defines a directory name that will be stored in a backup server. By default option, it will be an output of the *hostname* command. Default value:\`hostnmae\`.            
|bksrv             | Defines the real hostname or IP address of a remote backup server. In my case, it is a localhost, but I highly recommend using a remote storage.
|bkusr             | Specifies a user to access remote server.  
|Port              | Sets the ssh port to connect to remote backup server. Default value: 22.
|dbbackuppath      | Path to a directory storage for database backup files. Default value:/var/db-backup/.
|Days              | Amount of days that data will be saved on a backup server.  
|SUFFIX            | Add suffix for a directory name on a backup server where the data will be sore. Default value:\`date +"%Y-%m-%d-%H%M%S"\` 
|Pid               | Defines a path to the PID file. Default value:/var/run/ebackup.pid
|MySQL             | Sets back up MySQL. The script can back up MySQL databases by using *[mysqldump](#https://dev.mysql.com/doc/refman/en/mysqldump.html)* tool.
|MySQLCheck        | Defines whether to start or not to start a table maintenance utility *[mysqlcheck](#https://dev.mysql.com/doc/refman/en/mysqlcheck.html)*.
|MysqldumpKey      | You can specify *[mysqldump](#https://dev.mysql.com/doc/refman/en/mysqldump.html)* options. Default value:'--opt  --routines'
|MongoDB           | Sets backup of MongoDB. If you have MongoDB service, you can set “YES” or "yes" for this variable, but it will work without authentication. You can modify *MongoDump* function in the ebackup.sh file under your specification. 
|Log               | The script logs to its own log file. This variable defines path and file name for logs.Default value:/var/log/ebackup.log.
|rotate            | Defines log rotation. You don’t need configure *[logrotate](#https://linux.die.net/man/8/logrotate)* - log rotation can be done by the script. This function starts first, thus every file contains one iteration of a backup task. Default value:YES 
|rotateQu          | Specifies maximum amount of the log files before deleting the excess ones. Defauld value: 7

