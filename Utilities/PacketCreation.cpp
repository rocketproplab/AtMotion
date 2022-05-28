#include <stdio.h>
#include <iostream>

int main() {

    int prev_word[30] = { 0 };
    prev_word[28] = 1;
    prev_word[29] = 1;

    int D29star = prev_word[28];
    int D30star = prev_word[29];

    int FIFO[30] = {};

    int d[25] = {0, 0, 1, 1, 1, 0, 1, 0, 0}; //inverse of preamble because we are xoring it with D30Star = 1, so this will give the preamble. d[0] = 0 to align with indexing.

    for(int i = 1; i < 25; i++) { //Encode data with D30Star, according to encoding specification
        FIFO[i-1] = (d[i] + D30star) % 2;
    }


    int D25_computed = (D29star + d[1] + d[2] + d[3] + d[5] + d[6] + d[10] + d[11] + d[12] + d[13] + d[14] + d[17] + d[18] + d[20] + d[23]) % 2;
    int D26_computed = (D30star + d[2] + d[3] + d[4] + d[6] + d[7] + d[11] + d[12] + d[13] + d[14] + d[15] + d[18] + d[19] + d[21] + d[24]) % 2;
    int D27_computed = (D29star + d[1] + d[3] + d[4] + d[5] + d[7] + d[8] + d[12] + d[13] + d[14] + d[15] + d[16] + d[19] + d[20] + d[22]) % 2;
    int D28_computed = (D30star + d[2] + d[4] + d[5] + d[6] + d[8] + d[9] + d[13] + d[14] + d[15] +d[16] + d[17] + d[20] + d[21] + d[23]) % 2;
    int D29_computed = (D30star + d[1] + d[3] + d[5] + d[6] + d[7] + d[9] + d[10] + d[14] + d[15] + d[16] + d[17] + d[18] + d[21] + d[22] + d[24]) % 2;
    int D30_computed = (D29star + d[3] + d[5] + d[6] + d[8] + d[9] + d[10] + d[11] + d[13] + d[15] + d[19] + d[22] + d[23] + d[24]) % 2;

    std::cout << "Computed D25: " << D25_computed << " Input String: " <<  D29star << d[1] << d[2] << d[3] << d[5] << d[6] << d[10] << d[11] << d[12] << d[13] << d[14] << d[17] << d[18] << d[20] << d[23] << std::endl;
    std::cout << "Computed D26: " << D26_computed << " Input String: " <<  D30star << d[2] << d[3] << d[4] << d[6] << d[7] << d[11] << d[12] << d[13] << d[14] << d[15] << d[18] << d[19] << d[21] << d[24] << std::endl;
    std::cout << "Computed D27: " << D27_computed << " Input String: " <<  D29star << d[1] << d[3] << d[4] << d[5] << d[7] << d[8] << d[12] << d[13] << d[14] << d[15] << d[16] << d[19] << d[20] << d[22] << std::endl;
    std::cout << "Computed D28: " << D28_computed << " Input String: " <<  D30star << d[2] << d[4] << d[5] << d[6] << d[8] << d[9] << d[13] << d[14] << d[15] <<d[16] << d[17] << d[20] << d[21] << d[23] << std::endl;
    std::cout << "Computed D29: " << D29_computed << " Input String: " <<  D30star << d[1] << d[3] << d[5] << d[6] << d[7] << d[9] << d[10] << d[14] << d[15] << d[16] << d[17] << d[18] << d[21] << d[22] << d[24] << std::endl;
    std::cout << "Computed D30: " << D30_computed << " Input String: " <<  D29star << d[3] << d[5] << d[6] << d[8] << d[9] << d[10] << d[11] << d[13] << d[15] << d[19] << d[22] << d[23] << d[24] << std::endl;


    FIFO[24] = D25_computed;
    FIFO[25] = D26_computed;
    FIFO[26] = D27_computed;
    FIFO[27] = D28_computed;
    FIFO[28] = D29_computed;
    FIFO[29] = D30_computed;

    std::cout << "FIFO: ";

    for (int i = 0; i < sizeof(FIFO)/sizeof(FIFO[0]); i++) {
        std::cout << FIFO[i] << ", ";

    }

    std::cout << std::endl;
}