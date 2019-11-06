#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_SPI_NOT_FOUND)
			msg="spi flash memory w25x20 not found"
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
TEST=test_spi

# list errors
ERROR_SPI_NOT_FOUND=1

dmesg | grep -q w25x20
ret=$?

if [ "$ret" != "0" ]
then
	error $ERROR_SPI_NOT_FOUND
else
	success
fi
