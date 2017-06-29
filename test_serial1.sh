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

	local TX=$1
	local RX=$2

	if [ -e $TX ] && [ -e $RX ]
	then
		if [ "$TX" == "/dev/ttymxc0" ]
		then
			echo 128 > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio128/direction
			echo "1" > /sys/class/gpio/gpio128/value
			echo 128 > /sys/class/gpio/unexport
			echo 79 > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio79/direction
			echo "0" > /sys/class/gpio/gpio79/value
			echo 79 > /sys/class/gpio/unexport
		else
			echo 128 > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio128/direction
			echo "0" > /sys/class/gpio/gpio128/value
			echo 128 > /sys/class/gpio/unexport
			echo 79 > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio79/direction
			echo "1" > /sys/class/gpio/gpio79/value
			echo 79 > /sys/class/gpio/unexport
		fi

		stty -F $TX 115200 sane -echo
		stty -F $RX 115200 sane -echo
		
		exec 5<$RX
		exec 6>$TX
		
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
TEST=test_serial1

# list errors
ERROR_INVALIDARG=1
ERROR_MISSINGDEV=2
ERROR_READTIMEOUT=3
ERROR_RXVALUE=4

PORTDEV1=/dev/ttymxc0
PORTDEV2=/dev/ttymxc2
READ_TIMEOUT=10
BINDIR=$(dirname $0)

# analizza argomenti
while getopts "t:r:" o
do
	case "$o"
	in
		t) PORTDEV1=$OPTARG
			;;
		r) PORTDEV2=$OPTARG
			;;
		\?)
			error $ERROR_INVALIDARG
			;;
	esac
done
shift $((OPTIND - 1))

send_and_check $PORTDEV1 $PORTDEV2
