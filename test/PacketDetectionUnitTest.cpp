#include "miniunit.h"
#include "PacketDetectionUnit.h"

MU_TEST(with_preamble_and_parity_matching){
    RPL::PacketDetectionUnit PDU;
    int prev_word = 3; //Only 2 LSBs matter, this should both be 1
    int D29star = prev_word & 2;
    int D30star = prev_word & 1;
    int FIFO[30] = {};

    int d[25] = {0, 0, 1, 1, 1, 0, 1, 0, 0}; //inverse of preamble because we are xoring it with D30Star = 1

    for(int i = 1; i < 25; i++) {
        FIFO[i-1] = (d[i] + D30star) % 2;
    }


    int D25_computed = (D29star + d[1] + d[2] + d[3] + d[5] + d[6] + d[10] + d[11] + d[12] + d[13] + d[14] + d[17] + d[18] + d[20] + d[23]) % 2;
    int D26_computed = (D30star + d[2] + d[3] + d[4] + d[6] + d[7] + d[11] + d[12] + d[13] + d[14] + d[15] + d[18] + d[19] + d[21] + d[24]) % 2;
    int D27_computed = (D29star + d[1] + d[3] + d[4] + d[5] + d[7] + d[8] + d[12] + d[13] + d[14] + d[15] + d[16] + d[19] + d[20] + d[22]) % 2;
    int D28_computed = (D30star + d[2] + d[4] + d[5] + d[6] + d[8] + d[9] + d[13] + d[14] + d[15] +d[16] + d[17] + d[20] + d[21] + d[23]) % 2;
    int D29_computed = (D30star + d[1] + d[3] + d[5] + d[6] + d[7] + d[9] + d[10] + d[14] + d[15] + d[16] + d[17] + d[18] + d[21] + d[22] + d[24]) % 2;
    int D30_computed = (D29star + d[3] + d[5] + d[6] + d[8] + d[9] + d[10] + d[11] + d[13] + d[15] + d[19] + d[22] + d[23] + d[24]) % 2;

    FIFO[24] = D25_computed;
    FIFO[25] = D26_computed;
    FIFO[26] = D27_computed;
    FIFO[27] = D28_computed;
    FIFO[28] = D29_computed;
    FIFO[29] = D30_computed;

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(result, "preamble with matching parity failed");

}

MU_TEST(with_preamble_and_parity_not_matching){
    RPL::PacketDetectionUnit PDU;
    int prev_word = 3; //Only 2 LSBs matter, this should both be 1
    int D29star = prev_word & 2;
    int D30star = prev_word & 1;
    int FIFO[30] = {};

    int d[25] = {0, 0, 1, 1, 1, 0, 1, 0, 0}; //inverse of preamble because we are xoring it with D30Star = 1, so this will give the preamble

    for(int i = 1; i < 25; i++) {
        FIFO[i-1] = (d[i] + D30star) % 2;
    }


    int D25_computed = (D29star + d[1] + d[2] + d[3] + d[5] + d[6] + d[10] + d[11] + d[12] + d[13] + d[14] + d[17] + d[18] + d[20] + d[23]) % 2;
    int D26_computed = (D30star + d[2] + d[3] + d[4] + d[6] + d[7] + d[11] + d[12] + d[13] + d[14] + d[15] + d[18] + d[19] + d[21] + d[24]) % 2;
    int D27_computed = (D29star + d[1] + d[3] + d[4] + d[5] + d[7] + d[8] + d[12] + d[13] + d[14] + d[15] + d[16] + d[19] + d[20] + d[22] + 1) % 2; //Added +1 to make parity not match
    int D28_computed = (D30star + d[2] + d[4] + d[5] + d[6] + d[8] + d[9] + d[13] + d[14] + d[15] +d[16] + d[17] + d[20] + d[21] + d[23]) % 2;
    int D29_computed = (D30star + d[1] + d[3] + d[5] + d[6] + d[7] + d[9] + d[10] + d[14] + d[15] + d[16] + d[17] + d[18] + d[21] + d[22] + d[24]) % 2;
    int D30_computed = (D29star + d[3] + d[5] + d[6] + d[8] + d[9] + d[10] + d[11] + d[13] + d[15] + d[19] + d[22] + d[23] + d[24]) % 2;

    FIFO[24] = D25_computed;
    FIFO[25] = D26_computed;
    FIFO[26] = D27_computed;
    FIFO[27] = D28_computed;
    FIFO[28] = D29_computed;
    FIFO[29] = D30_computed;

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(result, "preamble with matching parity failed");
}

