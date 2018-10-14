
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


