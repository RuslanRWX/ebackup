
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
	-backup       - Incremental backup<br>
	-backup-full  - Full backup<br>
	-status       - Show status<br>
	-check        - Check backup, returns 0 - everything's OK, 1 - something's wrong  (for zabbix)<br>
	-check-l      - Check last backup<br>
       	-check-rsync  - Check rsync errors, return 0 - everthing Ok, 1 - something wrong (for zabbix)<br>
	-check-rsync-l - Check rsync errors, full errors<br>
	-clean        - Clean backup files<br>
	-backup-mysql - Start mysqldump and send to a backup server<br>
	-mysql-check  - Start mysqlcheck<br>
	-mysql-dump   - Start only mysqldump ( without sending a backup file to a backup server)<br>
	-command      - Execute remote command on a backup server, example:./backup/backup.sh -command "ls -al"<br>
	-com          - Same as -command, example:./backup.sh -com "cd ~/niroo; ls -al"<br>
	-ssh-keygen   - Create authentication key<br>
	-configure    - Configure or reconfigure your config file<br> 
	-rotate       - Rotate log files<br>
```

files.txt -- the file with directories to backup
files.exclude.txt  -- the file with exclude directories 
exclude.mysqldb.txt  --the script backup all of databases but you can exclude some of it

