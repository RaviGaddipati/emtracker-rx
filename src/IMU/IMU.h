/*
 * IMU.h
 *
 *  Created on: Dec 28, 2014
 *      Author: Ravi
 */

#ifndef IMU_H_
#define IMU_H_

#include "i2c.h"

void sensorUpdate(r_i2c &i2c, streaming chanend output);

#define MAG 0x1E
#define ACCEL 0x1D
#define GYRO 0x68


#endif /* IMU_H_ */
