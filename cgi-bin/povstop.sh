#!/bin/sh

PIDS=`ps -elf | grep pov_demo | perl -p -e "s/^.*root      //; s/  .*$/ /;"`
for PID in $PIDS
do
  echo killing $PID
  kill $PID >& /dev/null
done

#if [ -f "/home/root/.povpid" ]; then
#  rm -f /home/root/.povpid
#fi

echo heartbeat > /sys/class/leds/hps_led0/trigger

echo 1
