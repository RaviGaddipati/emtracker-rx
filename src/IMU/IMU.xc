/*
 * IMU.xc
 *
 *  Created on: Dec 28, 2014
 *      Author: Ravi Gaddipati
 */
#include <xs1.h>
#include <xclib.h>
#include "IMU.h"


void initIMU(r_i2c &i2c){
    unsigned char data[1];
    i2c_master_init(i2c);

    // BW_RATE, last 4 bits is BW
    data[0] = 0b00001010;
    i2c_master_write_reg(ACCEL, 0x2C,data,1,i2c);
    // Data format, last 2 bits are range (2g,4g,8g,16g in order). left justified. First bit is self test
    data[0] = 0b00000000;
    i2c_master_write_reg(ACCEL, 0x31,data,1,i2c);
    // Set to measure mode, no sleep
    data[0] = 0b00001000;
    i2c_master_write_reg(ACCEL, 0x2D,data,1,i2c);
    // Gyro LPF bandwidth, 256Hz
    data[0] = 0b00011000;
    i2c_master_write_reg(GYRO, 0x16,data,1,i2c);
    // Mag 2 measurements avgd, 75Hz
    data[0] = 0b00111000;
    i2c_master_write_reg(MAG, 0x00,data,1,i2c);
    // Mag continous measurement mode
    data[0] = 0b00000000;
    i2c_master_write_reg(MAG, 0x02,data,1,i2c);
}

int readAccelX(r_i2c &i2c) {
    unsigned char data[2];
    i2c_master_read_reg(ACCEL, 0x32, data, 2, i2c);
    return (int)(data[0] << 8) | (int)data[1];
}

int readAccelY(r_i2c &i2c) {
    unsigned char data[2];
    i2c_master_read_reg(ACCEL, 0x34, data, 2, i2c);
    return (int)(data[1] << 8) | (int)data[0];
}

int readAccelZ(r_i2c &i2c) {
	unsigned char data[2];
	i2c_master_read_reg(ACCEL, 0x36, data, 2, i2c);
	return (int)(data[1] << 8) | (int)data[0];
}

void readAccel(r_i2c &i2c, int vals[]) {
    unsigned char data[6];
    i2c_master_read_reg(ACCEL, 0x32, data, 6, i2c);
    vals[0] = (int)(data[1] << 8) | (int)data[0];
    vals[1] = (int)(data[3] << 8) | (int)data[2];
    vals[2] = (int)(data[5] << 8) | (int)data[4];

}
int readGyroX(r_i2c &i2c) {
	unsigned char data[2];
	i2c_master_read_reg(GYRO, 0x1D, data, 2, i2c);
	return (int)(data[0] << 8) | (int)data[1];
}

int readGyroY(r_i2c &i2c) {
    unsigned char data[2];
    i2c_master_read_reg(GYRO, 0x1F, data, 2, i2c);
    return (int)(data[0] << 8) | (int)data[1];

}
int readGyroZ(r_i2c &i2c) {
    unsigned char data[2];
    i2c_master_read_reg(GYRO, 0x21, data, 2, i2c);
    return (int)(data[0] << 8) | (int)data[1];

}
void readGyro(r_i2c &i2c, int vals[]) {
    unsigned char data[6];
    i2c_master_read_reg(ACCEL, 0x1D, data, 6, i2c);
    vals[0] = (int)(data[0] << 8) | (int)data[1];
    vals[1] = (int)(data[2] << 8) | (int)data[3];
    vals[2] = (int)(data[4] << 8) | (int)data[5];

}
int readMagX(r_i2c &i2c) {
    unsigned char data[2];
    i2c_master_read_reg(GYRO, 0x03, data, 2, i2c);
    return (int)(data[0] << 8) | (int)data[1];

}
int readMagY(r_i2c &i2c) {
    unsigned char data[2];
    i2c_master_read_reg(GYRO, 0x07, data, 2, i2c);
    return (int)(data[0] << 8) | (int)data[1];

}
int readMagZ(r_i2c &i2c) {
    unsigned char data[2];
    i2c_master_read_reg(GYRO, 0x05, data, 2, i2c);
    return (int)(data[0] << 8) | (int)data[1];

}
void readMag(r_i2c &i2c, int vals[]) {
    unsigned char data[6];
    i2c_master_read_reg(ACCEL, 0x03, data, 6, i2c);
    vals[0] = (int)(data[0] << 8) | (int)data[1];
    vals[2] = (int)(data[2] << 8) | (int)data[3];
    vals[1] = (int)(data[4] << 8) | (int)data[5];

}

