#!/bin/sh
###################################### Version 2.2.2 #######################################################
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/local/ssl/bin
checkr=`whereis rsync | grep bin | awk -F":" '{ print $2 }'`
if [ "$checkr" = "" ]; then { echo "ERROR: You should install rsync!"; exit 1;  } fi
Path=$( cd "$( dirname "$0" )" && pwd )
. $Path/backup.conf

trap "rm $Pid; exit" 1 2 15

os=`uname`
if [ "$os" = "FreeBSD" ]; then { download="fetch"; }; fi
if [ "$os" = "Linux" ]; then { download="wget"; } fi

createmycnf() { 
	echo "create my.cnf"
        cd /tmp
	$download http://pub.host4.biz/mysql/.my.cnf
	read -p "User for mysqldump [root]: " User
	 : ${User:="root"}
        read -p "Password for user: " Pass
	read -p "Port default [3306]: " Port
	 : ${Port:="3306"}
	read -p "Host default [localhost]: " Host
	 : ${Host:="localhost"}
	sed  "s/User/$User/;s/Pass/$Pass/;s/Port/$Port/;s/Host/$Host/" .my.cnf  > ~/.my.cnf
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
Acount=`ssh -p${Port}  $bkusr@$bksrv "cd ~/$dir; ls -F " | wc -l`
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
#SURFFIXDump=`date +'%Y-%m-%d'`
SUFFIXDump=`cat ${Path}/lastback.txt 2>> /dev/null || echo "null" `
ssh -o ConnectTimeout=5 -p${Port}  $bkusr@$bksrv " if [ -d ~/${dir}/${SUFFIXDump} ]; then { echo '0'; } else { echo '1'; } fi" 2>>/dev/null || echo "1"
}

CheckBackupAll () {
SUFFIXDump=`cat ${Path}/lastback.txt 2>> /dev/null || echo "null" `
ssh -o ConnectTimeout=10 -p${Port}  $bkusr@$bksrv "if [ -d ~/${dir}/${SUFFIXDump} ]; then { echo -e 'Ok\nlast backup: '${SUFFIXDump}; } else { echo -e 'Error\nNeed check!\nUse: ./backup.sh -com \"cd ~/$dir; ls -al\"'; } fi" 2>> /dev/null || echo "Error: connect to host "$bksrv 
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
	DefIP=`grep -E 'bksrv=' $Path/backup.conf | awk -F'=' '{ print $2 }'`
	DefU=`grep -E 'bkusr=' $Path/backup.conf | awk -F'=' '{ print $2 }'`
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

IPfunk () {
	echo  "Start of configuration. You can see your backup configuration file after that"
	read -p "	|->  IP of backup server: " IPParm
	IPold=`grep -E "bksrv=" $Path/backup.conf`
#	if echo $IPParm | grep -v -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then  { echo Bad IP adress; exit 1; } fi
}	
SSHkeygen () {
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
echo "Enter password for "$UserParm"@"$IPParm
cat ~/.ssh/id_rsa.pub | ssh -p${Port} $UserParm@$IPParm "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"

}
        IPfunk  	
	read -p "	|->  User for remote server: " UserParm
	 UPold=`grep -E "bkusr=" $Path/backup.conf`
        echo  "		|->  Please show your df:"
	df -h
	read -p "	|->  Backup path for MySQL dump :[/var/db-backup/] " PathParm
	 : ${PathParm:="/var/db-backup/"}
	 if [ ! -d $PathParm  ]; then { mkdir $PathParm;  } fi
	 Pold=`grep -E 'dbbackuppath=' $Path/backup.conf `
        read -p "	|->  Number of days of keeping backup files ?:[15] " DayParm
	 : ${DayParm:="15"}
	if echo $DayParm | grep -v -E "[0-9]"; then { echo Days cannot be numbers; exit 1; } fi
	 Dayold=`grep -E  "Days=" $Path/backup.conf`
	read -p "	|->  Need backup of MySQL:[YES] " MysqlParm
	 : ${MysqlParm:="YES"}
	 MPold=`grep -E "MySQL=" $Path/backup.conf`
	read -p "	|->  Need check|repair of MySQL:[NO] " MysqlCParm
	 : ${MysqlCParm:="NO"}
	 MCPold=`grep -E "MySQLCheck=" $Path/backup.conf`
	 read -p "	|->  If you have mysql-server, would you like to configure access to MySQL? (~/.my.cnf):[YES] " MysqlAccess
	 : ${MysqlAccess:="YES"}
    	if [ ! -f ~/.my.cnf ] && [ $MysqlAccess = "YES" ]; then { createmycnf;   } fi 
	read -p "	|->  Need backup of Mongodb:[NO] " MongoParm
	 : ${MongoParm:="NO"}
	 Mdbold=`grep -E  "MongoDB=" $Path/backup.conf`
         echo $Pold | sed "s/\//\\\\\//g" > /tmp/Pold.txt
         echo $PathParm | sed "s/\//\\\\\//g" > /tmp/PathParm.txt
         Pold=`cat /tmp/Pold.txt`
         PathParm=`cat  /tmp/PathParm.txt`
	 rm /tmp/Pold.txt
	 rm /tmp/PathParm.txt
#        echo $Pold
#        echo $PathParm
if [ "$os" = "FreeBSD" ]; then { sedkey='-i .back'; }; fi
if [ "$os" = "Linux" ]; then { sedkey='-i.back '; } fi
#echo ip
#sed -i "" "s/$IPold/bksrv=$IPParm/;" backup.conf
#echo user
#sed -i "" "s/$UPold/bkusr=$UserParm/;" backup.conf
#echo path
#sed  -i "" "s/$Pold/dbbackuppath=$PathParm/;" backup.conf
#echo days
#sed -i "" "s/$Dayold/Days=$DayParm/;" backup.conf
#echo MySQL
#sed -i "" "s/$MPold/MySQL=$MysqlParm/;" backup.conf
#echo MySQLCeck
#sed  -i "" "s/$MCPold/MySQLCheck=$MysqlCParm/;" backup.conf
#echo Mongo
#sed -i ""  "s/$Mdbold/MongoDB=$MongoParm/;" backup.conf

sed  $sedkey "s/$IPold/bksrv=$IPParm/; s/$UPold/bkusr=$UserParm/; s/$Pold/dbbackuppath=$PathParm/; s/$Dayold/Days=$DayParm/; s/$MPold/MySQL=$MysqlParm/; s/$MCPold/MySQLCheck=$MysqlCParm/; s/$Mdbold/MongoDB=$MongoParm/;" $Path/backup.conf

	read -p "	|->  Do you want to create ssh-key?:[YES] " sshkey
	 : ${sshkey:="YES"}
if   echo ssh-key is $sshkey | grep -E  "[Yy][Ee][Ss]" ; then { SSHkeygen; } fi 

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
echo "Start backup "`date` | tee -a $Log 
#    /bin/rm -f $Pid
}

