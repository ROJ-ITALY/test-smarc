DESTDIR ?=

GIT_VERSION := $(shell git describe --dirty --always --tags)

.PHONY: all
all: version fbfill

fbfill: fbfill.c
	$(CC) -o $@ $<

.PHONY: distclean
.PHONY: clean
distclean clean:
	$(RM) fbfill
	$(RM) version
	$(RM) *.o

.PHONY: install
install:
	install -d $(DESTDIR)/opt/tools
	install -m 755 fbfill $(DESTDIR)/opt/tools
	install -m 644 version $(DESTDIR)/opt/tools
	install -m 755 test_all.sh $(DESTDIR)/opt/tools
	install -m 755 test_usb1.sh $(DESTDIR)/opt/tools
	install -m 755 test_usb2.sh $(DESTDIR)/opt/tools
	install -m 755 test_sata.sh $(DESTDIR)/opt/tools
	install -m 755 test_sd.sh $(DESTDIR)/opt/tools
	install -m 755 test_wifi.sh $(DESTDIR)/opt/tools
	install -m 755 test_can.sh $(DESTDIR)/opt/tools
	install -m 755 test_ethernet.sh $(DESTDIR)/opt/tools
	install -m 755 test_i2c.sh $(DESTDIR)/opt/tools
	install -m 755 i2c.out $(DESTDIR)/opt/tools
	install -m 755 test_video.sh $(DESTDIR)/opt/tools
	install -m 755 test_serial1.sh $(DESTDIR)/opt/tools
	install -m 755 test_serial2.sh $(DESTDIR)/opt/tools
	install -m 755 test_gpio.sh $(DESTDIR)/opt/tools
	install -m 755 test_eeprom.sh $(DESTDIR)/opt/tools
	install -m 755 test_spare_pin.sh $(DESTDIR)/opt/tools

.PHONY: force
version: force
	echo '$(GIT_VERSION)' | cmp -s - $@ || echo '$(GIT_VERSION)' > $@
