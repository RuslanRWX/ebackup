#!/bin/sh
# Copyright (c) 2014 Ruslan Variushkin,  email:ruslan@host4.biz
#
###################################### Version 2.2.4 #######################################################
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/local/ssl/bin
checkr=$(whereis rsync | grep bin | awk -F":" '{ print $2 }')
if [ "$checkr" = "" ]; then { echo "ERROR: You should install rsync!"; exit 1;  } fi
Path=$( cd "$( dirname "$0" )" && pwd )
. $Path/ebackup.conf

trap "rm $Pid; exit" 1 2 15
#logger -i $Pid
os=$(uname)
if [ "$os" = "FreeBSD" ]; then { download="fetch"; }; fi
if [ "$os" = "Linux" ]; then { download="wget"; } fi

createmycnf() { 
	echo "create my.cnf"
	read -p "User for mysqldump [root]: " User
	 : ${User:="root"}
        read -p "Password for user: " Pass
	read -p "Port default [3306]: " Port
	 : ${Port:="3306"}
	read -p "Host default [localhost]: " Host
	 : ${Host:="localhost"}
	if [ -f ~/.my.cnf ];
	 then {
	 mv ~/.my.cnf ~/.my.cnf.back;
	 echo "We have saved your old .my.cnf file, you can find it there: ~/.my.cnf.back"
	 }
	 fi
	sed "s/User/$User/;s/Pass/$Pass/;s/Port/$Port/;s/Host/$Host/" .my.cnf  > ~/.my.cnf
       	cd $Path
}

MySQLCheck() {
    if [ ! -f ~/.my.cnf ]; then { createmycnf;   } fi 
	mysqlcheck -A --repair
}

MySQLDump () {
if [ ! -d $dbbackuppath ]; then { /bin/mkdir -p $dbbackuppath;  } fi 
    if [ ! -f ~/.my.cnf ]; then { createmycnf;   } fi 
    mysql -e "SHOW DATABASES;" | sed '1d'   > /tmp/backup.mysqldb.log
if [ "$os" = "FreeBSD" ]; then { sedkey='-i ""'; }; fi
if [ "$os" = "Linux" ]; then { sedkey='-i'; } fi

    	while  read line
	do
	sed $sedkey "/$line/d"   /tmp/backup.mysqldb.log 
	done < $Path/exclude.mysqldb.txt

    
	while read db
	do
		echo -n "Dumping $db..."
		mysqldump $MysqldumpKey $db | gzip > $dbbackuppath/$db.sql.gz
		echo "Done!"
    	done < /tmp/backup.mysqldb.log
}							


MongoDump () {
    mongodump -o $dbbackuppath/mongo
    tar czf $dbbackuppath/mongodb-backup.tar.gz $dbbackuppath/mongo && rm -r $dbbackuppath/mongo
}

Arsync () {
	Acount=$(ssh -p${Port}  $bkusr@$bksrv "cd ~/$dir; ls -F " | wc -l)
	if [ "$OnlyMysql" = "OnlyM"  ]
	then
		ssh -p${Port}  $bkusr@$bksrv "cd ~/$dir && mv Processing-$SUFFIX $SUFFIX-Only-Mysqldump"
	else
		ssh -p${Port} $bkusr@$bksrv "cd ~/$dir && mv Processing-$SUFFIX $SUFFIX && rm -f 111-Latest && ln -s $SUFFIX 111-Latest"
	fi
if [ "$Acount" -gt "$Days" ]; then { echo "Start clean"; ssh -p${Port}  $bkusr@$bksrv "cd ~/$dir; find . -type d -mtime +$Days -maxdepth 1 -exec rm -r '{}' \;"; } fi
}

StoreBackup () {
ssh -p${Port} $bkusr@$bksrv "if [ ! -d ~/$dir ]; then { /bin/mkdir -p ~/$dir;  } fi"    
    rsync -vbrltz --progress -e "ssh -p${Port}" \
    --no-p --no-g --chmod=ugo=rwX \
    --delete \
    --timeout=600 \
    --ignore-errors \
    --exclude-from="${Path}/files.exclude.txt" \
    --files-from="${Path}/files.txt" \
    / $bkusr@$bksrv:~/$dir/Processing-$SUFFIX
}

	        
StoreBackupInc () {
ssh -p${Port}  $bkusr@$bksrv "if [ ! -d ~/$dir ]; then { /bin/mkdir -p ~/$dir;  } fi"    
    rsync -brltz --progress -e "ssh -p${Port}"  \
    --no-p --no-g --chmod=ugo=rwX \
    --delete \
    --timeout=600 \
    --ignore-errors \
    --exclude-from="${Path}/files.exclude.txt" \
    --link-dest=../111-Latest \
    --files-from="${Path}/files.txt" \
    / $bkusr@$bksrv:~/$dir/Processing-$SUFFIX
}

