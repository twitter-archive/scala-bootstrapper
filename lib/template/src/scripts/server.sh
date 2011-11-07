#!/bin/sh
## this file encapsulates starting the server including the JVM options
## and putting the pid into the pidfile. this is executed by service.sh
## on the start action.
## it is an expectation that this be run in your application home directory.

SCRIPT_DIR=`dirname $0`
source "$SCRIPT_DIR/config.sh"

GC_LOGGING_OPTS="-verbosegc -Xloggc:/var/log/$APP_NAME/gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintHeapAtGC"
JAVA_OPTS="-server -XX:+DisableExplicitGC -XX:+UseNUMA $GC_OPTS $GC_LOGGING_OPTS $HEAP_OPTS $EXTRA_JAVA_OPTS"

if [ -z $APP_HOME ]; then
  APP_HOME=`pwd`
fi

if [ -z $PIDFILE ]; then
  PIDFILE="/var/run/$APP_NAME/$APP_NAME.pid"
fi

if [ ! -f "$APP_HOME/$MAIN_JAR" ]; then
  echo "jar not found at $APP_HOME/$MAIN_JAR"
  exit 1
fi

if [ -z $JAVA_HOME ]; then
  JAVA_HOME="/usr/java/default"
fi

echo $$ > $PIDFILE
exec ${JAVA_HOME}/bin/java ${JAVA_OPTS} -jar ${APP_HOME}/${MAIN_JAR} ${CMD_OPTS}
