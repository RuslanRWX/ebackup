
### ebackup.sh 

- [Introduction](#introduction)
- [Description](#description)

Action:
1. [Installation](#installation)

1.1 [Before installation](#bifore installation)

1.2 [Clone project from Github repository](#)

1.3 [Go to directory and list files](#)
2. Configuration by using the script
3. Configuration by redact a configuration file
3.1 ebackup.conf
3.2 files.txt 
3.3 files.exclude.txt 
3.4. exclude.mysqldb.txt 
           4. Testing script
4.1 Test to proper connect
           5. Featches 
5.1 Start backup  ( incremental in case exist backup )
5.2 Start full backup
5.3 Check status
5.4 Check status of archives
5.5 Check rsync errors
5.6 Clean
5.7 Backup and check MySQL
5.7.1 Backup
5.7.2 Backup without sent data to a backup server 
5.7.3 MySQL Check
                     5.8 Execute command on the remote backup server 
5.10 Configuration option 
5.11. Rotation 
6. Troubleshooting 
6.1 Rsync error
6.2 Error mysql
6.3 SSH error 