StoreBackupMysql () {
ssh -p${Port}  $bkusr@$bksrv "if [ ! -d ~/$dir ]; then { /bin/mkdir -p ~/$dir;  } fi"    
    rsync -vbrltz --progress -e "ssh -p${Port}" \
    --no-p --no-g --chmod=ugo=rwX \
    --delete \
    --timeout=600 \
    --ignore-errors \
  -R  $dbbackuppath $bkusr@$bksrv:~/$dir/Processing-$SUFFIX
}

CheckBackup () {
#SURFFIXDump=$(date +'%Y-%m-%d')
SUFFIXDump=$(cat ${Path}/lastback.txt 2>> /dev/null || echo "null" )
ssh -o ConnectTimeout=5 -p${Port}  $bkusr@$bksrv " if [ -d ~/${dir}/${SUFFIXDump} ]; then { echo '0'; } else { echo '1'; } fi" 2>>/dev/null || echo "1"
}

CheckBackupAll () {
SUFFIXDump=$(cat ${Path}/lastback.txt 2>> /dev/null || echo "null" )
ssh -o ConnectTimeout=10 -p${Port}  $bkusr@$bksrv "if [ -d ~/${dir}/${SUFFIXDump} ]; then { echo -e 'Ok\nlast backup: '${SUFFIXDump}; } else { echo -e 'Error\nNeed check!\nUse: ./ebackup.sh -com \"cd ~/$dir; ls -al\"'; } fi" 2>> /dev/null || echo "Error: connect to host "$bksrv 
}

CheckRsync () {
Res=$(grep -i -E  "Disk quota|Broken pipe|rsync error" $Log) 
if [ ! -n "$Res" ]; then  { echo '0'; } else { echo '1'; } fi
}

CheckRsyncl () {
grep  -i -A2 -B2 --color=auto -E "Disk quota|Broken pipe|rsync error" $Log
}

Command () {
ssh -p${Port}  $bkusr@$bksrv "$Com"
}

Clean () {
            echo "start clean"
	    ssh -p${Port}  $bkusr@$bksrv "cd ~/$dir; find . -type d -mtime +$Days -maxdepth 1 -exec rm -r '{}' \;"
	    echo "clean done"
    }

SSHkey () {
	DefIP=$(grep -E 'bksrv=' $Path/ebackup.conf | awk -F'=' '{ print $2 }')
	DefU=$(grep -E 'bkusr=' $Path/ebackup.conf | awk -F'=' '{ print $2 }')
	read -p "	|->  IP backup server  [ $DefIP ] :" IPParm
	: ${IPParm:="$DefIP"}
	read -p "	|->  User for remote server [ $DefU ] :" UserParm
	: ${UserParm:="$DefU"}
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
echo "Enter password for "$UserParm"@"$IPParm
cat ~/.ssh/id_rsa.pub | ssh -p${Port} $UserParm@$IPParm "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
}

