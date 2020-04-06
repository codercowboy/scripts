#!/bin/bash

OLD_PWD="$PWD"
WORKING_DIRECTORY="/archive/scripts/analog"

cd "$WORKING_DIRECTORY"

TEMP_CONFIG_FILE="tmp.cfg"
VERBOSE_FOOTER="verbosefooter.cfg"
NORMAL_FOOTER="footer.cfg"



#first arg is a label for this run
#second arg is the footer.cfg or verbosefooter.cfg to append to the end of the config file
#third arg is the header to put in the config file
function run_analog
{
	echo "NOW RUNNING $1"
	
	#start the config file out with the header stuff
	#note that this is going to overwrite the $TEMP_CONFIG_FILE 
	echo "$3" > "$TEMP_CONFIG_FILE"
	
	#append the footer 
	cat "$2" >> "$TEMP_CONFIG_FILE"
	
	#run analog..
	ARGS="-G +g$TEMP_CONFIG_FILE"
	echo "ARGS ARE $ARGS"
	analog $ARGS
	
	
}
### ojfs all
run_analog "ojfs all" "$NORMAL_FOOTER" "

HOSTNAME \"onejasonforsale all\"
HOSTURL http://www.onejasonforsale.com
LOGFILE /archive/logs/unzipped/ojfs/*
OUTFILE /www/stats/ojfs/all/index.html
IMAGEDIR /www/stats/ojfs/all/

"

###ojfs mp3
run_analog "ojfs mp3" "$VERBOSE_FOOTER" "

HOSTNAME \"onejasonforsale mp3\"
HOSTURL http://www.onejasonforsale.com
LOGFILE /archive/logs/unzipped/ojfs/*
OUTFILE /www/stats/ojfs/mp3/index.html
IMAGEDIR /www/stats/ojfs/mp3/
FILEEXCLUDE *
FILEINCLUDE *.mp3
REFREPEXCLUDE *onejasonforsale.com/*

"

### esoteric all
run_analog "esoteric all" "$NORMAL_FOOTER" "

HOSTNAME \"esoteric vision\"
HOSTURL http://www.anesotericvision.com
LOGFILE /archive/logs/unzipped/esoteric/*
OUTFILE /www/stats/esoteric/index.html
IMAGEDIR /www/stats/esoteric/
REFREPEXCLUDE *esotericvision.com*

"

### futility all
run_analog "futility all" "$NORMAL_FOOTER" "

HOSTNAME \"experimental futility\"
HOSTURL http://www.experimentalfutility.com
LOGFILE /archive/logs/unzipped/futility/*
OUTFILE /www/stats/futility/index.html
IMAGEDIR /www/stats/futility/
REFREPEXCLUDE *experimentalfutility.com*

"

### wws all
run_analog "wws all" "$NORMAL_FOOTER" "

HOSTNAME \"wws\"
HOSTURL http://www.worldsworstsoftware.com
LOGFILE /archive/logs/unzipped/wws/*
OUTFILE /www/stats/wws/index.html
IMAGEDIR /www/stats/wws/
REFREPEXCLUDE *worldsworstsoftware.com*


"
### antipatterns all
run_analog "antipatterns all" "$NORMAL_FOOTER" "

HOSTNAME \"antipatterns\"
HOSTURL http://www.theantipatterns.com
LOGFILE /archive/logs/unzipped/antipatterns/*
OUTFILE /www/stats/antipatterns/all/index.html
IMAGEDIR /www/stats/antipatterns/
REFREPEXCLUDE *theantipatterns.com*

"

### antipatterns mp3-all
run_analog "antipatterns all" "$NORMAL_FOOTER" "

HOSTNAME \"antipatterns\"
HOSTURL http://www.theantipatterns.com
LOGFILE /archive/logs/unzipped/antipatterns/*
OUTFILE /www/stats/antipatterns/mp3-all/index.html
IMAGEDIR /www/stats/antipatterns/
REFREPEXCLUDE *theantipatterns.com*
FILEEXCLUDE *
FILEINCLUDE *.mp3
FILEINCLUDE *.MP3

"

### antipatterns mp3-jpq
run_analog "antipatterns all" "$NORMAL_FOOTER" "

HOSTNAME \"antipatterns\"
HOSTURL http://www.theantipatterns.com
LOGFILE /archive/logs/unzipped/antipatterns/*
OUTFILE /www/stats/antipatterns/mp3-jpq/index.html
IMAGEDIR /www/stats/antipatterns/
REFREPEXCLUDE *theantipatterns.com*
FILEEXCLUDE *
FILEINCLUDE *jpq*

"

### antipatterns mp3-negative-space
run_analog "antipatterns all" "$NORMAL_FOOTER" "

HOSTNAME \"antipatterns\"
HOSTURL http://www.theantipatterns.com
LOGFILE /archive/logs/unzipped/antipatterns/*
OUTFILE /www/stats/antipatterns/mp3-negative-space/index.html
IMAGEDIR /www/stats/antipatterns/
REFREPEXCLUDE *theantipatterns.com*
FILEEXCLUDE *
FILEINCLUDE \"*Negative Space*.mp3\"

"



### futility all
run_analog "aajr all" "$NORMAL_FOOTER" "

HOSTNAME \"amanda and jason rule\"
HOSTURL http://www.amandaandjasonrule.com
LOGFILE /archive/logs/unzipped/aajr/*
OUTFILE /www/stats/aajr/index.html
IMAGEDIR /www/stats/aajr/
REFREPEXCLUDE *amandaandjasonrule.com*


"

###blunx
run_analog "blunx" "$NORMAL_FOOTER" "

HOSTNAME \"blunx\"
HOSTURL http://blunx.no-ip.com/
LOGFILE /archive/logs/unzipped/blunx/*
OUTFILE /www/stats/blunx/index.html
IMAGEDIR /www/stats/blunx/
REFREPEXCLUDE *blunx.no-ip.com*

"

###jpq
run_analog "jpq" "$VERBOSE_FOOTER" "

HOSTNAME \"blunx/jpq\"
HOSTURL http://blunx.no-ip.com/
LOGFILE /archive/logs/unzipped/blunx/*
OUTFILE /www/stats/jpq/index.html
IMAGEDIR /www/stats/jpq/
FILEEXCLUDE *
FILEINCLUDE /jpq/*
REFREPEXCLUDE *blunx.no-ip.com*


"

###kuno
run_analog "kuno" "$VERBOSE_FOOTER" "

HOSTNAME \"kuno\"
HOSTURL http://www.kunosdream.com
LOGFILE /archive/logs/unzipped/kuno/*
OUTFILE /www/stats/kuno/index.html
IMAGEDIR /www/stats/kuno/
REFREPEXCLUDE *kunosdream.com*

"

###wwp
run_analog "wwp" "$VERBOSE_FOOTER" "

HOSTNAME \"wwp\"
HOSTURL http://www.worldsworstphotography.com
LOGFILE /archive/logs/unzipped/wwp/*
OUTFILE /www/stats/wwp/index.html
IMAGEDIR /www/stats/wwp/
REFREPEXCLUDE *worldsworstphotography.com*

"


cd "$OLD_PWD"
