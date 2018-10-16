
## ebackup.sh is an easy backup script for Linux/Unix OS   

- [Introduction](#introduction)
- [Description](#description)

Action:
1. [Installation](#1-installation)\s\s
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



### 1.1 Before installation 

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
### 1.2 Clone project from GitHub repository: 

>Note: Create a directory where you want to store script, for example in your home directory:
```bash cd & mkdir bin & cd bin```  

Git clone:
```bash
git clone https://github.com/ruslansvs2/ebackup.git 
```

### 1.3 Go to directory and list files
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

### 3.1 ebackup.conf 
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
|dbbackuppath      | Path to a directory storage for database backup files. Default value:"/var/db-backup/".
|Days              | Amount of days that data will be saved on a backup server.  
|SUFFIX            | Add suffix for a directory name on a backup server where the data will be sore. Default value:\`date +"%Y-%m-%d-%H%M%S"\`. 
|Pid               | Defines a path to the PID file. Default value:"/var/run/ebackup.pid". 
|MySQL             | Sets back up MySQL. The script can back up MySQL databases by using *[mysqldump](#https://dev.mysql.com/doc/refman/en/mysqldump.html)* tool.
|MySQLCheck        | Defines whether to start or not to start a table maintenance utility *[mysqlcheck](#https://dev.mysql.com/doc/refman/en/mysqlcheck.html)*.
|MysqldumpKey      | You can specify *[mysqldump](#https://dev.mysql.com/doc/refman/en/mysqldump.html)* options. Default value:"'--opt  --routines'".
|MongoDB           | Sets backup of MongoDB. If you have MongoDB service, you can set “YES” or "yes" for this variable, but it will work without authentication. You can modify *MongoDump* function in the ebackup.sh file under your specification. 
|Log               | The script logs to its own log file. This variable defines path and file name for logs. Default value:"/var/log/ebackup.log".
|rotate            | Defines log rotation. You don’t need configure *[logrotate](#https://linux.die.net/man/8/logrotate)* - log rotation can be done by the script. This function starts first, thus every file contains one iteration of a backup task. Default value:"YES". 
|rotateQu          | Specifies maximum amount of the log files before deleting the excess ones. Default value: 7.


### 3.2 files.txt
*files.txt* defines which files and directories are going to be backed up.
Example:
```
/etc/
/usr/
/var/www/
/home/user/
```
    
### 3.3 files.exclude.txt 
In this file you can exclude some directories. 
Example:
```
/use/share/
/var/www/log/
```

### 3.4. Exclude.mysqldb.txt 
If you set *MySQL* variable to “YES” in the main configuration file (ebackup.conf), script is going to back up all of your databases. You can add name of databases in *exclude.mysqldb.txt* file if you don’t want to back them up. 
Example:
```
information_schema
performance_schema
test 
```
---
## 4. Testing script 

### 4.1 Connection test
To check your configuration, you can use some simple commands, such as: *./ebackup -com “ls -al”*. 
The -com flag sends command to a backup server.   
Look below to see output: 

```
./ebackup.sh -com "ls -al"
total 36
drwxr-xr-x 6 test test 4096 Aug 24 01:19 .
drwxr-xr-x 8 root root 4096 Aug 24 01:16 ..
-rw-r--r-- 1 test test  220 Aug 24 01:16 .bash_logout
-rw-r--r-- 1 test test 4000 Aug 24 01:16 .bashrc
drwx------ 2 test test 4096 Aug 24 01:19 .cache
drwxr-xr-x 4 test test 4096 Aug 24 01:16 .config
drwxr-xr-x 3 test test 4096 Aug 24 01:16 .mozilla
-rw-r--r-- 1 test test  655 Aug 24 01:16 .profile
drwxrwxr-x 2 test test 4096 Aug 24 01:19 .ssh
```

>Note: *ebackup.sh* uses a ssh-client to connect to backup server. You should check connection by the ssh-client if some problem has occurred. 

---
## 5. Features, Examples
See the -help option of *./ebackup.sh*:
```
./ebackup.sh -help

```

### 5.1 Start Backup
The flag *-backup* will start backup process.

```
# ./ebackup.sh -backup 
root     14814  0.0  0.0   4504  1628 pts/0    S+   23:57   0:00 /bin/sh ./ebackup.sh -backup
Start backup
Rotation is YES
Start rotating logs
moving  /var/log/backup.log.6 /var/log/backup.log.7
moving  /var/log/backup.log.5 /var/log/backup.log.6
moving  /var/log/backup.log.4 /var/log/backup.log.5
moving  /var/log/backup.log.3 /var/log/backup.log.4
moving  /var/log/backup.log.2 /var/log/backup.log.3
moving  /var/log/backup.log.1 /var/log/backup.log.2
moving  /var/log/backup.log /var/log/backup.log.1
Start backup Вт окт 2 23:57:04 CEST 2018
sending incremental file list
--link-dest arg does not exist: ../111-Latest
etc/
etc/.pwd.lock
              0 100%    0.00kB/s    0:00:00 (xfr#1, ir-chk=1299/1301)
etc/adduser.conf
          3,028 100%    0.00kB/s    0:00:00 (xfr#2, ir-chk=1298/1301)
```

>Note: It is a default option for backing up your file system.  

### 5.2 Start full backup

```./ebackup.sh -backup-full```

Output should be the same as above. 

### 5.3 Check status
```
./ebackup.sh -status
backup is not running
```

### 5.4 Check status of archives
There are two options: *-check* and *-check-l* ( verbose ) 

*-check* option returns boolean value 0 or 1

>where:
>
>0 - backup is okay 
>
>1 - backup is not okay  

-check-l gives you more information.

Output with error:  
```
./ebackup.sh -check-l  
Error
Need check!
Use: ./ebackup.sh -com "cd ~/enigma; ls -al"
```

It means something is wrong. You have to check your backup files, settings, access etc.   

Output without error: 
```
./ebackup.sh -check-l  
Ok
last backup: 2018-10-03-003617
# date
Sep  4   00:06:40 CEST 2018
```


### 5.5 Check rsync errors
This option has two outputs as well: *-check-rsync*  and *-check-rsync-l* 
Output without error:
```
# ./ebackup.sh -check-rsync-l
``` 
If everything is okay, there is no output 
and
```
# ./ebackup.sh -check-rsync
0
```

Output with error:
```
./ebackup.sh -check-rsync
1
```
```
# ./ebackup.sh -check-rsync-l 
ssh: connect to host 127.0.0.1 port 22: Connection refused
rsync: connection unexpectedly closed (0 bytes received so far) [sender]
rsync error: unexplained error (code 255) at io.c(226) [sender=3.1.1]
ssh: connect to host 127.0.0.1 port 22: Connection refused
ssh: connect to host 127.0.0.1 port 22: Connection refused
```


### 5.6 Cleanup of archives
You can force clean your backup storage by use *-clean* option.
Let’s have a look an example:
```
# date
Wed Oct  3 0:01:26 CEST 2018
./ebackup.sh -com "ls -al  enigma"
drwxr-xr-x 7 test test 4096 Oct  2 23:51 ..
lrwxrwxrwx 1 test test   17 Oct  3 00:36 111-Latest -> 2018-10-03-003617
drwxrwxr-x 3 test test 4096 Oct  2 23:51 2018-10-02-235115
drwxrwxr-x 3 test test 4096 Oct  2 23:57 2018-10-02-235704
drwxrwxr-x 3 test test 4096 Oct  3 00:29 2018-10-03-002936
drwxrwxr-x 3 test test 4096 Oct  3 00:36 2018-10-03-003617
```

enigma is my hostname and directory in the backup server. 

I have changed Days variable in the *ebackup.conf* from 3 to 1. 
```
grep Days ebackup.conf
Days=1
```
And let’s run clean and see what will happen
```
./ebackup.sh -com "ls -al  enigma"
total 24
drwxrwxr-x 6 test test 4096 окт  3 00:01 .
drwxr-xr-x 7 test test 4096 окт  2 23:51 ..
lrwxrwxrwx 1 test test   17 окт  3 00:36 111-Latest -> 2018-10-03-003617
drwxrwxr-x 3 test test 4096 окт  3 00:29 2018-10-03-002936
drwxrwxr-x 3 test test 4096 окт  3 00:36 2018-10-03-003617
  
Folders 2018-10-02-235115 and 2018-10-02-235704 were deleted 
```

>Note: The cleanup always starts after successful backup. 


### 5.7 Backup and Check MySQL
### 5.7.1 Backup MySQL database
The *-backup-mysql* option backs up only [MySQL](#https://www.mysql.com/) database and sends archives to the backup server:

```
./ebackup.sh -backup-mysql
root     28770  0.0  0.0   4504  1636 pts/8    S+   01:11   0:00 /bin/sh ./ebackup.sh -backup-mysql
Start backup
Rotation is YES
Start rotating logs
moving  /var/log/backup.log.6 /var/log/backup.log.7
moving  /var/log/backup.log.5 /var/log/backup.log.6
moving  /var/log/backup.log.4 /var/log/backup.log.5
moving  /var/log/backup.log.3 /var/log/backup.log.4
moving  /var/log/backup.log.2 /var/log/backup.log.3
moving  /var/log/backup.log.1 /var/log/backup.log.2
moving  /var/log/backup.log /var/log/backup.log.1
Start backup Ср окт 3 01:11:14 CEST 2018
Start MySQL Dump and send to backup server
Dumping mysql...Done!
Dumping sys...Done!
Dumping test...Done!
Dumping test01...Done!
sending incremental file list
created directory /home/test/enigma/Processing-2018-10-03-011114
/var/
/var/db-backup/
/var/db-backup/mysql.sql.gz
        256,806 100%    5.62MB/s    0:00:00 (xfr#1, to-chk=3/6)
/var/db-backup/sys.sql.gz
         57,378 100%    1.22MB/s    0:00:00 (xfr#2, to-chk=2/6)
/var/db-backup/test.sql.gz
         10,550 100%  223.97kB/s    0:00:00 (xfr#3, to-chk=1/6)
/var/db-backup/test01.sql.gz
            470 100%    9.77kB/s    0:00:00 (xfr#4, to-chk=0/6)

sent 325,437 bytes  received 173 bytes  651,220.00 bytes/sec
total size is 325,204  speedup is 1.00
Start clean
Finish Ср окт 3 01:11:18 CEST 2018
Log file:  /var/log/backup.log
```

Let’s check:
```
./ebackup.sh -com "ls -al  enigma"
total 44
drwxrwxr-x 11 test test 4096 окт  2 0:01 .
drwxr-xr-x  7 test test 4096 окт  2 23:51 ..
lrwxrwxrwx  1 test test   17 окт  3 00:36 111-Latest -> 2018-10-03-003601

drwxrwxr-x  3 test test 4096 окт  3 00:29 2018-10-03-002936
drwxrwxr-x  3 test test 4096 окт  3 00:36 2018-10-03-003601
drwxrwxr-x  3 test test 4096 окт  3 01:11 2018-10-03-011114-Only-Mysqldump
```

```
./ebackup.sh -com "ls -al  enigma/2018-10-03-011114-Only-Mysqldump/var/db-backup"
total 336
drwxrwxr-x 2 test test   4096 окт  3 01:11 .
drwxrwxr-x 3 test test   4096 окт  3 01:11 ..
-rw-rw-r-- 1 test test 256806 окт  3 01:11 mysql.sql.gz
-rw-rw-r-- 1 test test  57378 окт  3 01:11 sys.sql.gz
-rw-rw-r-- 1 test test    470 окт  3 01:11 test01.sql.gz
-rw-rw-r-- 1 test test  10550 окт  3 01:11 test.sql.gz
```

>Note: */var/db-backup* is a path for database backup directory on the local machine. It defines *dbbackuppath* variable in the main configuration file: 
```
grep dbbackuppath  ebackup.conf
dbbackuppath=/var/db-backup/
```

This way it stores two copies of your data: on the backup server and on a local directory   
Let’s check it:
```
ls -al /var/db-backup/
total 336
drwxr-xr-x  2 root root   4096 окт  3 17:11 .
drwxr-xr-x 14 root root   4096 авг 29 21:31 ..
-rw-r--r--  1 root root 256807 окт  3 01:26 mysql.sql.gz
-rw-r--r--  1 root root  57379 окт  3 01:26 sys.sql.gz
-rw-r--r--  1 root root    473 окт  3 01:26 test01.sql.gz
-rw-r--r--  1 root root  10550 окт  3 01:26 test.sql.gz
```


### 5.7.2 Backup MySQL database without sending data to a backup server 
The *-mysql-dump* option dumps your databases on a local storage (*/var/db-backup* in my case)  

```
./ebackup.sh -mysql-dump
Start MySQL Dump
Dumping mysql...Done!
Dumping sys...Done!
Dumping test...Done!
Dumping test01...Done!
```

### 5.7.3 MySQL Check

The *-mysql-check* option starts *“mysqlcheck -A --repair”*

```
./ebackup.sh -mysql-check
Start MySQL Check
mysql.columns_priv                                 OK
mysql.db                                           OK
mysql.engine_cost
note     : The storage engine for the table doesn't support repair
mysql.event                                        OK
mysql.func                                         OK
```

>Note: Use this option only for MyISAM engine 

### 5.8 Execute command on the remote backup server 
The *-command* or *-com* options send your command to a remote server and execute it.
It’s very useful for debugging and saves time on checking your backup. 
We actively used this option in our examples above. 
```
#./ebackup.sh -com "ls -l"
total 4
drwxrwxr-x 11 test test 4096 Oct  3 02:11 enigma
# ./ebackup.sh -com "touch test_file_for_chapter_5.8"
# ./ebackup.sh -com "ls -l"
total 4
drwxrwxr-x 11 test test 4096 Oct  3 02:11 enigma
-rw-rw-r--  1 test test    0 Oct  3 01:43 test_file_for_chapter_5.8
```


### 5.9 Create ssh-key 

The *-ssh-keygen* option creates "ssh-key* to access the backup server.
You should prepare user’s ssh password. 
Example:
```
./ebackup.sh -ssh-keygen  
	|->  IP backup server  [ 127.0.0.1 ] :
	|->  User for remote server [ test ] :
Generating public/private rsa key pair.
/home/ruslan/.ssh/id_rsa already exists.
Overwrite (y/n)? n
Enter password for test@127.0.0.1
```

### 5.10 Configuration option 
The *-configure* option configures your script in the interactive mode. 
In section 2 this feature is explained 
In section 3 you can learn how to configure script by editing configuration file.

### 5.11. Rotation 
The *-rotation* option handles rotation of the log files. 
```
./ebackup.sh -rotate 
Start rotating logs
moving  /var/log/backup.log.6 /var/log/backup.log.7
moving  /var/log/backup.log.5 /var/log/backup.log.6
moving  /var/log/backup.log.4 /var/log/backup.log.5
moving  /var/log/backup.log.3 /var/log/backup.log.4
moving  /var/log/backup.log.2 /var/log/backup.log.3
moving  /var/log/backup.log.1 /var/log/backup.log.2
moving  /var/log/backup.log /var/log/backup.log.1
```

>Note: if this option is turned on, it always starts before copying file to the remote server.

---
## 6. Troubleshooting 
>Note: Backup user has to have a *Bash* or *sh* command line interpreter for proper behavior:
>```
>./ebackup.sh -com "echo $BASH"
>/bin/bash
>FreeBSD operating system has CSH as a default command line interpreter - this will result in unusual issues.  


### 6.1 Rsync error
 
Some common error:
```
rsync error: some files vanished before they could be transferred (code 24) at main.c(1668) [generator=3.1.2] 
```

Sometimes it could happen when data is changing very fast, especially for databases.


### 6.2 MySQL errors
```
 ./ebackup.sh -backup-mysql
root     27798  0.0  0.0   4504  1640 pts/8    S+   01:08   0:00 /bin/sh ./ebackup.sh -backup-mysql
Start backup
Rotation is YES
Start rotating logs
moving  /var/log/backup.log.6 /var/log/backup.log.7
moving  /var/log/backup.log.5 /var/log/backup.log.6
moving  /var/log/backup.log.4 /var/log/backup.log.5
moving  /var/log/backup.log.3 /var/log/backup.log.4
moving  /var/log/backup.log.2 /var/log/backup.log.3
moving  /var/log/backup.log.1 /var/log/backup.log.2
moving  /var/log/backup.log /var/log/backup.log.1
Start backup Ср окт 3 01:08:21 CEST 2018
Start MySQL Dump and send to backup server
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
sending incremental file list
created directory /home/test/enigma/Processing-2018-10-03-010821
/var/
/var/db-backup/
sent 106 bytes  received 93 bytes  398.00 bytes/sec
total size is 0  speedup is 0.00
Start clean
Finish Ср окт 3 01:08:24 CEST 2018
Log file:  /var/log/backup.log
```
Access denied for user - you have to add permissions to database and configure your ~/.my.cnf file 


