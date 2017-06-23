#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	msg="Pattern $1 check failed"
	echo "$TEST - ERROR 1 ($msg)"

	gpio_deinit
	# exit from the script
	exit 1
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
gpio_init () {

#gpio out
echo 78 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio78/direction
echo 72 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio72/direction
echo 39 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio39/direction
echo 170 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio170/direction
echo 149 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio149/direction
echo 148 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio148/direction

#gpio in
echo 77 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio77/direction
echo 71 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio71/direction
echo 167 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio167/direction
echo 171 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio171/direction
echo 94 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio94/direction
echo 95 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio94/direction
echo 106 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio106/direction
echo 169 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio169/direction

}

#------------------------------------------------------------------------------
#	function gpio_deinit
#------------------------------------------------------------------------------
gpio_deinit () {

echo 78 > /sys/class/gpio/unexport
echo 72 > /sys/class/gpio/unexport
echo 39 > /sys/class/gpio/unexport
echo 170 > /sys/class/gpio/unexport
echo 77 > /sys/class/gpio/unexport
echo 71 > /sys/class/gpio/unexport
echo 167 > /sys/class/gpio/unexport
echo 171 > /sys/class/gpio/unexport
echo 94 > /sys/class/gpio/unexport
echo 95 > /sys/class/gpio/unexport
echo 149 > /sys/class/gpio/unexport
echo 106 > /sys/class/gpio/unexport
echo 148 > /sys/class/gpio/unexport
echo 169 > /sys/class/gpio/unexport

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
	PCAM_ON_CSI1=$(echo ${STR:4:1})
	if [ $PCAM_ON_CSI1 -eq 1 ]
	then	
		i2cset -f -y 2 0x04 0x00 0x08
	fi
	PCAM_ON_CSI0=$(echo ${STR:5:1})
	if [ $PCAM_ON_CSI0 -eq 1 ]
	then
		i2cset -f -y 2 0x04 0x00 0x04
	fi
	CHARGING=$(echo ${STR:6:1})
	if [ $CHARGING -eq 1 ]
	then
		i2cset -f -y 2 0x04 0x00 0x00
		echo ${STR:6:1} > /sys/class/gpio/gpio149/value
	else
		echo ${STR:6:1} > /sys/class/gpio/gpio149/value
	fi
	echo ${STR:7:1} > /sys/class/gpio/gpio148/value

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
	STR=${STR}$(cat /sys/class/gpio/gpio94/value)		
	STR=${STR}$(cat /sys/class/gpio/gpio95/value)
	STR=${STR}$(cat /sys/class/gpio/gpio106/value)
	STR=${STR}$(cat /sys/class/gpio/gpio169/value)
	
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

NUM_SHORT=8
COUNTER=0

while [ $COUNTER -lt $NUM_SHORT ]; do
	PATTERN_ARRAY[$COUNTER]="0"
	let COUNTER=COUNTER+1
done
PATTERN=$(echo "${PATTERN_ARRAY[*]}" | tr -d '[:space:]')

gpio_init

if ! gpio_check $PATTERN
then
	error $PATTERN
fi

for i in `seq 0 $(($NUM_SHORT-1))`;
do
	if [ $i -eq 0 ]
	then
		PATTERN_ARRAY[$i]="1"
		PATTERN=$(echo "${PATTERN_ARRAY[*]}" | tr -d '[:space:]')
		if ! gpio_check $PATTERN
		then
			error $PATTERN
		fi
	else
		PATTERN_ARRAY[$(($i-1))]="0"
		PATTERN_ARRAY[$i]="1"
		PATTERN=$(echo "${PATTERN_ARRAY[*]}" | tr -d '[:space:]')
		if ! gpio_check $PATTERN
		then
			error $PATTERN
		fi
	fi
done

success
