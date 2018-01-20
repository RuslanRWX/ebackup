
### backup.sh 
backup.sh - is a simple backup script for Linux or FreeBDS OS systems using shell (sh). 

Ability: 
   - Full backup file system 
   - Incremental backup file system 
   - Check status and status  for zabbix monitoring 
   - Dumping mysql and mongodb 
   - Send command to the remote backup server for example you can inspect your backup files    
   - Easy to configure 
   - keeping log and rotate it
   - More features you can see by following command ./backup.sh -help     


```
./backup.sh -help
Start with:
	-backup       - Incremental backup
	-backup-full  - Full backup
	-status       - Show status
	-check        - Check backup, returns 0 - everything's OK, 1 - something's wrong  (for zabbix)
	-check-l      - Check last backup
       	-check-rsync  - Check rsync errors, return 0 - everthing Ok, 1 - something wrong (for zabbix)
	-check-rsync-l - Check rsync errors, full errors
	-clean        - Clean backup files
	-backup-mysql - Start mysqldump and send to a backup server
	-mysql-check  - Start mysqlcheck
	-mysql-dump   - Start only mysqldump ( without sending a backup file to a backup server)
	-command      - Execute remote command on a backup server, example:./backup/backup.sh -command "ls -al"
	-com          - Same as -command, example:./backup.sh -com "cd ~/niroo; ls -al"
	-ssh-keygen   - Create authentication key
	-configure    - Configure or reconfigure your config file 
	-rotate       - Rotate log files
```

files.txt -- the file with directories to backup

files.exclude.txt  -- the file with exclude directories 

exclude.mysqldb.txt  --the script backup all of databases but you can exclude some of it

