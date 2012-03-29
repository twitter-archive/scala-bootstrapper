#!/bin/sh

export APP_NAME="birdname"
export APP_HOME="/usr/local/$APP_NAME/current"

export PIDFILE="/var/run/$APP_NAME/$APP_NAME.pid"
export STDOUT_FILE="/var/log/$APP_NAME/stdout"
export STDERR_FILE="/var/log/$APP_NAME/error"

export MAIN_JAR="$APP_NAME-1.0-SNAPSHOT.jar"
export ADMIN_PORT=9900

export HEAP_OPTS="-Xmx4096m -Xms4096m -XX:NewSize=768m"
export GC_OPTS="-XX:+UseParallelOldGC -XX:+UseAdaptiveSizePolicy -XX:MaxGCPauseMillis=1000 -XX:GCTimeRatio=99"

export STAGE=production
export EXTRA_JAVA_OPTS="-Dstage=$STAGE"

# you can also define the following functions to override behavior:
# running - checks whether the process is running
# start - executed after the process is verified to not be running and a start was requested
# stop - executed after the process is verified to be running and a stop was requested
# stopped - is passed the PID before ths top and checks if its still running
