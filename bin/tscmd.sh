#!/bin/bash

PIDFILE=$(dirname $0)/../data/ts.pid
PORT=1337


case "$1" in
  start)
    echo "start tracking"
    curl -X POST -F "cmd=start" localhost:$PORT/index.text
    ;;
  stop)
    echo "stop tracking"
    curl -X POST -F "cmd=stop" -F "comment=$2" localhost:$PORT/index.text
    ;;
  status)
    echo "check status"
    curl -X GET localhost:$PORT/index.text
    ;;
  startd)
    echo "starting daemon"
    ruby app.rb &> $(dirname $0)/../data/production.log &
    echo $! > $PIDFILE
    ;;
  stopd)
    echo "stopping daemon"
    if [ -e $PIDFILE ]; then
      kill `cat $PIDFILE`
      rm $PIDFILE
    else
      echo "did not find a pid file, unable to stop daemon"
    fi
    ;;
  restartd)
    echo "restarting daemon"
    $0 stopd
    $0 startd
    ;;
  *)
    echo "USAGE: $0 start|stop|startd|stopd"
    exit 1
    ;;
esac
exit 0;
