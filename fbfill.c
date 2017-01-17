#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char * argv[])
{
	int x, y, sx, sy, bpp, fd, sxred, sxgreen, sxblue;
	static const unsigned char red[] = { 255, 0, 0, 0 };
	static const unsigned char green[] = { 0, 255, 0, 0 };
	static const unsigned char blue[] = { 0, 0, 255, 0 };

	if (argc != 5)
	{
		printf("Invalid arguments\n");
		exit(-1);
	}
	
	sx = atoi(argv[1]);
	sy = atoi(argv[2]);
	bpp = atoi(argv[3]);

	sxred = sxgreen = sx / 3;
	sxblue = sx - sxred -sxgreen;

	fd = open(argv[4], O_WRONLY);
	if (fd < 0)
	{
		printf("Opening error\n");
		exit(-2);
	}

	for (y=0; y<sy; y++)
	{
		for (x=0; x<sxred; x++)
			write(fd, red, bpp / 8);
		for (x=0; x<sxgreen; x++)
			write(fd, green, bpp / 8);
		for (x=0; x<sxblue; x++)
			write(fd, blue, bpp / 8);	
	}
	
	close(fd);
}
