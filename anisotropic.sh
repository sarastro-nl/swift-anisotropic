#!/bin/bash

if [ -z "`command -v convert`" ];then
    echo "convert is missing\n\nPlease install imagemagick with `brew install imagemagick`"
    exit 1
fi

if [ $# == 0 ];then
    echo "argument missing"
    exit 1
fi

if [ ! -f "$1" ];then
    echo "no such file: $1"
    exit 1
fi

FILE="$1"
WIDTH=`identify -format '%w' "$FILE"`
HEIGHT=`identify -format '%h' "$FILE"`
MIN=$(( $WIDTH < $HEIGHT ? $WIDTH : $HEIGHT ))
POWER=9 # 512
RES=$((2**$POWER))

convert "$FILE" -gravity center -extent ${MIN}x${MIN} square.ppm
convert -size ${RES}x${RES} xc: "$FILE".ppm

YPOS=0
YSCALE=${RES}
for i in `seq $POWER`;do
    YSCALE=$(($YSCALE / 2))
    XPOS=0
    XSCALE=${RES}
    for j in `seq $POWER`;do
        XSCALE=$(($XSCALE / 2))
        echo convert "$FILE".ppm square.ppm -geometry ${XSCALE}x${YSCALE}!+${XPOS}+${YPOS} -composite -depth 8 "$FILE".ppm
        XPOS=$(($XPOS + $XSCALE))
    done
    YPOS=$(($YPOS + $YSCALE))
done

rm -f square.ppm
