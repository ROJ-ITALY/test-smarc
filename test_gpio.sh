#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_PATTERN_0000)
			msg="Pattern 0000 check failed"
			;;
		$ERROR_PATTERN_1000)
			msg="Pattern 1000 check failed"
			;;
		$ERROR_PATTERN_0100)
			msg="Pattern 0100 check failed"
			;;
		$ERROR_PATTERN_0010)
			msg="Pattern 0010 check failed"
			;;
		$ERROR_PATTERN_0001)
			msg="Pattern 0001 check failed"
			;;
		*)
			msg="Unknown error"
			;;
	esac

	echo "$TEST - ERROR $1 ($msg)"

	gpio_deinit
	# exit from the script
	exit $1
}

#------------------------------------------------------------------------------
#	function success
#------------------------------------------------------------------------------
function success
{
	echo "$TEST - OK"

	gpio_deinit
	# exit from the script
	exit 0
}

#------------------------------------------------------------------------------
#	function gpio_init
#------------------------------------------------------------------------------
gpio_init() {

#gpio out
echo 78 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio78/direction
echo 72 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio72/direction
echo 39 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio39/direction
echo 170 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio170/direction

#gpio in
echo 77 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio77/direction
echo 71 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio71/direction
echo 167 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio167/direction
echo 171 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio171/direction

}

#------------------------------------------------------------------------------
#	function gpio_deinit
#------------------------------------------------------------------------------
gpio_deinit() {

echo 78 > /sys/class/gpio/unexport
echo 72 > /sys/class/gpio/unexport
echo 39 > /sys/class/gpio/unexport
echo 170 > /sys/class/gpio/unexport
echo 77 > /sys/class/gpio/unexport
echo 71 > /sys/class/gpio/unexport
echo 167 > /sys/class/gpio/unexport
echo 171 > /sys/class/gpio/unexport

}

#------------------------------------------------------------------------------
#	function gpio_write
#------------------------------------------------------------------------------
gpio_write () {
	STR=$1
	
	echo ${STR:0:1} > /sys/class/gpio/gpio78/value
	echo ${STR:1:1} > /sys/class/gpio/gpio72/value
	echo ${STR:2:1} > /sys/class/gpio/gpio39/value
	echo ${STR:3:1} > /sys/class/gpio/gpio170/value
}

#------------------------------------------------------------------------------
#	function gpio_read
#------------------------------------------------------------------------------
gpio_read () {
	STR=
	
	STR=${STR}$(cat /sys/class/gpio/gpio77/value)
	STR=${STR}$(cat /sys/class/gpio/gpio71/value)
	STR=${STR}$(cat /sys/class/gpio/gpio167/value)
	STR=${STR}$(cat /sys/class/gpio/gpio171/value)
		
	echo $STR
}

#------------------------------------------------------------------------------
#	function gpio_check
#------------------------------------------------------------------------------
gpio_check () {
	echo "check pattern: $1"
	gpio_write $1
	sleep 1
	if [ "$(gpio_read)" == "$1" ]
	then
		return 0
	else
		return 1
	fi
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_gpio

# list errors
ERROR_PATTERN_0000=1
ERROR_PATTERN_1000=2
ERROR_PATTERN_0100=3
ERROR_PATTERN_0010=4
ERROR_PATTERN_0001=5


gpio_init

if ! gpio_check "0000"
then
	error $ERROR_PATTERN_0000
fi

if ! gpio_check "1000"
then
	error $ERROR_PATTERN_1000
fi

if ! gpio_check "0100"
then
	error $ERROR_PATTERN_0100
fi

if ! gpio_check "0010"
then
	error $ERROR_PATTERN_0010
fi

if ! gpio_check "0001"
then
	error $ERROR_PATTERN_0001
fi

success
