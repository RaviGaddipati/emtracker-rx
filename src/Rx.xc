#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include "ADC/ADC.h"
#include "fft.h"
#include "IMU/IMU.h"
#include "Rx.h"
#include <xscope.h>
#include <math.h>

int main(void) {
    streaming chan pair1, pair2, fft_pair1, fft_pair2, imu_data;
    xscope_register(4, XSCOPE_CONTINUOUS, "Ch0", XSCOPE_UINT, "mV",
            XSCOPE_CONTINUOUS, "Ch1", XSCOPE_UINT, "mV", XSCOPE_CONTINUOUS,
            "Ch2", XSCOPE_UINT, "mV", XSCOPE_CONTINUOUS, "Ch3", XSCOPE_UINT,
            "mV");

    par
    {
        ADCThread(adc, pair1, pair2);
        fftTwoReals(pair1, fft_pair1);
        fftTwoReals(pair2, fft_pair2);
        sensorUpdate(imu, imu_data);
        output(fft_pair1, fft_pair2, imu_data);

    }
    return 0;
}

void output(streaming chanend fft0, streaming chanend fft1,
        streaming chanend imu) {
    // Streams data through Xscope
    unsigned int tmp;

    while (1) {
        xscope_int(0, 0);
        xscope_int(1, 0);
        xscope_int(2, 0);
        xscope_int(3, 0);

        for (int i = 0; i < 128; i++) {
            fft0 :> tmp;
            if ((tmp & 1) == 0) {
                xscope_int(0, tmp >> 1);
            } else {
                xscope_int(1, tmp >> 1);
            }
            fft1 :> tmp;
            if ((tmp & 1) == 0) {
                xscope_int(2, tmp >> 1);
            } else {
                xscope_int(3, tmp >> 1);
            }

        }
    }

}

void fftTwoReals(streaming chanend input, streaming chanend output) {
    // FFT on two adc channels
    int re0[256], re1[256];
    int im0[256], im1[256];
    int sine[256];
    int tmp;
    // Copy sine table for par usage
    for (int i = 0; i < 256; i++) {
        sine[i] = sine_256[i];
    }

    while (1) {

        // Get ADC Data
        for (int i = 0; i < 256; i++) {
            input :> tmp;
            if ((tmp & 1) == 0) {
                re0[i] = tmp >> 1;
            } else {
                re1[i] = tmp >> 1;
            }
            im0[i] = 0;
            im1[i] = 0;
        }

        // FFT
        fftTwiddle(re0, im0, 256);
        fftTwiddle(re1, im1, 256);
        fftTwoRealsForward(re0, re1, im0, im1, 256, sine);

        // Output magnitude
        for (int i = 0; i < 128; i++) {
            output <: (unsigned int)sqrt((re0[i] * re0[i]) + (im0[i] * im0[i])) << 1;
            output <: (unsigned int)sqrt((re1[i] * re1[i]) + (im1[i] * im1[i])) << 1 + 1;

        }

    }
}
