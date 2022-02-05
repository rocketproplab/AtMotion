#include "miniunit.h"
#include "PacketDetectionUnit.h"

MU_TEST(with_preamble_and_parity_matching){
    RPL::PacketDetectionUnit PDU;
    int prev_word[30] = { 0 };
    prev_word[28] = 1;
    prev_word[29] = 1;

    int D29star = prev_word[28];
    int D30star = prev_word[29];

    //Computed FIFO from PacketCreation.cpp
    //First 8 bits match preamble = 1000 1011
    //D[1:24] = d[1:24] xor D30star
    //These data values use d[1:8] = !(1000 1011) = 0111 0100, d[9:24] = 0
    //                       D29star = 1, D30star = 1

    int FIFO[30] = {1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1};

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(result, "preamble with matching parity failed");

}

MU_TEST(with_preamble_and_parity_not_matching){
    RPL::PacketDetectionUnit PDU;
    int prev_word[30] = { 0 };
    prev_word[28] = 1;
    prev_word[29] = 1;

    int D29star = prev_word[28];
    int D30star = prev_word[29];

    //Computed FIFO from PacketCreation.cpp
    //First 8 bits match preamble = 1000 1011
    //D[1:24] = d[1:24] xor D30star
    //These data values use d[1:8] = !(1000 1011) = 0111 0100, d[9:24] = 0
    //                       D29star = 1, D30star = 1

    //Then finally to make parity not match D30 is flipped

    int FIFO[30] = {1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0};

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(!result, "preamble without matching parity failed"); //Note: mu_assert checks that the result is true. In this case we want the function to return false (parity not matching)
                                                               //       so we should pass mu_assert !result as the test has passed if result == False
}

MU_TEST(without_preamble_and_parity_matching){
    RPL::PacketDetectionUnit PDU;
    int prev_word[30] = { 0 };
    prev_word[28] = 1;
    prev_word[29] = 1;

    int D29star = prev_word[28];
    int D30star = prev_word[29];

   //Computed FIFO from PacketCreation.cpp
    //First 8 bits match preamble = 1000 1011
    //D[1:24] = d[1:24] xor D30star
    //These data values use d[1:8] = !(1000 1011) = 0111 0100, d[9:24] = 0
    //                       D29star = 1, D30star = 1

    //Then finally to make preamble not match D1 is flipped

    int FIFO[30] = {0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1};

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(!result, "without preamble with matching parity failed"); //We pass !result since this test is without the preamble and passes if result == FALSE
}

MU_TEST(without_preamble_and_parity_not_matching){
    RPL::PacketDetectionUnit PDU;
    int prev_word[30] = { 0 };
    prev_word[28] = 1;
    prev_word[29] = 1;

    int D29star = prev_word[28];
    int D30star = prev_word[29];

    //Computed FIFO from PacketCreation.cpp
    //First 8 bits match preamble = 1000 1011
    //D[1:24] = d[1:24] xor D30star
    //These data values use d[1:8] = !(1000 1011) = 0111 0100, d[9:24] = 0
    //                       D29star = 1, D30star = 1

    //Then finally to make preamble and parity not match, D1 and D30 are flipped.

    int FIFO[30] = {0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0};

    auto result = PDU.clock(prev_word, FIFO);
    mu_assert(!result, "without preamble and without matching parity failed"); //We Pass !result since this test has wrong preamble and parity, so it passes if result == FALSE
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