#!/bin/bash

#------------------------------------------------------------------------------
#	function error
#------------------------------------------------------------------------------
function error
{

	local msg

	case $1 in
		$ERROR_LCD_DUAL_PCK)
			msg="AFB5_IN - LCD_DUAL_PCK"
			;;
		$ERROR_USB1_EN_OC)
			msg="PCIE_A_CKREQ - USB1_EN_OC"
			;;
		$ERROR_SER2_CTS)
			msg="EIM_AD15 - SER2_CTS"
			;;
		$ERROR_SER0_CTS)
			msg="EIM_WAIT - SER0_CTS"
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
gpio_init () {

#gpio in
echo 38 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio38/direction
echo 35 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio35/direction
echo 79 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio79/direction
echo 128 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio128/direction

}

#------------------------------------------------------------------------------
#	function gpio_deinit
#------------------------------------------------------------------------------
gpio_deinit () {

echo 38 > /sys/class/gpio/unexport
echo 35 > /sys/class/gpio/unexport
echo 79 > /sys/class/gpio/unexport
echo 128 > /sys/class/gpio/unexport

}

#------------------------------------------------------------------------------
#	main script
#------------------------------------------------------------------------------
TEST=test_spare_pin

# list errors
ERROR_LCD_DUAL_PCK=1
ERROR_USB1_EN_OC=2
ERROR_SER2_CTS=3
ERROR_SER0_CTS=4

gpio_init

# test short between AFB5_IN (GPIO2_IO06) - LCD_DUAL_PCK
value=$(cat /sys/class/gpio/gpio38/value)
if [ "$value" != "1" ]
then
	error $ERROR_LCD_DUAL_PCK
fi

# test short between PCIE_A_CKREQ (GPIO2_IO03) - USB1_EN_OC
value=$(cat /sys/class/gpio/gpio35/value)
if [ "$value" != "1" ]
then
	error $ERROR_USB1_EN_OC
fi

# test short between EIM_AD15 (GPIO3_IO15) - SER2_CTS
value=$(cat /sys/class/gpio/gpio79/value)
if [ "$value" != "0" ]
then
	error $ERROR_SER2_CTS
fi

# test short between EIM_WAIT (GPIO5_IO00) - SER0_CTS
value=$(cat /sys/class/gpio/gpio128/value)
if [ "$value" != "0" ]
then
	error $ERROR_SER0_CTS
fi

success
