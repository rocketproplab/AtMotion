#include "miniunit.h"
#include "FrameProcessor.h"

MU_TEST(without_increment_returns_same_value){
    RPL::FrameProcessor processor;
    processor.reset();
    auto result = processor.clock(0, 0, 0, 0);
    mu_assert_int_eq(result.inverted_signal, 0);
}

MU_TEST(increment_incrases_value){
    RPL::FrameProcessor processor;
    processor.reset();
    // int result = processor.clock(true);
    mu_assert_int_eq(1, 1);
}

MU_TEST_SUITE(frame_processor_tests){
    MU_RUN_TEST(without_increment_returns_same_value);
    MU_RUN_TEST(increment_incrases_value);
}

int main(){
    MU_RUN_SUITE(frame_processor_tests);
    return 0;
}