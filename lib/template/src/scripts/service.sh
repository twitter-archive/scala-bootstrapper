#!/bin/sh
## this file is the control script for your jvm service.
## it is executed by monit with an argument of either start, stop or restart
## it is not responsible for options specific to the jvm but does background,
## disown, and redirect output.

function start() {
  cd $APP_HOME
  $START_SCRIPT > $STDOUT_FILE 2> $STDERR_FILE &
  disown %1

  sleep $INITIAL_SLEEP # give it time to compile config files and bind to ports
}

function running() {
  curl -m 5 -s "http://localhost:$ADMIN_PORT/ping.txt" > /dev/null 2> /dev/null
}

function stop() {
  kill -TERM $(cat $PIDFILE)
}

function stopped() {
  ! kill -0 $1 > /dev/null 2> /dev/null
}

SCRIPT_DIR=`dirname $0`
source "$SCRIPT_DIR/config.sh"
START_SCRIPT="sh $SCRIPT_DIR/server.sh"

if [ -z $INITIAL_SLEEP ]; then
  INITIAL_SLEEP=3
fi

if [ -z $MAX_START_TRIES ]; then
  MAX_START_TRIES=5
fi

case "$1" in
  start)
    printf "Starting %s... " "$APP_NAME"

    if running; then
      echo "already running."
      exit 0
    fi

    start

    tries=0
    while ! running; do
      tries=$((tries + 1))
      if [ $tries -ge $MAX_START_TRIES ]; then
        echo "ERROR: failed to start"
        exit 1
      fi
      sleep 1
    done
    echo "done."
  ;;

  stop)
    printf "Stopping %s... " "$APP_NAME"

    if [ ! -f $PIDFILE ]; then
      GUESSED_PID=`pgrep -u $USER java`
      if [ -z $GUESSED_PID ]; then
        echo "ERROR: no pid file and no java process found"
      else
        echo "ERROR: no pid file, but found java process: $GUESSED_PID"
      fi
      exit 1
    fi

    SNAPSHOT_PID=$(cat $PIDFILE)

    if $(stopped $SNAPSHOT_PID); then
      echo "already stopped."
      exit 0
    fi

    stop

    tries=0
    while ! $(stopped $SNAPSHOT_PID); do
      tries=$((tries + 1))
      if [ $tries -ge 5 ]; then
        echo "ERROR: failed to stop"
        exit 1
      fi
      sleep 1
    done
    echo "done."
  ;;

  status)
    if running; then
      echo "$APP_NAME is running."
    else
      echo "$APP_NAME is NOT running."
    fi
  ;;

  restart)
    $0 stop
    sleep 2
    $0 start
  ;;

  *)
    echo "Usage: /etc/init.d/$APP_NAME {start|stop|restart|status}"
    exit 1
  ;;
esac

exit 0