MU_TEST(without_preamble_and_parity_matching){
    RPL::PacketDetectionUnit PDU;
    int prev_word = 3; //Only 2 LSBs matter, this should both be 1
    int D29star = prev_word & 2;
    int D30star = prev_word & 1;
    int FIFO[30] = {};

    int d[25] = {1, 0, 1, 1, 1, 0, 1, 0, 0}; //inverse of preamble because we are xoring it with D30Star = 1, but with first bit flipped so it should not detect the preamble

    for(int i = 1; i < 25; i++) {
        FIFO[i-1] = (d[i] + D30star) % 2;
    }


    int D25_computed = (D29star + d[1] + d[2] + d[3] + d[5] + d[6] + d[10] + d[11] + d[12] + d[13] + d[14] + d[17] + d[18] + d[20] + d[23]) % 2;
    int D26_computed = (D30star + d[2] + d[3] + d[4] + d[6] + d[7] + d[11] + d[12] + d[13] + d[14] + d[15] + d[18] + d[19] + d[21] + d[24]) % 2;
    int D27_computed = (D29star + d[1] + d[3] + d[4] + d[5] + d[7] + d[8] + d[12] + d[13] + d[14] + d[15] + d[16] + d[19] + d[20] + d[22]) % 2;
    int D28_computed = (D30star + d[2] + d[4] + d[5] + d[6] + d[8] + d[9] + d[13] + d[14] + d[15] +d[16] + d[17] + d[20] + d[21] + d[23]) % 2;
    int D29_computed = (D30star + d[1] + d[3] + d[5] + d[6] + d[7] + d[9] + d[10] + d[14] + d[15] + d[16] + d[17] + d[18] + d[21] + d[22] + d[24]) % 2;
    int D30_computed = (D29star + d[3] + d[5] + d[6] + d[8] + d[9] + d[10] + d[11] + d[13] + d[15] + d[19] + d[22] + d[23] + d[24]) % 2;

    FIFO[24] = D25_computed;
    FIFO[25] = D26_computed;
    FIFO[26] = D27_computed;
    FIFO[27] = D28_computed;
    FIFO[28] = D29_computed;
    FIFO[29] = D30_computed;

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(result, "preamble with matching parity failed");
}

MU_TEST(without_preamble_and_parity_not_matching){
        RPL::PacketDetectionUnit PDU;
    int prev_word = 3; //Only 2 LSBs matter, this should both be 1
    int D29star = prev_word & 2;
    int D30star = prev_word & 1;
    int FIFO[30] = {};

    int d[25] = {0, 0, 1, 1, 1, 0, 1, 0, 0}; //inverse of preamble because we are xoring it with D30Star = 1

    for(int i = 1; i < 25; i++) {
        FIFO[i-1] = (d[i] + D30star) % 2;
    }


    int D25_computed = (D29star + d[1] + d[2] + d[3] + d[5] + d[6] + d[10] + d[11] + d[12] + d[13] + d[14] + d[17] + d[18] + d[20] + d[23]) % 2;
    int D26_computed = (D30star + d[2] + d[3] + d[4] + d[6] + d[7] + d[11] + d[12] + d[13] + d[14] + d[15] + d[18] + d[19] + d[21] + d[24]) % 2;
    int D27_computed = (D29star + d[1] + d[3] + d[4] + d[5] + d[7] + d[8] + d[12] + d[13] + d[14] + d[15] + d[16] + d[19] + d[20] + d[22] + 1) % 2; //Added +1 to make parity not match
    int D28_computed = (D30star + d[2] + d[4] + d[5] + d[6] + d[8] + d[9] + d[13] + d[14] + d[15] +d[16] + d[17] + d[20] + d[21] + d[23]) % 2;
    int D29_computed = (D30star + d[1] + d[3] + d[5] + d[6] + d[7] + d[9] + d[10] + d[14] + d[15] + d[16] + d[17] + d[18] + d[21] + d[22] + d[24]) % 2;
    int D30_computed = (D29star + d[3] + d[5] + d[6] + d[8] + d[9] + d[10] + d[11] + d[13] + d[15] + d[19] + d[22] + d[23] + d[24]) % 2;

    FIFO[24] = D25_computed;
    FIFO[25] = D26_computed;
    FIFO[26] = D27_computed;
    FIFO[27] = D28_computed;
    FIFO[28] = D29_computed;
    FIFO[29] = D30_computed;

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(result, "preamble with matching parity failed");
}


MU_TEST_SUITE(frame_processor_tests){
    MU_RUN_TEST(with_preamble_and_parity_matching);
    MU_RUN_TEST(with_preamble_and_parity_not_matching);
    MU_RUN_TEST(without_preamble_and_parity_matching);
    MU_RUN_TEST(without_preamble_and_parity_not_matching);
}

int main(){
    MU_RUN_SUITE(frame_processor_tests);
    return 0;
}