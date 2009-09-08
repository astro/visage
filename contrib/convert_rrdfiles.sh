#!/bin/bash

if [ "$3" = "" ]; then
    echo "Usage: $0 <export|import> <source-rrdfiles> <dest-rrdfiles>"
    exit -1
fi

direction=$1
from=$2
to=$3

function md {
    mkdir $@ 2> /dev/null
}

for hostdir in $from/*; do
    host=`basename $hostdir`
    md $to/$host
    for plugindir in $hostdir/*; do
	plugin=`basename $plugindir`
	echo $host $plugin
	md $to/$host/$plugin
	if [ $direction = "import" ]; then
	    for infile in $plugindir/*.xml; do
		infile_fixed=$infile.fixed
		rrdfile=$to/$host/$plugin/$(basename $infile|sed -e 's/\..*//').rrd
		echo "$infile → $rrdfile"
		sed -e "s/<\!-- .* -->//g" < $infile > $infile_fixed
		rm $rrdfile
		rrdtool restore $infile_fixed $rrdfile
		rm $infile_fixed
	    done
	elif [ $direction = "export" ]; then
	    for rrdfile in $plugindir/*.rrd; do
		outfile=$to/$host/$plugin/$(basename $rrdfile|sed -e 's/\..*//').xml
		echo "$rrdfile → $outfile"
		rrdtool dump $rrdfile > $outfile
	    done
	fi
    done
done
