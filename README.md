
## ebackup.sh is an easy backup script for Linux/Unix OS   

- [Introduction](#introduction)
- [Description](#description)

Action:
1. [Installation](#installation)
    - [Before installation](#biforeinstallation)
    - [Clone project from Github repository](#)
    - [Go to directory and list files](#)
2. [Configuration by using the script](#)
3. [Configuration by redact a configuration file](#)
   - [ebackup.conf](#)
   - [files.txt](#)
   - [files.exclude.txt](#) 
   - [exclude.mysqldb.txt](#) 
4. [Testing script](#)
   - [Test to proper connect](#)
5. [Featches](#) 
   - [Start backup](#)
   - [Start full backup](#)
   - [Check status](#)
   - [Check status of archives](#)
   - [Check rsync errors](#)
   - [Clean](#)
   - [Backup and check MySQL](#)
6. [Backup](#backup)
   - [Backup without sent data to a backup server](#) 
   - [MySQL Check](#)
   - [Execute command on the remote backup server](#) 
   - [Configuration option](#) 
   - [Rotation](#) 
7. [Troubleshooting](#trableshooting) 
   - [Rsync error](#)
   - [Error mysql](#)
   - [SSH error](#) 


##Introduction

The *ebackup.sh* is an easy backup script written in Shell (sh) for Linux/Unix operating systems. The ebackup is easy for configuration and installing. The source of script is broken into functions, therefore, you can add your own function without a big effort. 

##Description
The *ebackup.sh* is created based on Rsync and should be installed on machines that you want to back up. The *ebackup.sh* is connected to a remote backup server through SSH, therefore, you need access to some user and that user has to have command-line interpreter. For working properly, command-line interpreter have to be SH or Bash. For example, default shell on FreeBSD could be csh, in that case the *ebackup.sh* script wouldn’t work as expected. 


>Note: I highly recommend use sh or bash on a remote backup server.

 
Abilities:
 - Full backup of file system
 - Incremental backup of file system
 - Check of backup status
 - Dumping of MySQL and MongoDB
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
## Installation



#### Before installation 

>Note: You have to have a remote backup server to store your archives.


You should install Git if you haven’t yet.
For  Debian-based distribution, such as Debian, Ubuntu, try apt:
```bash
apt update && apt install git
```

For RHEL-based distribution, such as CentOS, Red Hat, Fedora, try yum:
```bash
yum install git 
```

>Note: If you haven’t got backup server, the simplest way to deal with this problem is to get a backup service with SSH access,  https://host4.biz/ru/hosting/backup-hosting or other backup hosting provider.   
Limit count of backup copies depends on a storage capacity on the remote backup server.


Now start installation and configuration 
#### Clone project from GitHub repository: 

>Note: Create a directory where you want to store script, for example in your home directory:
```bash cd & mkdir bin & cd bin```  

Git clone:
```bash
git clone https://github.com/ruslansvs2/ebackup.git 
```