Configure () {
cd $Path

IP_def () {
	echo  "Start configuration. You can see your backup configuration file after that"
	read -p "	|->  IP or domain of backup server: " IPParm
	IPold=$(grep -E "bksrv=" $Path/ebackup.conf)
#	if echo $IPParm | grep -v -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then  { echo Bad IP adress; exit 1; } fi
}

User_def () {
	read -p "	|->  User for a remote backup server: " UserParm
	UPold=$(grep -E "bkusr=" $Path/ebackup.conf)
}

Days_def () {
  	 read -p "	|->  How many days you want to keep the backup files ?:[15] " DayParm
	 : ${DayParm:="15"}
	if echo $DayParm | grep -v -E "[0-9]"; then { echo the days parameter must be an integer; exit 1; } fi
	Dayold=$(grep -E  "Days=" $Path/ebackup.conf)
}

MySQL_def () {
	read -p "	|->  Do you want to configure a MySQL backup:[YES] " MysqlParm
	 : ${MysqlParm:="YES"}
}

MySQL_then_def () {
 	         echo  "		|->  This output of df -h command can help you choose a storage for backed up databases :"
	         df -h
	         read -p "	|->  Backup path for MySQL dump :[/var/db-backup/] " PathParm
	         : ${PathParm:="/var/db-backup/"}
	         if [ ! -d $PathParm  ]; then { mkdir $PathParm;  } fi
	         Pold=$(grep -E 'dbbackuppath=' $Path/ebackup.conf )
	         MPold=$(grep -E "MySQL=" $Path/ebackup.conf)
	         read -p "	|->  Do you want to start mysqlcheck before dumping:[NO] " MysqlCParm
	         : ${MysqlCParm:="NO"}
	         MCPold=$(grep -E "MySQLCheck=" $Path/ebackup.conf)
	         read -p "	|->  Would you like to configure access to MySQL? (~/.my.cnf):[YES] " MysqlAccess
	         : ${MysqlAccess:="YES"}
    	     if echo $MysqlAccess |  grep -i -E  "^y$|^yes$|^ye$" >> /dev/null; then { createmycnf; } fi
}

MySQL_else_def () {
	        PathParm="/var/db-backup/"
                Pold=$(grep -E 'dbbackuppath=' $Path/ebackup.conf )
	        MysqlParm="NO"
	        MPold=$(grep -E "MySQL=" $Path/ebackup.conf)
	        MysqlCParm="NO"
	        MCPold=$(grep -E "MySQLCheck=" $Path/ebackup.conf)
}

Mongo_def () {
	read -p "	|->  Do you want to back up MongoDB:[NO] " MongoParm
	 : ${MongoParm:="NO"}
	 Mdbold=$(grep -E  "MongoDB=" $Path/ebackup.conf)
}

SSHkeygen () {
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
echo "Enter password for "$UserParm"@"$IPParm
cat ~/.ssh/id_rsa.pub | ssh -p${Port} $UserParm@$IPParm "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
}

Sshkey_def () {
	read -p "	|->  Do you want to create ssh-key?:[YES] " sshkey
	 : ${sshkey:="YES"}
	 echo ssh-key is $sshkey
     if echo $sshkey | grep -i -E  "^y$|^yes$|^ye$"  >> /dev/null; then { SSHkeygen; } fi
}

Cron_def () {
	read -p "        |->  Do you want to create backup cron task?:[YES] " CronTaskParm
         : ${CronTaskParm:="YES"}
        echo Cron task job is $CronTaskParm
        if echo $CronTaskParm | grep -i -E "^y$|^yes$|^ye$" >> /dev/null; then CronTask; fi
}


CronTask () {
echo "Each line of a crontab file represents a job, and looks like this::
	┌───────────── minute (0 - 59)
	│ ┌───────────── hour (0 - 23)
	│ │ ┌───────────── day of the month (1 - 31)
	│ │ │ ┌───────────── month (1 - 12)
	│ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
	│ │ │ │ │                                   7 is also Sunday on some systems)
	│ │ │ │ │
	│ │ │ │ │
 	* * * * * command to execute    
"
	read -p "Add job to the crontab file (/etc/crontab), enter a timestamp in cron format, default [1 1 * * *]: " CronTaskDate
        : ${CronTaskDate:="1 1 * * *"}
        echo " $CronTaskDate root $Path/ebackup.sh -backup >> /dev/null 2>&1 " >> /etc/crontab
} 
    # determination of parameters
    IP_def
    User_def
    Days_def
    MySQL_def
    	
    if echo  $MysqlParm | grep -i -E "^y$|^yes$|^ye$" >> /dev/null
	 then  MySQL_then_def 
         else  MySQL_else_def 
    fi 
    Mongo_def

    echo $Pold | sed "s/\//\\\\\//g" > /tmp/Pold.txt
    echo $PathParm | sed "s/\//\\\\\//g" > /tmp/PathParm.txt
    Pold=$(cat /tmp/Pold.txt)
    PathParm=$(cat  /tmp/PathParm.txt)
    rm /tmp/Pold.txt
    rm /tmp/PathParm.txt


    if [ "$os" = "FreeBSD" ]; then { sedkey='-i .back'; }; fi
    if [ "$os" = "Linux" ]; then { sedkey='-i.back '; } fi


    sed  $sedkey "s/$IPold/bksrv=$IPParm/; s/$UPold/bkusr=$UserParm/; s/$Pold/dbbackuppath=$PathParm/; s/$Dayold/Days=$DayParm/; s/$MPold/MySQL=$MysqlParm/; s/$MCPold/MySQLCheck=$MysqlCParm/; s/$Mdbold/MongoDB=$MongoParm/;" $Path/ebackup.conf

    Sshkey_def
    Cron_def
    echo "Success !!!"

}

