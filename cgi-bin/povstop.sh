#!/bin/sh

PIDS=`ps -elf | grep pov_demo | grep -v grep | head -n 1 | perl -p -e "s/^.*root      //; s/  .*$/ /;"`
#PIDS=`ps -eo pid,pgrp,args | grep -e "pov_demo" | grep -v "grep" | head -n 1 | perl -p -e "s/^\s*\S+\s+(\S+)\s+\S+/\1/;"`
for PID in $PIDS
do
  echo killing $PID
  kill -TERM $PID >& /dev/null
done

#if [ -f "/home/root/.povpid" ]; then
#  rm -f /home/root/.povpid
#fi


echo 1
