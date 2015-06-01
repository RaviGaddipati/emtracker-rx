/**
 * @file
 * @author Ravi Gaddipati
 * @version 1.0
 */

#ifndef ADC_H_
#define ADC_H_

#define UPDATE_PERIOD 333 // 333KSPS overall, 100KSPS each channel
/**
 * A structure containing all of the neccesary components to control a SPI ADC module
 *
 * @param CS Chip Select 1 bit port
 * @param MOSI buffered:32 1 bit port
 * @param MISO buffered:32 1 bit input port
 * @param SCLK buffered:32 1 bit output port
 * @param blk1 A clock block
 * @param blk2 A clock block
 */
typedef struct ADC {
	out port CS;
	out buffered port:32 MOSI;
	in buffered port:32 MISO;
	out buffered port:32 SCLK;
	clock blk1;
	clock blk2;
} ADC;

/**
 * Collects data from the SPI ADCs and outputs in blocks of 256 samples.
 *
 * @param adc Structure defining the ADC to read from
 * @param output Streaming Channel to a Processing thread
 */
void ADCThread(ADC &adc, streaming chanend out0, streaming chanend out1, streaming chanend out2);
#endif /* ADC_H_ */

/**
 * Configure sequencer, sequencer, power mode
 */
void configureADC(ADC &adc);
