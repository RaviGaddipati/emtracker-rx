/**
 * @file
 * @author Ravi Gaddipati <ravigaddipati@gmail.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 * ADC functions to interface with the AD7924. This file contains the definition for the thread, as well as a function to configure the ADCs (bit banged).
 * The functions take an ADC structure by reference.
 */

#include <xs1.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include "ADC.h"

void configureADC(ADC &adc);

/**
 * Collects data from the SPI ADCs and outputs to the matched Processing thread
 *
 * @param adc Structure defining the ADC to read from
 * @param output Streaming Channel to a Processing thread
 */
void ADCThread(ADC &adc, streaming chanend ch0, streaming chanend ch1, streaming chanend ch2) {
    int data, data1, data2, address1, address2;
    timer t;
    long time;

    configure_clock_rate(adc.blk1, 100, 4);
    configure_out_port(adc.SCLK, adc.blk1, 0);
    configure_clock_src(adc.blk2, adc.SCLK);
    configure_in_port(adc.MISO, adc.blk2);
    clearbuf(adc.SCLK);
    start_clock(adc.blk1);
    start_clock(adc.blk2);
    adc.SCLK <: 0xFF;

    configureADC(adc);

    t :> time;
    while (1) {
        //Read a packet of data, for channel n
        select {
            case t when timerafter(time) :> void:
            t :> time;
            time += 100000; //100khz sample rate

            adc.CS <: 0;
            clearbuf(adc.MISO);
            adc.SCLK <: 0xAA;
            adc.SCLK <: 0xAA;
            adc.SCLK <: 0xAA;
            adc.SCLK <: 0xAA;

            sync(adc.SCLK);
            adc.CS <: 1;

            break;
        }
        select {
            case t when timerafter(time):> void:
            //Read a packet of data, for channel n+1
            t :> time;
            time += 100000;

            adc.CS <: 0;
            adc.SCLK <: 0xAA;
            adc.SCLK <: 0xAA;
            adc.SCLK <: 0xAA;
            adc.SCLK <: 0xAA;

            adc.MISO :> data;
            adc.CS <: 1;

            break;
        }

        //Output an integer w/ channel identifier bit
        data = (int) bitrev(data);
        data1 = ((data) >> 16);
        data2 = ((data) & 65535);
        address1 = ((data1 & 0b1110000000000000) >> 13);
        address2 = ((data2 & 0b1110000000000000) >> 13);
        data1 = (unsigned int) (data1 & 0b0001111111111111) >> 1;
        data2 = (unsigned int) (data2 & 0b0001111111111111) >> 1;

        if (address1 == 0 && address2 == 1) {
            ch0 <: data1;
            ch1 <: data2;
        } else if (address1 == 2 && address2 == 3) {
            ch2 <: data1;
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
    int data;
    adc.CS <: 1;
    adc.MOSI <: 1;
    adc.CS <: 0;

    clearbuf(adc.MISO);
    for (int i = 0; i < 8; i++) {
        adc.SCLK <: 0xAA;
    }

    sync(adc.SCLK);
    adc.MISO :> data;

    clearbuf(adc.MISO);
    for (int i = 0; i < 8; i++) {
        adc.SCLK <: 0xAA;
    }

    sync(adc.SCLK);
    adc.MISO :> data;

    adc.CS <: 1;
    adc.MOSI <: 0;
}
