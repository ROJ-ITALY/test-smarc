#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_NO_SD_DEVICE)
			msg="No SD device plugged"
			;;
		$ERROR_TEST_SD)
			msg="Test read/write on SD device failed"
			rm -f /tmp/test.txt /tmp/dump1 /tmp/dump2
			dd if=/dev/zero of=$dev bs=1024 count=1 seek=25118 2> /dev/null
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

	rm -f /tmp/test.txt /tmp/dump1 /tmp/dump2
	dd if=/dev/zero of=$dev bs=1024 count=1 seek=25118 2> /dev/null

	# exit from the script
	exit 0
}

#------------------------------------------------------------------------------
#	function disk_check
#------------------------------------------------------------------------------
function disk_check
{
	if [ -e /dev/mmcblk0 ]
	then
		echo "- SD device plugged."
		dev="/dev/mmcblk0"
	else
		error $ERROR_NO_SD_DEVICE
	fi

	echo -n "0123456789ABCDEF" > /tmp/test.txt
	dd if=/tmp/test.txt of=$dev bs=1024 count=1 seek=25118 2> /dev/null
	hexdump /tmp/test.txt -n 16 -e '1/1 "%.2x"' > /tmp/dump1
	hexdump $dev -s $((1024*25118)) -n 16 -e '1/1 "%.2x"' > /tmp/dump2
	if diff -q /tmp/dump1 /tmp/dump2
	then
		success
	else
		error $ERROR_TEST_SD
	fi
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_sd

# list errors
ERROR_NO_SD_DEVICE=1
ERROR_TEST_SD=2

dev=""
disk_check
