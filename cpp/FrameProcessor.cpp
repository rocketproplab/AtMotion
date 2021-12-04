#include "FrameProcessor.h"

void RPL::FrameProcessor::reset(){
    this->state = 0;
}

struct RPL::FrameOutput RPL::FrameProcessor::clock(int data_point, long root_time, long phase_to_guess, long prn_state){
    return {this->state, 0};
}