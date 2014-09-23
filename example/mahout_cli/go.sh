#!/bin/bash

. etc/common.env
export OPT_VCT=''
ALGO=2

if   [ "$1" = "model" ]; then
	sh bin/model.sh $ALGO
elif [ "$1" = "test" ] ; then
	sh bin/test.sh  $ALGO
elif [ "$1" = "all" ]  ; then
	sh bin/model.sh $ALGO
	sh bin/test.sh  $ALGO
else
	echo "Think before Typing !!"
fi
