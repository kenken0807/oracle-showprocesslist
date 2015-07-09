#!/bin/sh
function GetSql() {
	wk="set line 500\n"
	#echo "set head off"
	wk="${wk} set pagesize 0\n"
	wk="${wk} set trim on\n"
	wk="${wk} column sql_text format a60\n"
	wk="${wk} column sql_text truncated\n"
	wk="${wk} column MACHINE format a30\n"
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
	wk="${wk} column status format a8\n"
	wk="${wk} column server format a9\n"
	wk="${wk} column program format a40\n"
	wk="${wk} set feedback off\n"
	wk="${wk} ALTER SESSION SET NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss';\n" 
	#echo "set autot on exp"
	#echo "column SPENDTIME format '0000'"
	wk="${wk} select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),' From $2' from dual;\n"
	wk="${wk} set pagesize 300\n"
	if [ $2 = "perfstat.stats\$sqltext" ]; then
		WHERE=" where piece =0 "
	else
		WHERE=" "
	fi
	if [ $1 -eq 1 ]; then
		wk="${wk} select a.sid,a.serial#,b.sql_text,a.status
		,round((sysdate -a.SQL_EXEC_START) * 24 * 60 * 60,0) as "ACTIVE_TIME",a.username,a.OSUSER,a.MACHINE
		,a.WAIT_CLASS,a.event,a.seconds_in_wait as WAITTIME,a.server,a.BLOCKING_SESSION,a.program,a.LOGON_TIME
		from v\$session a 
		left join  (select sql_id,sql_text from $2 ${WHERE} group by sql_id,sql_text ) b on a.sql_id=b.sql_id 
        	order by a.status,a.sid,a.username;\n"		
	#order by  a.status,a.sid,a.username;"
	else
		    wk="${wk} select a.sid,a.serial#,b.sql_text,a.status
          	,round((sysdate -a.SQL_EXEC_START) * 24 * 60 * 60,0) as "ACTIVE_TIME",a.username,a.OSUSER,a.MACHINE
          	,a.WAIT_CLASS,a.event,a.seconds_in_wait as WAITTIME,a.server,a.BLOCKING_SESSION,a.program,a.LOGON_TIME
          	from v\$session a
        	  left join ( select sql_id,sql_text from $2 ${WHERE}  group by sql_id,sql_text ) b on a.sql_id=b.sql_id
         	 where a.status='ACTIVE' order by  a.status,a.sid,a.username;\n"
	fi
	echo "${wk}"
}
function OptsDesc {
	echo "./oracle-showprocesslist.sh [option]"
	echo ""
	echo "-n [number of seconds]    DISC: LOOPTIME                                               Default: 10"
	echo "-a                        DISC: Check include INACTIVE sessions                        Default: ACTIVE"
	echo "-s                        DISC: Check table v\$sql table [WARN]it will be high-load!!  Default: perfstat.stats\$sqltext" 
	echo "-h                        DISC: Help"
}
TIME=10
TYPE=0
TABLE="perfstat.stats\$sqltext"
while getopts n:ash opt
do
	case ${opt} in
	n)
	  TIME=${OPTARG};;
	a)
	  TYPE=1;;
	s)
	  TABLE="v\$sql";;
	h)
	  OptsDesc
	  exit 1;;
	\?)
	  echo "Unknown Opts"
	  OptsDesc
	  exit 1;;
	esac
done
while :
do
	SQL=`GetSql ${TYPE} ${TABLE}`
	clear
	#echo -e "$SQL" 
	echo -e "$SQL" | sqlplus -s / as sysdba
	sleep ${TIME}
done

