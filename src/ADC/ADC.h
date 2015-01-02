/**
 * @file
 * @author Phani Gaddipati <phani.gaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 * ADC Header file that defines the function that have public access from other files. This file contains the definition for
 * the ADC structure, which contains all of the neccesary information to interface with a SPI ADC. This header file also provides
 * the definition for the ADC thread, to continually read the ADC and send the streamed information through a channel to another thread.
 *
 * Operating speed is limited by the speed of the ADC device and the SPI protocol. SPI currently runs at 25 MHz, for an approximate device
 * update rate of 125 kHz.
 */

#ifndef ADC_H_
#define ADC_H_
#define spi_clock_div 2

/**
 * A structure containing all of the neccesary components to control a SPI ADC module
 *
 * @param CS Chip Select 1 bit port
 * @param MOSI MOSI 1 bit port
 * @param MISO buffered:32 1 bit input port
 * @param SCLK buffered:8 1 bit output port
 * @param blk1 A clock block
 * @param blk2 A clock block
 */
typedef struct ADC {
	out port CS;
	out port MOSI;
	in buffered port:32 MISO;
	out buffered port:8 SCLK;
	clock blk1;
	clock blk2;
} ADC;

/**
 * Collects data from the SPI ADCs and outputs to the matched Processing thread
 *
 * @param adc Structure defining the ADC to read from
 * @param output Streaming Channel to a Processing thread
 */
void ADCThread(ADC &adc, streaming chanend pair1, streaming chanend pair2);

#endif /* ADC_H_ */
