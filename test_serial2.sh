#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_INVALIDARG)
			msg="Invalid argument"
			;;
		$ERROR_MISSINGDEV)
			msg="Missing device"
			;;
		$ERROR_READTIMEOUT)
			msg="Read timeout"
			;;
		$ERROR_RXVALUE)
			msg="Bad Rx value"
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
	exec 5<&-
	exec 6<&-
	# exit from the script
	exit 0
}

#------------------------------------------------------------------------------
#	function send_and_check
#------------------------------------------------------------------------------
send_and_check() {

	local DEV=$1

	if [ -e $DEV ]
	then
		stty -F $DEV 115200 sane -echo
		
		exec 5<$DEV
		exec 6>$DEV
		
		echo "0123456789ABCDEF" >&6
		
		if read -u 5 -t $READ_TIMEOUT RESULT
		then
			if [ "$RESULT" == "0123456789ABCDEF" ]
			then
				success
			else
				error $ERROR_RXVALUE
			fi
		else
			error $ERROR_READTIMEOUT
		fi
	else
		error $ERROR_MISSINGDEV
	fi

}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_serial2

# list errors
ERROR_INVALIDARG=1
ERROR_MISSINGDEV=2
ERROR_READTIMEOUT=3
ERROR_RXVALUE=4

PORTDEV=/dev/ttymxc3
READ_TIMEOUT=10
BINDIR=$(dirname $0)

# analizza argomenti
while getopts "p:" o
do
	case "$o"
	in
		p) PORTDEV=$OPTARG
			;;
		\?)
			error $ERROR_INVALIDARG
			;;
	esac
done
shift $((OPTIND - 1))

send_and_check $PORTDEV
