/*
 * Rx.h
 *
 *  Created on: Dec 27, 2014
 *      Author: Ravi
 */

#ifndef RX_H_
#define RX_H_

on tile[0] : ADC adc = { PORT_ADC_CS, PORT_ADC_MOSI, PORT_ADC_MISO,
        PORT_ADC_SCLK, XS1_CLKBLK_1, XS1_CLKBLK_2 };

on tile[0] : r_i2c imu = { PORT_IMU_SCL, PORT_IMU_SDA, 250 };


void fftTwoReals(streaming chanend input, streaming chanend output);
void output(streaming chanend fft0, streaming chanend fft1, streaming chanend ff2,
        streaming chanend imu);
void fft(streaming chanend input, streaming chanend output);

#endif /* RX_H_ */
