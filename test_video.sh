#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_INVALIDARGS)
			msg="Invalid arguments"
			;;
		$ERROR_FBFILL)
			msg="Error to draw color bars"
			;;
		$ERROR_READTIMEOUT)
			msg="Unexpected response"
			dd if=/dev/zero of=$FB 2>/dev/null
			;;
		$ERROR_TEST_FAIL)
			msg="Comparison failed"
			dd if=/dev/zero of=$FB 2>/dev/null
			;;
		*)
			msg="Unknown error"
			;;
	esac

	echo "$TEST - ERROR $1 ($msg)"

	# exit from the script
	exit $1
}

#------------------------------------------------------------------------------
#	function success
#------------------------------------------------------------------------------
function success
{
	echo "$TEST - OK"

	dd if=/dev/zero of=$FB 2>/dev/null
	
	# exit from the script
	exit 0
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_video

# list errors
ERROR_INVALIDARGS=1
ERROR_FBFILL=2
ERROR_READTIMEOUT=3
ERROR_TEST_FAIL=4

READ_TIMEOUT=10
BINDIR=$(dirname $0)

# default args
WIDTH=""
HEIGHT=""
BPP=""
FB=""

while getopts "w:h:d:f:" o
do
	case "$o"
	in
		w)	WIDTH=$OPTARG
			;;
		h) 	HEIGHT=$OPTARG
			;;
		d)	BPP=$OPTARG
			;;
		f)	FB=$OPTARG
			;;
		\?)
			error $ERROR_INVALIDARGS
			;;
	esac
done
shift $((OPTIND - 1))

if ! ${BINDIR}/fbfill $WIDTH $HEIGHT $BPP $FB
then
	error $ERROR_FBFILL
fi

if ! read -t $READ_TIMEOUT ACK
then
	error $ERROR_READTIMEOUT
fi

# ACK=0 --> test ok
# ACK=1 --> test fail

if [ $ACK -ne 0 ]
then
	error $ERROR_TEST_FAIL
fi

success