RotateLog () {
echo "Start rotating logs"
if [ -f "${Log}.${rotateQu}" ]; then { rm ${Log}.${rotateQu}; } fi
rotateFOlder=$rotateQu
	while [ 0 -ne $rotateFOlder  ]
	do     	
		rotateFLaster=$rotateFOlder
		rotateFOlder=$((${rotateFLaster} - 1))
		        if [ $rotateFOlder -eq 0 ]; 
			then 
				if [ -f "${Log}" ]
				then
				   
					 echo "moving  "${Log} ${Log}.${rotateFLaster}
					 mv ${Log} ${Log}.${rotateFLaster}
				fi
				else
				if [ -f "${Log}.${rotateFOlder}" ]
				then
					echo "moving  "${Log}.${rotateFOlder} ${Log}.${rotateFLaster}
					mv ${Log}.${rotateFOlder} ${Log}.${rotateFLaster}
				fi
			fi
	done
}

PidFun () {
#find $Pid -mtime +2 -exec rm -r '{}' \; 2>/dev/null
ps uax | grep -v grep | grep $0 || find $Pid -exec rm -r '{}' \;
echo $SUFFIX > $Path/lastback.txt
if [ -f $Pid ]
then
    echo "backup already running, shutting down! If you want to start you should do rm "$Pid
    exit 1
    else
    echo $$ > $Pid
 echo "Start backup"
fi 
if   echo Rotation is $rotate  | grep -E -w "[Yy][Ee][Ss]" ; then { RotateLog; } fi	     
echo "Start backup "$(date) | tee -a $Log 
#    /bin/rm -f $Pid
}

Finish () {
echo "Finish "$(date) | tee -a $Log 
echo "Log file:  "$Log
/bin/rm -f $Pid
}


help () {
echo    "Start with:
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
	-command      - Execute remote command on a backup server, example:$Path/ebackup.sh -command \"ls -al\"
	-com          - Same as -command, example:$Path/ebackup.sh -com \"cd ~/$dir; ls -al\"
	-ssh-keygen   - Create authentication key  
	-configure    - Configure or reconfigure your config file 
	-rotate       - Rotate log files

ebackup.conf - configuration file
files.txt - the file defines directories that you want to bacup
files.exclude.txt - the file defines exclude directories
exclude.mysqldb.txt - the script backups all of a databases but you can exclude some of it
	"
}
# ======================================== Action ======================================

case $1 in 
     -backup)	
PidFun
if   echo MySQLCheck is $MySQLCheck | grep -E -w "[Yy][Ee][Ss]" ; then { MySQLCheck 2>&1 | tee -a  $Log; } fi 
if   echo MySQL is $MySQL | grep -E -w "[Yy][Ee][Ss]" ; then {  MySQLDump 2>&1 | tee -a $Log; } fi 
if   echo MongoDB is $MongoDB | grep -E -w "[Yy][Ee][Ss]"; then { MongoDump 2>&1 | tee -a $Log ; }  fi
    StoreBackupInc 2>&1 | tee -a  $Log 
if   echo MySQL is $MySQL Mongodb is $MongoDB  | grep -E -w "[Yy][Ee][Ss]" ; then { StoreBackupMysql 2>&1 | tee -a $Log; } fi 
    Arsync 2>&1 | tee -a $Log
Finish 
    ;;
   -check|check)
    CheckBackup 
    ;;
    -check-l)
    CheckBackupAll
    ;;
    -backup-full)
PidFun
    echo "Start Full Backup" | tee -a $Log
	if   echo MySQL is $MySQL | grep -E -w "[Yy][Ee][Ss]" ; then {  MySQLDump 2>&1 | tee -a $Log; } fi 
     	StoreBackup 2>&1 | tee -a $Log 
        StoreBackupMysql 2>&1 | tee -a $Log
        Arsync 2>&1 | tee -a $Log 
Finish 
    ;;
    -backup-mysql)
PidFun 
    echo "Start MySQL Dump and send to backup server" | tee -a $Log
    MySQLDump 2>&1 | tee -a $Log 
    StoreBackupMysql 2>&1 | tee -a $Log
    OnlyMysql="OnlyM"
    Arsync 2>&1 | tee -a $Log 
Finish 
    ;;
    -mysql-check)
    echo "Start MySQL Check"
    MySQLCheck
    ;;
    -mysql-dump)
    echo "Start MySQL Dump"
    MySQLDump
    ;;
    -clean)
    Clean
    ;;
    -command|-com)
    Com=$2
    Command
    ;;
    -ssh-keygen)
    SSHkey
    ;;
    -configure)
    Configure
    ;;
    -rotate)
    RotateLog
    ;;
    -check-rsync)
    CheckRsync
    ;;
    -check-rsync-l)
    CheckRsyncl
    ;;
    -status)
	    if [ -f $Pid ]; then { echo "backup is running as pid "$(cat $Pid); } else { echo "backup is not running";  } fi
    ;;
        *)
	help
    ;;
esac
exit 0

