#include "Vsim_top.h"
#include "verilated.h"

#include <fstream>
#include <iostream>
#include <ctime>
#include <ratio>
#include <chrono>

void clk(Vsim_top* dut);
size_t cycles = 0;

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);

    std::chrono::high_resolution_clock::time_point start_time = std::chrono::high_resolution_clock::now();

    Vsim_top* top = new Vsim_top;

    top->clk = 0;
    top->rst_n = 0;

    for(int i = 0; i<10; i++){
        clk(top);
        cycles ++;
    }

    top->rst_n = 1;
    top->eval();

    // int load_success = 0;

    // if(argc > 1){
    //     load_success = fill_mem(argv[1], top->sim_fast_top__DOT__FAST_SDRAM__DOT__mem);
    // } else {
    //     load_success = fill_mem("../../../hexfiles/coin.hex", top->sim_fast_top__DOT__FAST_SDRAM__DOT__mem);
    // }

    top->eval();

    // while(!top->done && load_success > 0) {
        // clk(top);
        // cycles ++;
    // }
    // double cpi = ((double)top->cycles) / top->instructions;
    // std::cout << "#Instructions = " << std::dec << top->instructions << " #Cycles = " << top->cycles << " cpi " << cpi << std::endl;
    delete top;

    std::chrono::high_resolution_clock::time_point end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> total_time = end_time - start_time;
    long ns_sim = 10 * cycles; // 10ns per clock cycle
    double s_real = total_time.count();
    int ns_sim_per_s = (int)(ns_sim / s_real);
    std::cout << "Finished " << cycles << " cycle (" << ns_sim << "ns) simulation in " << s_real << "s at " << ns_sim_per_s << "ns/s." << std::endl;
    exit(0);
}

void clk(Vsim_top* dut){
    dut->clk = 1;
    dut->eval();
    dut->clk = 0;
    dut->eval();
}

// int fill_mem(const char * file, IData* data){
//     std::ifstream input_file(file, std::fstream::in);
//     size_t counter = 0;
//     if(!input_file){
//         std::cerr << "Unable to read file " << file << std::endl;
//         return -1;
//     }
//     while(input_file){
//         IData value;
//         input_file >> std::hex >> value;
//         data[counter] = value;
//         counter++;
//     }
//     return 1;
// }

// double sc_time_stamp() {
//     return cycles*10*1000;
// }

// const int MAX_SIZE = 1024;
// char CORE_0_BUFF[MAX_SIZE];
// char CORE_1_BUFF[MAX_SIZE];
// size_t CORE_0_LAST_PC = 0;
// size_t CORE_1_LAST_PC = 0;
// size_t CORE_0_INDEX = 0;
// size_t CORE_1_INDEX = 0;

// void check_core(size_t &last_pc, size_t &index,
//                 char *buffer, size_t pc, bool shouldPrint,
//                 char charToPrint, const char *prefix)
// {
//     if (last_pc == pc)
//     {
//         return;
//     }
//     last_pc = pc;
//     if (shouldPrint)
//     {
//         buffer[index] = charToPrint;
//         index++;
//         if (index >= MAX_SIZE)
//         {
//             index = 0;
//         }
//         if (charToPrint == '\n')
//         {
//             buffer[index] = '\0';
//             printf("%s: %s", prefix, buffer);
//             index = 0;
//         }
//     }
// }

// bool next_next = false;

// void check_print(Vsim_fast_top *dut)
// {
//     check_core(CORE_0_LAST_PC, CORE_0_INDEX, CORE_0_BUFF,
//      dut->pc[0], dut->should_print[0], dut->print_char[0],
//      "CORE 0");

//     check_core(CORE_1_LAST_PC, CORE_1_INDEX, CORE_1_BUFF,
//      dut->pc[1], dut->should_print[1], dut->print_char[1],
//      "CORE 1");
// }