/*
 * IMU.h
 *
 *  Created on: Dec 28, 2014
 *      Author: Ravi
 */

#ifndef IMU_H_
#define IMU_H_

#include "i2c.h"

int readAccelX(r_i2c &i2c);
int readAccelY(r_i2c &i2c);
int readAccelZ(r_i2c &i2c);
void readAccel(r_i2c &i2c, int vals[]);

int readGyroX(r_i2c &i2c);
int readGyroY(r_i2c &i2c);
int readGyroZ(r_i2c &i2c);
void readGyro(r_i2c &i2c, int vals[]);

int readMagX(r_i2c &i2c);
int readMagY(r_i2c &i2c);
int readMagZ(r_i2c &i2c);
void readMag(r_i2c &i2c, int vals[]);

void initIMU(r_i2c &i2c);

#define MAG 0x1E
#define ACCEL 0x1D
#define GYRO 0x68


#endif /* IMU_H_ */
