#!/bin/bash

#------------------------------------------------------------------------------
#	error
#------------------------------------------------------------------------------
error ()
{
	local msg

	case $1 in
		$ERROR_INVALIDARGS)
			msg="Invalid arguments"
			;;
		$ERROR_IFISUP)
			msg="Interface is not up"
			;;
		$ERROR_IFNOTFOUND)
			msg="Interface not found"
			;;
		$ERROR_DHCP)
			msg="DHCP failed"
			;;
		$ERROR_PINGFAILED)
			msg="Ping failed"
			;;
		*)
			msg="Unknown error"
			;;
	esac

	echo "$TEST - ERROR $1 ($msg)"

	if [ -e /sys/class/net/$IF ]
	then
	 	ip link set $IF down
	fi

	exit $1
}

#------------------------------------------------------------------------------
#	success
#------------------------------------------------------------------------------
success ()
{
	echo "$TEST - OK"

	if [ -e /sys/class/net/$IF ]
	then
	 	ip link set $IF down
	fi

	exit 0
}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_ethernet

# list errors
ERROR_INVALIDARGS=1
ERROR_IFISUP=2
ERROR_IFNOTFOUND=3
ERROR_DHCP=4
ERROR_PINGFAILED=5

# default args
IF=eth0
DEST=192.168.241.1
while getopts "i:d:" o
do
	case "$o"
	in
		i)	IF=$OPTARG
			;;
		d) 	DEST=$OPTARG
			;;
		\?)
			error $ERROR_INVALIDARGS
			;;
	esac
done
shift $((OPTIND - 1))

echo "- Test interface $IF presence"
if [ -e /sys/class/net/$IF ]
then
	ip link set $IF up
	echo "- Test interface $IF is up"
	if ! ip link show up | grep -q $IF
	then
		error $ERROR_IFISUP
	fi

	echo "- Ip address request"
	if ! udhcpc -n -q -i $IF > /dev/null
	then
		error $ERROR_DHCP
	fi

	echo "- Ping $DEST"
	if ping -I $IF -c 3 $DEST > /dev/null
	then
		success
	else
		error $ERROR_PINGFAILED
	fi
else
	error $ERROR_IFNOTFOUND
fi

