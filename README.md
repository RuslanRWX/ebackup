
<html>
# backup
Start with:<br>
	-backup       - Incremental backup<br>
	-backup-full  - Full backup<br>
	-status       - Show status<br>
	-check        - Check backup, returns 0 - everything's OK, 1 - something's wrong  (for zabbix)<br>
	-check-l      - Check last backup<br>
	-clean        - Clean backup files<br>
	-backup-mysql - Start mysqldump and send to backup server<br>
	-mysql-check  - Start mysqlcheck<br>
	-mysql-dump   - Start only mysqldump ( without sending backup file to backup server)<br>
	-command      - Execute remote command on backup server, example:./backup/backup.sh -command "ls -al"<br>
	-com          - Same as -command, example:./backup.sh -com "cd ~/niroo; ls -al"<br>
	-ssh-keygen   - Create authentication key<br>
	-configure    - Configure or reconfigure your config file<br> 
	-rotate       - Rotate log files<br>


files.txt -- file with directorys to backup 
files.exclude.txt  -- file with exclude directories 
exclude.mysqldb.txt  -- script backuping all of databases but you can exclude some databases
<html>