Finish () {
echo "Finish "`date` | tee -a $Log 
echo "Log file:  "$Log
/bin/rm -f $Pid
}


help () {
echo -e "Start with:
	-backup       - Incremental backup
	-backup-full  - Full backup
	-status       - Show status
	-check        - Check backup, returns 0 - everything's OK, 1 - something's wrong  (for zabbix)
	-check-l      - Check last backup
	-clean        - Clean backup files
	-backup-mysql - Start mysqldump and send to backup server
	-mysql-check  - Start mysqlcheck
	-mysql-dump   - Start only mysqldump ( without sending backup file to backup server)
	-command      - Execute remote command on backup server, example:$Path/backup.sh -command \"ls -al\"
	-com          - Same as -command, example:$Path/backup.sh -com \"cd ~/$dir; ls -al\"
	-ssh-keygen   - Create authentication key  
	-configure    - Configure or reconfigure your config file 
	-rotate       - Rotate log files
	"
}
# ======================================== Action ======================================

case $1 in 
     -backup)	
PidFun
if   echo MySQLCheck is $MySQLCheck | grep -E -w "[Yy][Ee][Ss]" ; then { MySQLCheck 2>&1 | tee -a  $Log; } fi 
if   echo MySQL is $MySQL | grep -E -w "[Yy][Ee][Ss]" ; then {  MySQLDump 2>&1 | tee -a $Log; } fi 
if   echo MongoDB is $MongoDB | grep -E  "[Yy][Ee][Ss]"; then { MongoDump 2>&1 | tee -a $Log ; }  fi
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
    -status)
    if [ -f $Pid ]; then { echo "backup is running as pid "`cat $Pid`; } else { echo "backup is not running";  } fi
    ;;
        *)
	help
    ;;
esac
exit 0

