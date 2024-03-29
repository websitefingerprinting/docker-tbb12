#!/bin/bash

# configures and runs a crawl (inside a docker container)
# IMPORTANT: If this file is changed, docker container needs to be rebuilt
DEVICE=eth0
BASE='/home/docker'
FOLDER_NAME='docker-tbb12'

AUTO_CONFIG_PATH='/home/docker/tor-browser/Browser/defaults/pref/ '
TORRC_CONFIG_PATH='/home/docker/tor-browser/Browser/'
TORRC_PATH='/home/docker/tor-browser/Browser/TorBrowser/Data/Tor/torrc'


PT='wfdef'

wfd=$1
tag=$2
crawler=$3


# set offloads
ifconfig ${DEVICE} mtu 1500
ethtool -K ${DEVICE} tx off rx off tso off gso off gro off lro off

# cp TBB repository to container's own space
echo "Get TBB"
# shellcheck disable=SC2164
pushd ${BASE}
cp ./${FOLDER_NAME}/put_tbb12_here/tor-browser.tar.xz ${BASE}/tor-browser-cp.tar.xz
tar -xf tor-browser-cp.tar.xz -C ${BASE}
rm ${BASE}/tor-browser-cp.tar.xz

# set user profile js file
cp /home/docker/${FOLDER_NAME}/autoconfig.js ${AUTO_CONFIG_PATH}
cp /home/docker/${FOLDER_NAME}/firefox.cfg ${TORRC_CONFIG_PATH}

# Write in torrc that can not be set in firefox.cfg 
echo 'ClientTransportPlugin '${wfd}' exec /home/docker/'${PT}'-cp/obfs4proxy/obfs4proxy' >> ${TORRC_PATH}

# change privilege 
chmod -R 777 ${BASE}/tor-browser/

# cp PT repository to container's own space.
echo "Get WFDefProxy"
cp -r /home/docker/${PT} /home/docker/${PT}-cp
chmod -R 777 /home/docker/${PT}-cp



if [ "${wfd}" == "wfgan" ]; then
	echo "Start pyserver..."
	python3 /home/docker/${PT}-cp/transports/wfgan/grpc/py/server.py --log /home/docker/tor-config/pyserver_${tag}.log -c observer &
	sleep 5
fi


# # launch crawler
# shellcheck disable=SC2164
pushd ${BASE}/AlexaCrawler
export MOZ_HEADLESS=1

## TBB12 requires non-root to run
sudo -u docker -H python ${crawler}
