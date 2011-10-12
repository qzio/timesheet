#!/bin/bash

PIDFILE=$(dirname $0)/../data/ts.pid
PORT=1337


case "$1" in
  start)
    echo "Start tracking"
    curl -X POST -F "cmd=start" localhost:$PORT/index.text
    ;;
  stop)
    echo "Stop tracking"
    curl -X POST -F "cmd=stop" -F "comment=$2" localhost:$PORT/index.text
    ;;
  status)
    echo "Check status"
    curl -X GET localhost:$PORT/index.text
    ;;
  startd)
    echo "Starting daemon"
    ruby app.rb &> $(dirname $0)/../data/production.log &
    echo $! > $PIDFILE
    ;;
  stopd)
    echo "stopping daemon"
    if [ -e $PIDFILE ]; then
      kill `cat $PIDFILE`
      rm $PIDFILE
    else
      echo "Did not find a PID file, unable to stop daemon"
    fi
    ;;
  restartd)
    echo "Restarting daemon"
    $0 stopd
    $0 startd
    ;;
  *)
    echo "USAGE: $0 start|stop|startd|stopd"
    exit 1
    ;;
esac
exit 0;
