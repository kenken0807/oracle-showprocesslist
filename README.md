# oracle-showprocesslist
this is for oracle database.it is like mysql's SHOW PROCESSLIST command and better to install STATSPACK.
## OPTIONS
-n [number of seconds]    means: LOOPTIME                                               Default: 10  
-a                        means: Check include INACTIVE sessions                        Default: ACTIVE  
-s                        means: Check table v$sql table [WARN]it will be high-load!!   Default: perfstat.stats$sqltext  
-h                        means: Help  
