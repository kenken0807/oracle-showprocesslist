#!/bin/sh
#watch --interval=30 "bash ShowProcesslist,sh | sqlplus / as sysdba"
function GetSql() {
	TYPE=$1 
	TABLE=$2 
	USER=$3 
	SIMPLE=$4 
	FULL=$5
	wk="set line 1000\n"
	#echo "set head off"
	wk="${wk} set pagesize 0\n"
	wk="${wk} set trim on\n"
	wk="${wk} column sid format 9999\n"
	wk="${wk} column serial format 99999\n"
	wk="${wk} column MACHINE format a20\n"
	wk="${wk} column MACHINE truncated\n"
	wk="${wk} column PROCESS format a10\n"
	wk="${wk} column PROCESS truncated\n"
	wk="${wk} column OSUSER format a10\n"
	wk="${wk} column OSUSER truncated\n"
	wk="${wk} column username format a10\n"
	wk="${wk} column username truncated\n"
	wk="${wk} column event format a20\n"
	wk="${wk} column event truncated\n"
	wk="${wk} column WAIT_CLASS format a12\n"
	wk="${wk} column WAIT_CLASS truncated\n"
	wk="${wk} column status format a1\n"
	wk="${wk} column server format a9\n"
	wk="${wk} column program format a40\n"
	wk="${wk} set feedback off\n"
	wk="${wk} ALTER SESSION SET NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss';\n" 
	#echo "set autot on exp"
	#echo "column SPENDTIME format '0000'"
	wk="${wk} select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),' From $2' from dual;\n"
	wk="${wk} set pagesize 300\n"
	wk="${wk} column ACT_TM format 9999\n"
	#wk="${wk} column WAITTM format 999999\n"
	if [ ${USER} = "alluser" ]; then
		AUSER=" "
	else
		AUSER=" and a.username = upper('$3') "
	fi
	if [ ${TYPE} -eq 1 ]; then
		STATUS="  "
	else
		STATUS=" and a.status='ACTIVE' "
	fi
	#simple
	if [ ${SIMPLE} -eq 1 ]; then
		wk="${wk} select a.sid,a.serial# as SERIAL,CASE a.status WHEN 'ACTIVE' THEN 'A' ELSE 'I' END as status,round((sysdate -a.SQL_EXEC_START) * 24 * 60 * 60,0) as "ACT_TM"
		,a.username,a.MACHINE,a.WAIT_CLASS,a.seconds_in_wait as WAITTM,a.LOGON_TIME 
		from v\$session a where 1=1 ${AUSER} ${STATUS} order by a.status,a.sid,a.username;\n"
		echo "${wk}"
		return
	fi
	if [ ${FULL} -eq 0 ]; then
		wk="${wk} column sql_text format a60\n"
		wk="${wk} column sql_text truncated\n"
		SELECT="SELECT a.sid,a.serial# as SERIAL,b.sql_text,CASE a.status WHEN 'ACTIVE' THEN 'A' ELSE 'I' END as status ,round((sysdate -a.SQL_EXEC_START) * 24 * 60 * 60,0) as "ACTIVE_TIME",a.username
				,a.OSUSER,a.MACHINE ,a.WAIT_CLASS,a.event,a.seconds_in_wait as WAITTM,a.BLOCKING_SESSION,a.program,a.LOGON_TIME 
				FROM v\$session a
				LEFT JOIN  ${TABLE} b ON a.sql_id=b.sql_id and piece =0
				WHERE 1=1 ${AUSER} ${STATUS}
				ORDER BY a.status,a.sid;\n"
	else
		wk="${wk} column sql_text format a768\n"
		wk="${wk} column sql_text truncated\n"
		SELECT="SELECT a.sid,a.serial# as SERIAL,CASE a.status WHEN 'ACTIVE' THEN 'A' ELSE 'I' END as status,round((sysdate -a.SQL_EXEC_START) * 24 * 60 * 60,0) as "ACT_TM" ,a.seconds_in_wait as WAITTM,b.sql_text  
				FROM v\$session a
				LEFT JOIN (SELECT sql_id,listagg(SQL_TEXT) WITHIN GROUP (ORDER BY PIECE) as SQL_TEXT FROM v\$sqltext WHERE PIECE <= 13 GROUP BY sql_id ) b ON a.sql_id=b.sql_id
				WHERE 1=1 ${AUSER} ${STATUS}
				ORDER BY a.status,a.sid;\n"
	fi
	wk="${wk} ${SELECT} " 
	echo "${wk}"
}

function OptsDesc {
	echo "./ShowProcesslist.sh [option]"
	echo ""
	echo "-n [number of seconds]    LOOPTIME Default:10"
	echo "-a                        Check include INACTIVE sessions Default:ACTIVE"
	echo "-t                        Check table v\$sqltext table[WARN]it will be high-load  Default: perfstat.stats\$sqltext" 
	echo "-u [username]             USERNAME Default:none"
	echo "-s                        Show Simplicity Default:none"
	echo "-f                        Show SQL_TEXT long ver  Default:none"
}
TIME=10
TYPE=0
USER="alluser"
TABLE="perfstat.stats\$sqltext"
SIMPLE=0
FULL=0
while getopts u:n:athsf opt
do
	case ${opt} in
	u)
	  USER=${OPTARG};;
	n)
	  TIME=${OPTARG};;
	a)
	  TYPE=1;;
	t)
	  TABLE="v\$sqltext";;
	h)
	  OptsDesc
	  exit 1;;
	s)
	  SIMPLE=1;;
	f)
	  FULL=1;;
	\?)
	  echo "Unknown Opts"
	  OptsDesc
	  exit 1;;
	esac
done
#watch --interval $TIME  "/home/oracle/scripts/oracle-showprocesslist.git/ShowProcesslist.sh $TYPE | sqlplus  -S  / as sysdba"
while :
do
	SQL=`GetSql ${TYPE} ${TABLE} ${USER} ${SIMPLE} ${FULL}`
	clear
	#echo -e "$SQL" 
	echo -e "$SQL" | sqlplus -s / as sysdba
	sleep ${TIME}
done

