#include <xs1.h>
#include <xclib.h>
#include "pga.h"

/**
 * Init PGA ports, and set gains to 1.
 */
void initPGA(PGA &pga) {
    // SCLK at 100/16 Mhz. Output MOSI on SCLK edge.
    configure_clock_rate(pga.blk1, 100, 16);
    configure_out_port(pga.SCLK, pga.blk1, 1);
    configure_clock_src(pga.blk2, pga.SCLK);
    configure_out_port(pga.MOSI, pga.blk2, 0);
    clearbuf(pga.SCLK);
    start_clock(pga.blk1);
    start_clock(pga.blk2);
    pga.CS <: 1;
    pga.MOSI <: 1;
    unsigned int data[3];
    data[0] = 1;
    data[1] = 1;
    data[2] = 1;

    setGain(pga,data);

}

/**
 * Set gain of all PGA's. Every PGA must be updated every update.
 * Each nibble controls the gain of one channel, 0-7.
 * Possible gains [num- gain: chA, chB]:
 * 0- 0: 0,0
 * 1- 1: 1,1
 * 2- 2: 1,2
 * 3- 4: 2,2
 * 4- 5: 3,1
 * 5- 10: 3,2
 * 6- 20: 4,2
 * 7- 25: 3,3
 * 8- 40: 5,2
 * 9- 50: 4,3
 * 10- 100: 4,4
 * 11- 200: 5,4
 * 12- 250: 6,3
 * 13- 400: 5,5
 * 14- 500: 6,4
 * 15- 1000: 6,5
 * 16- 2000: 7,5
 * 17- 2500: 6,6
 * 18- 5000: 7,6
 * 19- 10000: 7,7
 */
void setGain(PGA &pga, unsigned int gain[]) {
    unsigned int  mosi = 0;

    for (int i = 0; i < 3; i ++){
        mosi = mosi << 8;
        switch (gain[i]){
        case 0: break;
        case 1: mosi |= 0x11; break;
        case 2: mosi |= 0x12; break;
        case 3: mosi |= 0x22; break;
        case 4: mosi |= 0x31; break;
        case 5: mosi |= 0x32; break;
        case 6: mosi |= 0x42; break;
        case 7: mosi |= 0x33; break;
        case 8: mosi |= 0x52; break;
        case 9: mosi |= 0x43; break;
        case 10: mosi |= 0x44; break;
        case 11: mosi |= 0x54; break;
        case 12: mosi |= 0x63; break;
        case 13: mosi |= 0x55; break;
        case 14: mosi |= 0x64; break;
        case 15: mosi |= 0x65; break;
        case 16: mosi |= 0x75; break;
        case 17: mosi |= 0x66; break;
        case 18: mosi |= 0x76; break;
        case 19: mosi |= 0x77; break;
        default: mosi |= 0x77; break;
        }
    }

    pga.CS <: 0;
    pga.CS <: 0;

    clearbuf(pga.MOSI);
    pga.MOSI <: bitrev(mosi); // MSB first
    pga.SCLK <: 0xAAAAAAAA;
    pga.SCLK <: 0xAAAAAAAA;
    sync(pga.SCLK);

    pga.CS <: 0;
    pga.CS <: 0;
    pga.CS <: 0;
    pga.CS <: 0;
    pga.CS <: 1;

}
