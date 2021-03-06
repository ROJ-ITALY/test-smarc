#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_NO_USB_DEVICE)
			msg="No usb device plugged"
			;;
		$ERROR_TEST_USB)
			msg="Test read/write on usb device failed"
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
	if [ -e /dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.1:1.0-scsi-0:0:0:0 ]
	then
		echo "- USB device connected to USB-1 port."
		dev="/dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.1:1.0-scsi-0:0:0:0"
	elif [ -e /dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.2:1.0-scsi-0:0:0:0 ]
	then
		echo "- USB device connected to USB-2 port."
		dev="/dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.2:1.0-scsi-0:0:0:0"
	elif [ -e /dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.3:1.0-scsi-0:0:0:0 ]
	then
		echo "- USB device connected to USB-3 port."
		dev="/dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.3:1.0-scsi-0:0:0:0"
	elif [ -e /dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.4:1.0-scsi-0:0:0:0 ]
	then
		echo "- USB device connected to USB-4 port."
		dev="/dev/disk/by-path/platform-ci_hdrc.1-usb-0:1.1.4:1.0-scsi-0:0:0:0"
	else
		error $ERROR_NO_USB_DEVICE
	fi

	echo -n "0123456789ABCDEF" > /tmp/test.txt
	dd if=/tmp/test.txt of=$dev bs=1024 count=1 seek=25118 2> /dev/null
	hexdump /tmp/test.txt -n 16 -e '1/1 "%.2x"' > /tmp/dump1
	hexdump $dev -s $((1024*25118)) -n 16 -e '1/1 "%.2x"' > /tmp/dump2
	if diff -q /tmp/dump1 /tmp/dump2
	then
		success
	else
		error $ERROR_TEST_USB
	fi
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_usb1

# list errors
ERROR_NO_USB_DEVICE=1
ERROR_TEST_USB=2

dev=""
disk_check
