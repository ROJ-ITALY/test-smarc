#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_RW)
			msg="read-write eeprom failed"
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
#	function eeprom_readwrite
#------------------------------------------------------------------------------
eeprom_check() {

local value

value="0x0a"

#i2cset -f -y i2cbus chip-address data-address[16bit] value
#write the value 0x0a at the data-address 0x0000
i2cset -f -y 2 0x50 0x00 0x00 $value i
sleep 1
i2cset -f -y 2 0x50 0x00 0x00

#i2cget -f -y i2cbus chip-address data-address
#read the value at the data-address 0x0000
if [ "$(i2cget -f -y 2 0x50)" == "$value" ]
	then
		i2cset -f -y 2 0x50 0x00 0x00 0xff i
		return 0
	else
		i2cset -f -y 2 0x50 0x00 0x00 0xff i
		return 1
	fi
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_eeprom

# list errors
ERROR_RW=1


if ! eeprom_check
then
	error $ERROR_RW
fi

success
