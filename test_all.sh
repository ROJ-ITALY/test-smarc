#!/bin/bash

# Script to test SMARC module
# Syntax: ./test_all.sh <args>
# where <args> can be an empty string (in this case will be run all tests) or the list of the specific tests to run.

#------------------------------------------------------------------------------
#	function success
#------------------------------------------------------------------------------
function success
{
	echo -e "\e[92m[OK]\e[39m"
}

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{
	echo -e "\e[91m[FAIL]\e[39m"
	exit -1
}

#------------------------------------------------------------------------------
#	function test_title
#------------------------------------------------------------------------------
function test_title
{
	echo "--------------------"
	echo " Test $1"
	echo "--------------------"
}


#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------

BINDIR=$(dirname $0)

TEST_USB1=0
TEST_USB2=0
TEST_SATA=0
TEST_SD=0
TEST_WIFI=0
TEST_CAN=0
TEST_ETHERNET=0
TEST_I2C=0
TEST_VIDEO=0
TEST_SERIAL1=0
TEST_SERIAL2=0
TEST_GPIO=0
TEST_EEPROM=0
TEST_SPARE_PIN=0
TEST_SPI=0
TEST_SHA204=0

if [ $# -eq 0 ]
then
	TEST_USB1=1
	TEST_USB2=1
	TEST_SATA=1
	TEST_SD=1
	TEST_WIFI=1
	TEST_CAN=1
	TEST_ETHERNET=1
	TEST_I2C=1
	TEST_VIDEO=1
	TEST_SERIAL1=1
	TEST_SERIAL2=1
	TEST_GPIO=1
	TEST_EEPROM=1
	TEST_SPARE_PIN=1
	TEST_SPI=1
	TEST_SHA204=1
else
	for var in "$@"
	do
		case "$var" in
			usb1)
				TEST_USB1=1
				;;
			usb2)
				TEST_USB2=1
				;;
			sata)
				TEST_SATA=1
				;;
			sd)
				TEST_SD=1
				;;
			wifi)
				TEST_WIFI=1
				;;
			can)
				TEST_CAN=1
				;;
			ethernet)
				TEST_ETHERNET=1
				;;
			i2c)
				TEST_I2C=1
				;;
			video)
				TEST_VIDEO=1
				;;
			serial1)
				TEST_SERIAL1=1
				;;
			serial2)
				TEST_SERIAL2=1
				;;
			gpio)
				TEST_GPIO=1
				;;
			eeprom)
				TEST_EEPROM=1
				;;
			spare_pin)
				TEST_SPARE_PIN=1
				;;
			spi)
				TEST_SPI=1
				;;
			sha204)
				TEST_SHA204=1
			*)
				echo -e "\e[91mtest_all: Invalid command line argument.\e[39m"
				;;
		esac
	done
fi

if [ $TEST_USB1 -ne 0 ]
then
	test_title "usb1"
	# run test_usb1
	if ${BINDIR}/test_usb1.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_USB2 -ne 0 ]
then
	test_title "usb2"
	# run test_usb2
	if ${BINDIR}/test_usb2.sh
	then
		success
	else
		error
	fi
fi

MACHINE=$(cat /etc/hostname)
if [ "$MACHINE" == "imx6qenuc" ]
then
	if [ $TEST_SATA -ne 0 ]
	then
		test_title "sata"
		# run test_sata
		if ${BINDIR}/test_sata.sh
		then
			success
		else
			error
		fi
	fi
fi

if [ $TEST_SD -ne 0 ]
then
	test_title "sd"
	# run test_sd
	if ${BINDIR}/test_sd.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_WIFI -ne 0 ]
then
	test_title "wifi"
	# run test_wifi
	if ${BINDIR}/test_wifi.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_CAN -ne 0 ]
then
	test_title "can"
	# run test_can
	if ${BINDIR}/test_can.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_ETHERNET -ne 0 ]
then
	test_title "ethernet eth0"
	# run test_ethernet eth0
	if ${BINDIR}/test_ethernet.sh -i eth0 -d 8.8.8.8
	then
		success
	else
		error
	fi
	test_title "ethernet enp1s0"
	# run test_ethernet enp1s0
	if ${BINDIR}/test_ethernet.sh -i enp1s0 -d 8.8.8.8
	then
		success
	else
		error
	fi
fi

if [ $TEST_I2C -ne 0 ]
then
	test_title "i2c"
	# run test_i2c
	if ${BINDIR}/test_i2c.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_VIDEO -ne 0 ]
then
	test_title "video lvds"
	# run test_video display lvds 800x600
	if ${BINDIR}/test_video.sh -w 800 -h 600 -d 32 -f /dev/fb0
	then
		success
	else
		error
	fi
	test_title "video hdmi"
	echo 0 > /sys/class/graphics/fb2/blank 2>/dev/null
	fbset -fb /dev/fb2 -g 800 480 800 480 32
	if ${BINDIR}/test_video.sh -w 800 -h 480 -d 32 -f /dev/fb2
	then
		success
	else
		error
	fi
fi

if [ $TEST_SERIAL1 -ne 0 ]
then
	test_title "ser0 - ser2"
	# run test_serial1 ser0 - ser2
	if ${BINDIR}/test_serial1.sh -t /dev/ttymxc0 -r /dev/ttymxc2
	then
		success
	else
		error
	fi
	test_title "ser2 - ser0"
	# run test_serial1 ser2 - ser0
	if ${BINDIR}/test_serial1.sh -t /dev/ttymxc2 -r /dev/ttymxc0
	then
		success
	else
		error
	fi
fi

if [ $TEST_SERIAL2 -ne 0 ]
then
	test_title "ser3"
	# run test_serial2 ser3
	if ${BINDIR}/test_serial2.sh -p /dev/ttymxc3
	then
		success
	else
		error
	fi
fi

if [ $TEST_GPIO -ne 0 ]
then
	test_title "gpio"
	# run test_gpio
	if ${BINDIR}/test_gpio.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_EEPROM -ne 0 ]
then
	test_title "eeprom"
	# run test_eeprom
	if ${BINDIR}/test_eeprom.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_SPARE_PIN -ne 0 ]
then
	test_title "spare_pin"
	# run test_spare_pin
	if ${BINDIR}/test_spare_pin.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_SPI -ne 0 ]
then
	test_title "spi"
	# run test_spi
	if ${BINDIR}/test_spi.sh
	then
		success
	else
		error
	fi
fi

if [ $TEST_SHA204 -ne 0 ]
then
	test_title "sha204"
	# run test_sha204
	if ${BINDIR}/test_sha204.sh
	then
		success
	else
		error
	fi
fi
# add other tests...
