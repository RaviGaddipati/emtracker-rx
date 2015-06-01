/*
 * coilFFT.xc
 *
 *  Created on: Jun 1, 2015
 *      Author: Ravi Gaddipati
 */

#include "fft.h"
#include <math.h>

/**
 * Recieves a set of samples and performs a FFT. Outputs the magnitude of the frequencies defined by freqs[].
 */
void fft(streaming chanend input, streaming chanend output) {
    int re[256], im[256],locSin[65];
    int bin, freqs[1], numFreqs = 1;
    freqs[0] = 10000;
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
        for (int i = 0; i < numFreqs; i++) {
            bin = (256 * freqs[i])/100000;
            output <: (unsigned int)sqrt((re[bin] * re[bin] * 1000000) + (im[bin] * im[bin] * 1000000));
        }
    }
}
