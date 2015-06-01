#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include "ADC/ADC.h"
#include "IMU/IMU.h"
#include "PGA/pga.h"
#include "FFT/coilFFT.h"
#include "Rx.h"

// PGA, ADC, and IMU ports
PGA pga = {PORT_AMP_CS, PORT_AMP_MOSI, PORT_AMP_MISO, PORT_AMP_SCLK, XS1_CLKBLK_3, XS1_CLKBLK_4};
ADC adc = { PORT_ADC_CS, PORT_ADC_MOSI, PORT_ADC_MISO, PORT_ADC_SCLK, XS1_CLKBLK_1, XS1_CLKBLK_2 };
r_i2c imu = { PORT_IMU_SCL, PORT_IMU_SDA, 250 };

int main(void) {
    streaming chan adc0,adc1,adc2, fft0, fft1, fft2;

    // Launch threads
    par
    {
        ADCThread(adc, adc0,adc1,adc2);
        fft(adc0,fft0);
        fft(adc1,fft1);
        fft(adc2,fft2);
        output(fft0, fft1, fft2);
    }

    return 0;
}

void output(streaming chanend ch0, streaming chanend ch1, streaming chanend ch2) {
     unsigned int c0, c1, c2, s0 = 0, s1 = 0, s2 = 0;
     unsigned int gain[3];
     int accel[3], gyro[3], mag[3];
     timer t;
     unsigned int time, diff;

     initIMU(imu);
     initPGA(pga);
     gain[0] = 5;
     gain[1] = 5;
     gain[2] = 5;
     setGain(pga,gain);


    while (1) {

        t :> time;

        readAccel(imu, accel);
        readGyro(imu, gyro);
        readMag(imu, mag);

        for (int i = 0; i < 10; i++){
            ch0 :> c0;
            ch1 :> c1;
            ch2 :> c2;
            s0 += c0;
            s1 += c1;
            s2 += c2;
        }
        s0 = s0/10;
        s1 = s1/10;
        s2 = s2/10;
        t :> diff;
        diff -= time;
        printf("%8d ns, 10Khz: %8d %8d %8d, Accel: %5d %5d %5d, Gyro: %5d %5d %5d, Mag: %5d %5d %5d \n",
                diff,s0,s1,s2,accel[0],accel[1],accel[2],gyro[0],gyro[1],gyro[2],mag[0],mag[1],mag[2]);

    }

}


