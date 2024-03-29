# A dockerized Tor Browser (TBB version 12)

## What? 
This repository contains a modified Tor Browser 12.0.3 that can work in the docker container 
to facilitate the dataset crawl for website fingerprinting research.
We documented the engineering details about how to hack TBB 12 as it has changed a lot compared with TBB 10. 
Note that the dockerized TBB should be used together with a crawler script.
Therefore, we built another project called [WFCraweler](https://github.com/websitefingerprinting/WFCrawler). 

Note that this is only for research purpose. 

## Our need
We need to use command line tools to drive TBB 12, and we may need to change the torrc configuration 
and let the TBB to close the window after the loading finishes.
Since the Tor Browser Bundle seems to change significantly after upgrading to version 12, 
our previous way to meet these needs does not work anymore, as explained as follows.
(We only consider the Linux version, by the way.)

## Main steps to hack TBB 12

### 1. Configuration after the first download.
Launch TBB 12 on a Linux Computer that has a GUI and click ``Always connect automatically``. 
The Tor browser will not connect to Tor after launch automatically anymore since version 12. 
Therefore, we should click this box manually. 

### 2. Install Tampermonkey extension.
As Tor browser will not close itself after a loading finishes, we choose to use a tampermonkey script to close the window for us.
Search and install ``Tampermonkey`` extension and load the script `closeAfterLoad.js` in this repository in tampermonkey. 

### 3. Pass torrc configuration to TBB 12
The biggest change in TBB 12 is that it will overwrite the items in `Browser/TorBrowser/Data/Tor/torrc` after every launch 
if **this item can be found in the browser's configuration 
(i.e., any setting found in the GUI or in `about:config`).** 
Therefore, to have a customized torrc, 
we should take advantage of [AutoConfig](https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig) 
that can effectively inject the required parameters into Firefox. 
You need to put `autoconfig.js` in `./Browser/defaults/pref/`. 
After that, put `firefox.cfg`, which contains the settings in `./Browser/` and start TBB. 
Now the correct settings should be populated by Tor Launcher and reflected in torrc.

For other torrc configurations that are not in `about:config`, you can directly add them in the torrc file.

We also pass necessary browser settings to TBB 12 here. We explain the use of these settings in `firefox.cfg`. 

### 4. Run the modified TBB 12 in headless mode
To run the modified browser, simply use the command `./Browser/start-tor-browser --verbose --headless {some url}`. 
On any headless server or inside the docker, simply use `export MOZ_HEADLESS=1` (See `Entrypoint.sh`). 

### 5. Use our docker container
***NOTE that: please use rootless docker to run the container as TBB 12 does not allow root privilege.***

In this folder, type `make build` to build the docker image. Then use `make run` to launch the crawl. 
Remember to check the necessary parameters in the `Makefile`. 
Do check the `volumes` as you may have a different path than I do.
The docker will execute `Entrypoint.sh` after launch. 
Do modify it if you use your own crawler (See Line 65 in `Entrypoint.sh`).

Note that since TBB 12, **running TBB as root is not allowed** anymore. Pay attention to it if you run TBB 12 in docker containers. 

We have uploaded the modified TBB version 12.0.3 to this repository so that you can directly use it. If you want to use another version, 
just follow the above steps.


### Reminder
These should be very important when you first use the dockerized TBB 12 

1. Do remember to replace the correct info in `Line 37` of `firefox.cfg`.

## Acknowledgment
- Thanks for the help from Hamy on how to hack firefox. 
- The Makefile is based on Nate Mathews's project [Tor-Browser-Crawler-Video](https://github.com/notem/tor-browser-crawler-video). 

## Contact 
Feel free to email me for any problem (gongjj at comp dot nus dot edu dot sg). 
