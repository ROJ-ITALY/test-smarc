#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_I2C0_NOTFOUND)
			msg="Bus i2c 0 not found"
			;;
		$ERROR_I2C1_NOTFOUND)
			msg="Bus i2c 1 not found"
			;;
		$ERROR_I2C2_NOTFOUND)
			msg="Bus i2c 2 not found"
			;;
		$ERROR_TEST_FAIL)
			rm /tmp/i2c.out
			msg="Unexpected scan response"
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
	
	rm /tmp/i2c.out
	# exit from the script
	exit 0
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_i2c

# list errors
ERROR_I2C0_NOTFOUND=1
ERROR_I2C1_NOTFOUND=2
ERROR_I2C2_NOTFOUND=3
ERROR_TEST_FAIL=4

if [ ! -e /sys/class/i2c-dev/i2c-0 ]
then
	error $ERROR_I2C0_NOTFOUND""
fi

if [ ! -e /sys/class/i2c-dev/i2c-1 ]
then
	error $ERROR_I2C1_NOTFOUND
fi

if [ ! -e /sys/class/i2c-dev/i2c-2 ]
then
	error $ERROR_I2C2_NOTFOUND
fi

i2cdetect -y 0 > /tmp/i2c.out
i2cdetect -y 1 >> /tmp/i2c.out
i2cdetect -y 2 >> /tmp/i2c.out

if diff -q i2c.out /tmp/i2c.out
then
	success
else
	error $ERROR_TEST_FAIL
fi
