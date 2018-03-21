import sys
import fcntl
import struct
import io
import time

I2C_SLAVE = 0x0703
I2C_ADDR = 0x64

# Error dictionary
err_dict = {
	'ERR_OPEN': 1,
	'ERR_WRITE': 2,
	'ERR_WAKEUP': 3,
	'ERR_TEST': 4
}

# Calculate CRC
def crc16(data):
	crc_register = 0
	polynomial = 0x8005
	for c in data:
		for shift_register in 1, 2, 4, 8, 16, 32, 64, 128:
			data_bit = 1 if (c & shift_register) > 0 else 0
			crc_bit = crc_register >> 15
			crc_register = (crc_register << 1) & 0xFFFF
			if (data_bit ^ crc_bit) != 0:
				crc_register ^= polynomial
	return crc_register

# Open communication with device I2C SHA204
def open():
	fr = io.open('/dev/i2c-2', 'rb', buffering=0)
	fw = io.open('/dev/i2c-2', 'wb', buffering=0)
	if ( fcntl.ioctl(fr, I2C_SLAVE, I2C_ADDR) < 0 ):
		print('ERR: Open device I2C SHA204 failed (read channel)')
		sys.exit(err_dict['ERR_OPEN'])
	if ( fcntl.ioctl(fw, I2C_SLAVE, I2C_ADDR) < 0 ):
		print('ERR: Open device I2C SHA204 failed (write channel)')
		sys.exit(err_dict['ERR_OPEN'])
	return fr, fw

# Close communication with device I2C SHA204
def close(fd):
	fr = fd[0]
	fw = fd[1]
	fr.close()
	fw.close()

# Write  
def write(fd, wordAddr, ba=None):
	fw = fd[1]
	if ba != None:
		lenght = 4 + len(ba)
		buffer = struct.pack('<BB%ds' % len(ba), wordAddr, lenght-1, ba)
		crc = crc16(buffer[1:])
		frame = struct.pack('<%dsH' % len(buffer), buffer, crc)
	else:
		lenght = 1
		frame = wordAddr	
	if ( fw.write(frame) != len(frame) ):
		print('ERR: Error byte written')
		close(fd)
		sys.exit(err_dict['ERR_WRITE'])

# Read
def read(fr):
	lenght = int.from_bytes( fr.read(1), byteorder='big' )
	buffer = fr.read(lenght-1)
	return buffer

# Read ConfigZone
def readConfig(fd, index):
	fr = fd[0]
	fw = fd[1]
	wordAddr = 0x03
	opCode = 0x02
	zone = 0x00
	addr = index
	ba = struct.pack('<BBH', opCode, zone, addr)
	write(fd, wordAddr, ba)
	time.sleep(0.01)
	ba = read(fr)
	return ba

# Sleep command
def sleep(fd):
	try:
		write(fd, b'\x01')
	except OSError:
		pass

# Wakeup command
def wakeup(fd):
	try:
		fr = fd[0]
		write(fd, b'\x00')
		ba = read(fr)
		if( ba[0] != 0x11 ):
			print('ERR: Wake up error')
			close(fd)
			sys.exit(err_dict['ERR_WAKEUP'])
	except OSError:
		pass

# Read ConfigZone at index 0x00 	
def config():
	fd= open()
	sleep(fd);
	time.sleep(0.01)
	wakeup(fd);
	time.sleep(0.01)
	index = 0x00
	ba = readConfig(fd, index)
	if ( ba[0] == 0x01 and ba[1] == 0x23 ):
		print('OK')
		close(fd)
		sys.exit(0)
	else:
		print('ERR: Test ConfigZone failed')
		close(fd)
		sys.exit(err_dict['ERR_TEST'])
	
# Main
config()
