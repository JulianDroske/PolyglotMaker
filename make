#!/bin/sh
# Usage: ./make [unzipForARM] [unzipForX86] [ZipFile] [outputFile] [autoScriptPath]

ECHO(){
	echo -n $*
}

echo '#!/bin/sh' >"$4"
if [ "$5" != "" ];then
	echo "#$5" >>"$4"
fi

cat "$0" |tail -n +35 >>"$4"

TMPFILE="/tmp/unpackinf.tmp"

echo "" >"$TMPFILE"


for x in $1 $2 $3;do
	# du --bytes -0 $4 |grep -o -a -z "[0-9]" >>$TMPFILE
	stat --printf %s $4 >>$TMPFILE
	ECHO "," >>$TMPFILE
	# du --bytes -0 $x |grep -o -a -z "[0-9]" >>$TMPFILE
	stat --printf %s $x >>$TMPFILE
	ECHO ";" >>$TMPFILE
	cat $x >>$4
done

cat $TMPFILE >>$4
chmod +x $4
# /bin/sh -c "$(dirname $4)/$4"
exit


# Main Data Extractor
# By: JulianDroid
# 2019.8.8

ECHO(){
	echo -n $*
}

WKDIR="$(dirname $0)"
cd $WKDIR

# Read Offsets
# Format:
# 	$offsetStart,$Size;$offsetStart,$Size;$offsetStart,$Size
# 	# arm,x86,main
OFFSETS="$(cat $0 |tail -n 1)"

OFS=	# Start
SIZE=	# Size

# Args: 1
initOffset(){
	pso="$1"
	if [ $pso = "arm" ];then
		OFF="$(ECHO $OFFSETS |cut -d ';' -f 1)"
	elif [ $pso = "x86" ];then
		OFF="$(ECHO $OFFSETS |cut -d ';' -f 2)"
	elif [ $pso = "bdy" ];then
		OFF="$(ECHO $OFFSETS |cut -d ';' -f 3)"
	fi
	OFS="$(echo $OFF |cut -f1 -d ',')"
	SIZE="$(echo $OFF |cut -f2 -d ',')"
}

DUMPFILE="dumpedoofile.zip"	# unpacked
ECHO "" >$DUMPFILE

# Uses: $OFS,$SIZE
unpack(){
	ECHO "" >$DUMPFILE
	dd if="$0" of="$DUMPFILE" skip="$OFS" bs=1 count="$SIZE"
}

# Processor Reco
PSO="$(uname -m)"

initOffset "$(expr substr $PSO 1 3)"
unpack

if [ -f unzip ];then
	rm -rf unzip
fi
mv $DUMPFILE unzip
chmod +x unzip

initOffset "bdy"
unpack

CMDLINE="$(cat $0 |head -n 2 |tail -n 1 |tail -c +2)"
if [ "$CMDLINE" = "" ];then
	CMDLINE="echo"
fi
./unzip $DUMPFILE && $CMDLINE
exit
