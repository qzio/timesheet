#!/bin/bash

PIDFILE=data/ts.pid


case "$1" in
  start)
    echo "start tracking"
    curl -X POST -F "cmd=start" localhost:4567/index.text
    ;;
  stop)
    echo "stop tracking"
    curl -X POST -F "cmd=stop" localhost:4567/index.text
    ;;
  status)
    echo "check status"
    curl -X GET localhost:4567/index.text
    ;;
  startd)
    echo "starting daemon"
    ruby ts.rb &> data/production.log &
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
