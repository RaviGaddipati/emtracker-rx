#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include "ADC/ADC.h"
#include "fft.h"
#include "IMU/IMU.h"
#include "Rx.h"
#include <math.h>
#include "PGA/pga.h"

    PGA pga = {PORT_AMP_CS, PORT_AMP_MOSI, PORT_AMP_MISO, PORT_AMP_SCLK, XS1_CLKBLK_3, XS1_CLKBLK_4};


int main(void) {
    streaming chan adc0,adc1,adc2, fft0, fft1, fft2, imu_data, imuN;


/*    initIMU(imu);
    int accel[3];
while(1){
    readAccel(imu,accel);
    printf("X: %i, Y: %i, Z: %i\n",accel[0], accel[1], accel[2]);
}
*/

    par
    {
        ADCThread(adc, adc0,adc1,adc2);
  //      xOut(imu, imu_data);
        fft(adc0,fft0);
        fft(adc1,fft1);
        fft(adc2,fft2);
        output(fft0, fft1, fft2, imuN);

    }

    return 0;
}

void output(streaming chanend fft0, streaming chanend fft1, streaming chanend fft2,
        streaming chanend imu) {
     int ch0[256], ch1[256], ch2[256];
     int max=0, maxloc=0;
    initPGA(pga);
    setGain(pga,2,2,2,2,1,2);


    while (1) {
        for (int i = 0; i < 128; i++) {
            fft0 :> ch0[i];
            fft1 :> ch1[i];
            fft2 :> ch2[i];
            if (ch2[i] > max && i != 0) {
                max = ch2[i];
                maxloc = i;
            }
        }

       printf("%d, %d, %d\n",max,maxloc,((maxloc+1)*2500/2)/(256/2));
    }

}

void fft(streaming chanend input, streaming chanend output) {
    int re[256], im[256],locSin[65], tmp;
    for (int i = 0; i < 65; i++) {
        locSin[i] = sine_256[i];
    }
    while(1){
        for (int i = 0; i < 256; i++) {
        input :> re[i];
        im[i] = 0;
        }
        fftTwiddle(re, im, 256);
        fftForward(re, im, 256, locSin);
        for (int i = 0; i < 128; i++) {
            output <: (int)sqrt((re[i] * re[i]) + (im[i] * im[i]));
        }
    }
}

void fftTwoReals(streaming chanend input, streaming chanend output) {
    // FFT on two adc channels
    int re0[256], re1[256];
    int im0[256], im1[256];
    int sine[65];
    int tmp,c1 = 0,c2 = 0;
    // Copy sine table for par usage
    for (int i = 0; i < 65; i++) {
        sine[i] = sine_256[i];
    }

    while (1) {

        // Get ADC Data
        for (int i = 0; i < 512; i++) {
            input :> tmp;
            if ((tmp & 1) == 0) {
                re0[c1] = tmp >> 1;
                c1++;
            } else {
                re1[c2] = tmp >> 1;
                c2++;
            }
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
