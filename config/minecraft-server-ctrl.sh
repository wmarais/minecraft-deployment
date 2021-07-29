#!/bin/bash

# Adjust below to match your system
WORKDIR="/opt/minecraft-server"
MIN_MEMORY_ALLOCATION="5G"
MAX_MEMORY_ALLOCATION="5G"
JAVA="/usr/lib/jvm/jdk-16.0.2/bin/java"


# Additional Java flags recommended by Aikar: https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/
# Modify as needed.
JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

# Don't modify below
RETVAL=0

getpid() {
    pid=`ps -eo pid,comm | grep java | awk '{ print $1 }'`
}

echo_success() {
    echo "success"
}

echo_failure() {
    echo "failed"
}

start() {
    echo -n $"Starting minecraft: "
    getpid
    if [ -z "$pid" ]; then
        cd $WORKDIR
        ${JAVA} -Xms$MIN_MEMORY_ALLOCATION -Xmx$MAX_MEMORY_ALLOCATION $JAVA_FLAGS -server -jar $WORKDIR/server.jar nogui &
        RETVAL=$?
    fi
    if [ $RETVAL -eq 0 ]; then
        touch ${WORKDIR}/lock_file
        echo_success
    else
        echo_failure
    fi
    echo
    return $RETVAL
}

stop() {
    echo -n $"Stopping minecraft: "
    getpid
    RETVAL=$?
    if [ -n "$pid" ]; then
        kill -9 $pid
    sleep 1
    getpid
    if [ -z "$pid" ]; then
        rm -f ${WORKDIR}/lock_file
        echo_success
    else
        echo_failure
    fi
    else
        echo_failure
    fi
    echo
    return $RETVAL
}

case "$1" in
   start)
      start
      ;;
   stop)
      stop
      ;;
   restart)
      stop
      start
      ;;
   status)
      getpid
      if [ -n "$pid" ]; then
          echo "minecraft-server (pid ${pid}) is running..."
      else
          RETVAL=1
          echo "minecraft-server is stopped"
      fi
      ;;
   *)
      echo $"Usage: $0 {start|stop|status|restart}"
      exit 1
      ;;
esac

exit 0
