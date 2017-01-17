#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_IFUP)
			msg="Error to activate $IF interface"
			;;
		$ERROR_IFDOWN)
			msg="Error to deactivate $IF interface"
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

	# exit from the script
	exit 0
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_wifi

# default args
IF=wlan0

# list errors
ERROR_IFUP=1
ERROR_IFDOWN=2

# activate WiFi interface
echo "- $IF up"
if ! ip link set $IF up
then
	error $ERROR_IFUP
fi

# deactivate WiFi interface
echo "- $IF down"
if ! ip link set $IF down
then
	error $ERROR_IFDOWN
fi

success
