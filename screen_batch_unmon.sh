#!/bin/bash
host=c1


port=443
wfd=front



time=1s
date +"%H:%M:%S"  
sleep ${time}

# end time  
date +"%H:%M:%S"  


echo "begin"

LOG_DIR=/home/jgongac/tor-config

# shellcheck disable=SC2164
pushd /home/jgongac/docker-tbb12
# make clean

# kill all finished screen sessions
# screen -ls | grep Dsctached | cut -d. -f1 | awk '{print $1}' | xargs kill

# create sessions

host_num=4
step=3000
start_num=200

for i in $(seq 1 $host_num);
do
   start=$((start_num+i*step-step));
   end=$((start_num+i*step));
   echo "start: $start, end: $end"
   screen -dmS "tbb$i" -L -Logfile ${LOG_DIR}/${host}_tbb${i}_screen.log make run open=1 start=${start} end=${end} tag=${host}_tbb"$i" port=${port} wfd=${wfd};
   sleep 2;
done
