# This script is tailored to collectd openshift specfic metrics

INTERVAL=10
HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"

while `true`
do
  USED=$(oo-cgroup-read memory.usage_in_bytes)
  MAX_USED=$(oo-cgroup-read memory.max_usage_in_bytes)
  LIMIT=$(oo-cgroup-read memory.limit_in_bytes)
  echo "PUTVAL \"$HOSTNAME/gear_memory/gear_memory\" interval=$INTERVAL N:$USED:$MAX_USED:$LIMIT"
 
  VALUE=$(oo-cgroup-read cpuacct.stat)
  SYS=`echo $VALUE | cut -f 4 -d " "`
  USER=`echo $VALUE |cut -f 2 -d " "`
  echo "PUTVAL \"$HOSTNAME/gear_cpu_usage/gear_cpu\" interval=$INTERVAL N:$USER:$SYS"

  VALUE=`netstat -npt | grep tcp | grep -v "-" | awk '{ print $6}' | sort | uniq -c`
  ESTABLISHED=`echo $VALUE | grep ESTABLISHED | awk '{print $1 }'`
  CLOSED_WAIT=`echo $VALUE | grep CLOSED_WAIT | awk '{print $1 }'`
  TIME_WAIT=`echo $VALUE | grep TIME_WAIT | awk '{print $1 }'`
  LISTENING=`netstat -lnpt | grep -v "-" | grep tcp | wc -l`
  
  echo "PUTVAL \"$HOSTNAME/gear_network/gear_connections\" interval=$INTERVAL N:${ESTABLISHED:-0}:${TIME_WAIT:-0}:${CLOSED_WAIT:-0}:${LISTENING:-0}"
 
  OLD_IFS=$IFS
  IFS=$'\n'
  DSS_CLI=`env | grep "DSS" | grep "CLI"`
  for CLI in $DSS_CLI
  do
    HOST=`echo $CLI | cut -f 1 -d "=" | sed -e 's/_CLI//g'`
    E=`echo $CLI | cut -f 1 -d "="`
    K=`eval echo "/usr/bin/time --format \'%R\' \\\$\$E -e \'quit\' 2>&1"`
    R=`eval $K 2>&1`
    echo "PUTVAL \"$HOSTNAME/conn_to_$HOST/conn_time\" interval=$INTERVAL N:$R"
  done 
  IFS=OLD_IFS
   
	 
# This captures lots of details about memory usage on the gear, perhaps a bit too much
#  VALUE=$(oo-cgroup-read memory.stat)
#  OLD_IFS=IFS;
#  IFS=$'\n'
#  for STAT in $VALUE
#  do
#    V=`echo $STAT | cut -f 2 -d " "`
#    N=`echo $STAT | cut -f 1 -d " "`
#    echo "PUTVAL \"$HOSTNAME/gear_memory_$N/counter\" interval=$INTERVAL N:$V"
#  done
#  IFS=OLD_IFS;
  sleep $INTERVAL
done
