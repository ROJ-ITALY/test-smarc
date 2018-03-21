#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

# list errors defined in python script
ERR_OPEN=1
ERR_WRITE=2
ERR_WAKEUP=3
ERR_TEST=4
	
	case $1 in
		$ERR_OPEN)
			msg="ERR: Open device I2C SHA204 failed (read/write channel)"
			;;
		$ERR_WRITE)
			msg="ERR: Error byte written"
			;;
		$ERR_WAKEUP)
			msg="ERR: Wake up error"
			;;
		$ERR_TEST)
			msg="ERR: Test ConfigZone failed"
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
TEST=test_sha204


# Run python script to read ConfigZone (first two bytes)
/opt/tools/sha204.py
ret=$?
if [ $ret == 0 ]
then
	success
else
	error $ret
fi
