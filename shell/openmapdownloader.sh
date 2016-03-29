#!/bin/bash

# This script takes two URLs as parameters of the area to be downloaded:
# take the link from the upper left image as first parameter, rigt-bottom image is second parameter.
# the script will make the apropiate folder if non-existent and download the images between the two locations.

# rum it inside a "parent" folder with the name of your location.
URL1=$1
URL2=$2
ZOOM=$(echo $URL1 | cut -d '/' -f4)

XSTART=$(echo $URL1 | cut -d '/' -f5)
XEND=$(echo $URL2 | cut -d '/' -f5)

YSTART=$(echo $URL1 | cut -d '/' -f6 | cut -d '.' -f1)
YEND=$(echo $URL2 | cut -d '/' -f6 | cut -d '.' -f1)

echo downloading with zoom $ZOOM from $XSTART, $YSTART to $XEND, $YEND

mkdir $ZOOM

for ((X=$XSTART; X<=$XEND; X++))
do
	for ((Y=$YSTART; Y<=$YEND; Y++))
	do
		mkdir -p $ZOOM/$X
		wget -O $ZOOM/$X/$Y.png http://a.tile.openstreetmap.org/$ZOOM/$X/$Y.png
	done
done
