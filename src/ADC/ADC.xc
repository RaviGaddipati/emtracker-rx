/**
 * @file
 * @author Ravi Gaddipati <ravigaddipati@gmail.com>\n
 */

#include <xs1.h>
#include <xclib.h>
#include "ADC.h"

/**
 * Collects data from the SPI ADCs and outputs to the matched Processing thread
 * Two channels are read in each cycle to fill up the 32bit buffered port.
 * @param adc Structure defining the ADC to read from
 * @param output Streaming Channel to a Processing thread
 */
void ADCThread(ADC &adc, streaming chanend out0, streaming chanend out1, streaming chanend out2) {
    unsigned int data0, data1, addr0, addr1;
    unsigned int counter0 = 0, counter1 = 0, counter2 = 0;
    unsigned int ch0[256], ch1[256], ch2[256];
    timer t;
    unsigned int time;

    configureADC(adc);

    t :> time;
    time += 10000;
    while (1) {
        //Read a packet of data, for channel n
        select {
        case t when timerafter(time) :> void:
        t :> time;
        time += UPDATE_PERIOD;

        adc.CS <: 0;
        clearbuf(adc.MISO);
        adc.SCLK <: 0xAAAAAAAA;
        sync(adc.SCLK);
        adc.CS <: 1;

        break;
        }
        // read the next channel
        select {
        case t when timerafter(time) :> void:
        t :> time;
        time += UPDATE_PERIOD;

        adc.CS <: 0;
        adc.SCLK <: 0xAAAAAAAA;
        sync(adc.SCLK);
        adc.CS <: 1;

        break;
        }

        //extract channel data
        //Format: [ch n[0,addr (2 bits),result(12 bits),0],ch n + 1 [0,addr (2 bits),result(12 bits),0]]
        adc.MISO :> data0;
        data0 = (unsigned int) bitrev(data0); // MSB first
        data1 = (data0 & 0xFFFF) >> 1;
        data0 = data0 >> 17;
        addr0 = data0 >> 12;
        addr1 = data1 >> 12;
        data0 = data0 & 0xFFF;
        data1 = data1 & 0xFFF;

        // store result. addr1 is always next channel due to sequencer.
        switch (addr0){
        case 0:
            if (counter0 < 256) {
                ch0[counter0] = data0;
                counter0++;
                ch1[counter1] = data1;
                counter1++;
            }
            break;
        case 1:
            if (counter1 < 256) {
                ch1[counter1] = data0;
                counter1++;
                ch2[counter2] = data1;
                counter2++;
            }
            break;
        case 2:
            if (counter2 < 256) {
                ch2[counter2] = data0;
                counter2++;
                ch0[counter0] = data1;
                counter0++;
            }
            break;
        }

        // After collecting data for fft, send to fft threads. and continue collecting next block.
        if (counter0 == 256 && counter1 == 256 && counter2 == 256) {
            for (int i = 0; i < 256; i++) {
                out0 <: ch0[i];
                out1 <: ch1[i];
                out2 <: ch2[i];
            }
            counter0 = 0;
            counter1 = 0;
            counter2 = 0;
        }

    }
}

/**
 * Bit-bangs configuration data to the ADC:
 * Normal power mode, sequencer 0-3, maximum speed
 * Must be called prior to using the ADCs to ensure proper data return
 * Each ADC must be configured
 *
 * @param adc Structure defining the ADC to configure
 */
void configureADC(ADC &adc) {
    // 100Mhz/6 SPI clk
    configure_clock_rate(adc.blk1, 100, 6);
    configure_out_port(adc.SCLK, adc.blk1, 1);
    configure_clock_src(adc.blk2, adc.SCLK);
    configure_in_port(adc.MISO, adc.blk2);
    configure_out_port(adc.MOSI, adc.blk2,0);
    start_clock(adc.blk1);
    start_clock(adc.blk2);
    adc.CS <: 1;

    /* Config: sequencer ch 0-2, range 0 to VREF*2, straight binary */
    // Sets initial write bit to 1
    adc.MOSI <: 0xFFFFFFFF;
    adc.SCLK <: 0xAAAAAAAA;
    sync(adc.SCLK);

    clearbuf(adc.SCLK);
    clearbuf(adc.MOSI);
    adc.CS <: 0;
    adc.CS <: 0;
    // next 11 bits of config register (reversed)
    adc.MOSI <: 0b10011101001;
    adc.SCLK <: 0xAAAAAAAA;
    sync(adc.SCLK);
    clearbuf(adc.SCLK);
    clearbuf(adc.MISO);
    clearbuf(adc.MOSI);
    adc.CS <: 1;

    // sets write bit to 0
    adc.MOSI <: 0;
    adc.SCLK <: 0xAAAAAAAA;
    sync(adc.SCLK);
}
