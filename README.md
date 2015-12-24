# oracle-showprocesslist
this is for oracle database.it is like mysql's SHOW PROCESSLIST command and better to install STATSPACK.
## OPTIONS
-n [number of seconds]    Interval Default:10
-a                        Check include INACTIVE sessions Default:ACTIVE
-t                        Check table v$sqltext table[WARN]it will be high-load  Default: perfstat.stats$sqltext
-u [username]             USERNAME Default:none
-s                        Show Simplicity Default:none
-f                        Show SQL_TEXT long ver  Default:none
