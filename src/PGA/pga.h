/*
 * pga.h
 *
 *  Created on: May 27, 2015
 *      Author: Ravi
 */

#ifndef PGA_H_
#define PGA_H_

typedef struct PGA {
    out port CS;
    out buffered port:32 MOSI;
    in port MISO;
    out buffered port:32 SCLK;
    clock blk1;
    clock blk2;
} PGA;

void setGain(PGA &pga, unsigned int gain[]);
void initPGA(PGA &pga);

#endif /* PGA_H_ */
