# backup
Start with:
	-backup       - Incremental backup
	-backup-full  - Full backup
	-status       - Show status
	-check        - Check backup, returns 0 - everything's OK, 1 - something's wrong  (for zabbix)
	-check-l      - Check last backup
	-clean        - Clean backup files
	-backup-mysql - Start mysqldump and send to backup server
	-mysql-check  - Start mysqlcheck
	-mysql-dump   - Start only mysqldump ( without sending backup file to backup server)
	-command      - Execute remote command on backup server, example:./backup/backup.sh -command "ls -al"
	-com          - Same as -command, example:./backup.sh -com "cd ~/niroo; ls -al"
	-ssh-keygen   - Create authentication key  
	-configure    - Configure or reconfigure your config file 
	-rotate       - Rotate log files

