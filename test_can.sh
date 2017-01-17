#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_RESPONSE_FROM_CAN1)
			msg="Unexpected response from can1"
			;;
		$ERROR_RESPONSE_FROM_CAN0)
			msg="Unexpected response from can0"
			;;
		*)
			msg="Unknown error"
			;;
	esac

	echo "$TEST - ERROR $1 ($msg)"

	rm /tmp/cantest.txt	
	ip link set can0 down
	ip link set can1 down

	# exit from the script
	exit $1
}

#------------------------------------------------------------------------------
#	function success
#------------------------------------------------------------------------------
function success
{
	echo "$TEST - OK"

	rm /tmp/cantest.txt	
	ip link set can0 down
	ip link set can1 down

	# exit from the script
	exit 0
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_can

# list errors
ERROR_RESPONSE_FROM_CAN1=1
ERROR_RESPONSE_FROM_CAN0=2

ip link set can0 up type can bitrate 125000 2> /dev/null
ip link set can1 up type can bitrate 125000 2> /dev/null

candump can0 > /tmp/cantest.txt &
cansend can1 -i 0x5a1 0x0a 0x0b 0x0c

RESULT=$(cat /tmp/cantest.txt | tail -n 1)
	
if [ "$RESULT" == "<0x5a1> [3] 0a 0b 0c " ]
then
	candump can1 > /tmp/cantest.txt &
	cansend can0 -i 0x5a1 0x0a 0x0b 0x0c
		
	RESULT=$(cat /tmp/cantest.txt | tail -n 1)
		
	if [ "$RESULT" == "<0x5a1> [3] 0a 0b 0c " ]
	then
		success
	else
		error $ERROR_RESPONSE_FROM_CAN1
	fi
else
	error $ERROR_RESPONSE_FROM_CAN0
fi

