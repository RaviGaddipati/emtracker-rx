/*
 * IMU.xc
 *
 *  Created on: Dec 28, 2014
 *      Author: Ravi
 */
#include <xs1.h>
#include <xclib.h>
#include "IMU.h"

int readAccelX(struct r_i2c &i2c);
int readAccelY(struct r_i2c &i2c);
int readAccelZ(struct r_i2c &i2c);
int readGyroX(struct r_i2c &i2c);
int readGyroY(struct r_i2c &i2c);
int readGyroZ(struct r_i2c &i2c);
int readMagX(struct r_i2c &i2c);
int readMagY(struct r_i2c &i2c);
int readMagZ(struct r_i2c &i2c);


void sensorUpdate(struct r_i2c &i2c, streaming chanend output) {
	long vals[9];
	while (1) {
		vals[0] = (long)readAccelX(i2c);
		vals[1] = (long)readAccelY(i2c);
		vals[2] = (long)readAccelZ(i2c);
		vals[3] = (long)readGyroX(i2c);
		vals[4] = (long)readGyroY(i2c);
		vals[5] = (long)readGyroZ(i2c);
		vals[6] = (long)readMagX(i2c);
		vals[7] = (long)readMagY(i2c);
		vals[8] = (long)readMagZ(i2c);

		for (int i = 0; i < 9; i++) {
			output <: (long)(vals[i] << 4) + i;
		}

	}
}

int readAccelX(struct r_i2c &i2c) {
	unsigned char data[1];
	int x;
	i2c_master_read_reg(ACCEL, 0x32, data, 1, i2c);
	x = data[0];
	i2c_master_read_reg(ACCEL, 0x33, data, 1, i2c);
	x = (int) (data[0] << 8) + x;

	return x;
}

int readAccelY(struct r_i2c &i2c) {
	unsigned char data[1];
	int y;

	i2c_master_read_reg(ACCEL, 0x34, data, 1, i2c);
	y = data[0];
	i2c_master_read_reg(ACCEL, 0x35, data, 1, i2c);
	y = (int) (data[0] << 8) + y;

	return y;
}

int readAccelZ(struct r_i2c &i2c) {
	unsigned char data[1];
	int z;

	i2c_master_read_reg(ACCEL, 0x36, data, 1, i2c);
	z = data[0];
	i2c_master_read_reg(ACCEL, 0x37, data, 1, i2c);
	z = (int) (data[0] << 8) + z;

	return z;
}

int readGyroX(struct r_i2c &i2c) {
	unsigned char data[1];
	int x;
	i2c_master_read_reg(GYRO, 0x1E, data, 1, i2c);
	x = data[0];
	i2c_master_read_reg(GYRO, 0x1D, data, 1, i2c);
	x = (int) (data[0] << 8) + x;

	return x;
}
int readGyroY(struct r_i2c &i2c) {
	unsigned char data[1];
	int y;
	i2c_master_read_reg(GYRO, 0x20, data, 1, i2c);
	y = data[0];
	i2c_master_read_reg(GYRO, 0x1F, data, 1, i2c);
	y = (int) (data[0] << 8) + y;

	return y;

}
int readGyroZ(struct r_i2c &i2c) {
	unsigned char data[1];
	int z;
	i2c_master_read_reg(GYRO, 0x22, data, 1, i2c);
	z = data[0];
	i2c_master_read_reg(GYRO, 0x21, data, 1, i2c);
	z = (int) (data[0] << 8) + z;

	return z;

}
int readMagX(struct r_i2c &i2c) {
	unsigned char data[1];
	int x;
	i2c_master_read_reg(MAG, 0x04, data, 1, i2c);
	x = data[0];
	i2c_master_read_reg(MAG, 0x03, data, 1, i2c);
	x = (int) (data[0] << 8) + x;

	return x;

}
int readMagY(struct r_i2c &i2c) {
	unsigned char data[1];
	int y;
	i2c_master_read_reg(MAG, 0x08, data, 1, i2c);
	y = data[0];
	i2c_master_read_reg(MAG, 0x07, data, 1, i2c);
	y = (int) (data[0] << 8) + y;

	return y;

}
int readMagZ(struct r_i2c &i2c) {
	unsigned char data[1];
	int z;
	i2c_master_read_reg(MAG, 0x06, data, 1, i2c);
	z = data[0];
	i2c_master_read_reg(MAG, 0x05, data, 1, i2c);
	z = (int) (data[0] << 8) + z;

	return z;

}

