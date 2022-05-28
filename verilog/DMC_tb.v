`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2022 04:47:43 PM
// Design Name: 
// Module Name: DMC_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DMC_tb(

    );
    
//Input parameters
parameter BLOCK_SIZE = 4;
parameter NUM_OF_BLOCKS_PER_LINE = 2;
parameter NUM_OF_CACHE_LINES = 4;
parameter ADDRESS_SIZE = 16;

//Calculate local parameters (same as in module)
localparam BLOCK_OFFSET_LENGTH = $clog2(NUM_OF_BLOCKS_PER_LINE);
localparam INDEX_LENGTH = $clog2(NUM_OF_CACHE_LINES);
localparam TAG_LENGTH = ADDRESS_SIZE - BLOCK_OFFSET_LENGTH - INDEX_LENGTH;
localparam DIRTY_BIT = 1'b1; //constant value used in address indexing for clarity, not used in address
localparam VALID_BIT = 1'b1; //constant value used in address indexing for clarity, not used in address
localparam CACHE_LINE_LENGTH = DIRTY_BIT + VALID_BIT + TAG_LENGTH + NUM_OF_BLOCKS_PER_LINE * BLOCK_SIZE;
localparam DIRTY_BIT_INDEX = CACHE_LINE_LENGTH - 1;
localparam VALID_BIT_INDEX = CACHE_LINE_LENGTH - 1 - DIRTY_BIT;
localparam TAG_INDEX = CACHE_LINE_LENGTH -1 - DIRTY_BIT - VALID_BIT;

//Local parameters
localparam LINE_SIZE = NUM_OF_BLOCKS_PER_LINE * BLOCK_SIZE ;

//Signals needed for DUT

//Local Variables with initial values
//Regs
reg clk_i = 0, rst_n_i = 1, read_i = 0, write_i = 0, start_from_CPU_i = 0;
reg                                         mem_address_from_tb = 1;
reg                                         mem_data_from_tb = 1;
reg                                         mem_read_from_tb = 1;
reg                                         mem_write_from_tb = 1;
reg                                         mem_tb_read_i = 0;
reg                                         mem_tb_write_i = 0;
reg         [ADDRESS_SIZE - 1: 0]           mem_tb_address_i;
reg         [BLOCK_SIZE - 1: 0]             mem_tb_data_i;
reg         [BLOCK_SIZE - 1: 0]             data_from_CPU_i;

reg [BLOCK_OFFSET_LENGTH - 1: 0] block_offset;
reg [INDEX_LENGTH - 1: 0] index;
reg [TAG_LENGTH - 1: 0] tag;


//Wires
wire hit_i, read_flush_i, read_fetch_i, write_flush_i, write_fetch_i, ready_to_CPU_o, mem_read_o, mem_write_o;
wire read_o, read_line_o, write_o, write_line_o;
wire        [BLOCK_SIZE - 1: 0]             mem_data_i;
wire        [BLOCK_SIZE - 1: 0]             data_from_memory_i;
wire        [BLOCK_SIZE - 1: 0]             data_from_cache_i;
wire        [BLOCK_SIZE - 1: 0]             data_to_CPU_o;
wire        [BLOCK_SIZE - 1: 0]             data_to_cache_o;
wire        [BLOCK_SIZE - 1: 0]             data_to_memory_o;
wire        [ADDRESS_SIZE - 1: 0]           mem_address_i;
wire        [ADDRESS_SIZE - 1: 0]           address_from_cache_i;
wire        [ADDRESS_SIZE - 1: 0]           address_to_cache_o;
wire        [ADDRESS_SIZE - 1: 0]           address_to_memory_o;
wire        [LINE_SIZE - 1: 0]              line_i;
wire        [LINE_SIZE - 1: 0]              line_o;
wire         [ADDRESS_SIZE - 1: 0]          address_from_CPU_i;

//integers
integer i = 0;                                                          


//Instantiate DUT and other required modules
DMC_Controller #(.BLOCK_SIZE(BLOCK_SIZE), .NUM_OF_BLOCKS_PER_LINE(NUM_OF_BLOCKS_PER_LINE), .NUM_OF_CACHE_LINES(NUM_OF_CACHE_LINES), .ADDRESS_SIZE(ADDRESS_SIZE)) DUT (
                                                   .clk_i(clk_i),
                                                   .rst_n_i(rst_n_i),
                                                   .read_i(read_i),
                                                   .write_i(write_i),
                                                   .hit_i(hit_i),
                                                   .start_from_CPU_i(start_from_CPU_i),
                                                   .read_flush_i(read_flush_i),
                                                   .read_fetch_i(read_fetch_i),
                                                   .write_flush_i(write_flush_i),
                                                   .write_fetch_i(write_fetch_i),
                                                   .address_from_CPU_i(address_from_CPU_i),
                                                   .address_from_cache_i(address_from_cache_i),
                                                   .data_from_CPU_i(data_from_CPU_i),
                                                   .data_from_cache_i(data_from_cache_i),
                                                   .data_from_memory_i(data_from_memory_i),
                                                   .line_i(line_i),
                                                   .data_to_CPU_o(data_to_CPU_o),
                                                   .data_to_cache_o(data_to_cache_o),
                                                   .data_to_memory_o(data_to_memory_o),
                                                   .line_o(line_o),
                                                   .address_to_cache_o(address_to_cache_o),
                                                   .address_to_memory_o(address_to_memory_o),
                                                   .ready_to_CPU_o(ready_to_CPU_o),
                                                   .mem_read_o(mem_read_o),
                                                   .mem_write_o(mem_write_o),
                                                   .read_o(read_o),
                                                   .read_line_o(read_line_o),
                                                   .write_o(write_o),
                                                   .write_line_o(write_line_o) 
);


memory #(.BLOCK_SIZE(BLOCK_SIZE), .ADDRESS_SIZE(ADDRESS_SIZE)) test_memory (
                                                    .clk_i(clk_i),
                                                    .read_i(mem_read),
                                                    .write_i(mem_write),
                                                    .data_i(mem_data_i),
                                                    .address_i(mem_address_i),
                                                    .data_o(data_from_memory_i)
                                                    
);

DirectMappedCache #(.BLOCK_SIZE(BLOCK_SIZE), .NUM_OF_BLOCKS_PER_LINE(NUM_OF_BLOCKS_PER_LINE), .NUM_OF_CACHE_LINES(NUM_OF_CACHE_LINES), .ADDRESS_SIZE(ADDRESS_SIZE))
cache (
                                                    .clk_i(clk_i),
                                                    .rst_n_i(rst_n_i),
                                                    .read_i(read_o),
                                                    .write_i(write_o),
                                                    .write_line_i(write_line_o),
                                                    .read_line_i(read_line_o),
                                                    .address_i(address_to_cache_o),
                                                    .data_i(data_to_cache_o),
                                                    .line_i(line_o),
                                                    .data_o(data_from_cache_i),
                                                    .line_o(line_i),
                                                    .address_o(address_from_cache_i),
                                                    .hit_o(hit_i),
                                                    .read_flush_o(read_flush_i),
                                                    .read_fetch_o(read_fetch_i),
                                                    .write_flush_o(write_flush_i),
                                                    .write_fetch_o(write_fetch_i)
);

//Assigns
//input to memory either from tb (to populate memory) or from cache during normal operation.
assign mem_data_i = mem_data_from_tb ? mem_tb_data_i : data_to_memory_o;
assign mem_address_i = mem_address_from_tb ? mem_tb_address_i : address_to_memory_o;
assign mem_read = mem_read_from_tb ? mem_tb_read_i : mem_read_o;
assign mem_write = mem_write_from_tb ? mem_tb_write_i : mem_write_o;


assign address_from_CPU_i = {tag, index, block_offset};

initial begin
    
    //Populate Memory
    mem_data_from_tb = 1;
    mem_address_from_tb = 1;
    mem_read_from_tb  = 1;
    mem_write_from_tb = 1;
    mem_tb_write_i = 1;
    for(i=0; i < 17; i = i+1) begin
        #10;
        mem_tb_data_i  = i;
        mem_tb_address_i  = i;
    end
    mem_data_from_tb = 0;
    mem_address_from_tb = 0;
    mem_read_from_tb  = 0;
    mem_write_from_tb = 0;
    mem_tb_write_i = 0;
    
    //reset controller and cache
    rst_n_i = 0;
    #10
    rst_n_i = 1;
    
    //Wait a lot of cycles to esnure reset
    #50
    
    //Begin tests
    $display("---------------------------------------------------------------------------------");
    $display("Beginning DMC_Controller Testbench");
    $display("---------------------------------------------------------------------------------\n");
    
    //At the beginning, every line of the cache should be invalid. Test read_fetch and write_fetch by issuing read and write commands
    $display("---------------------------------------------------------------------------------");
    $display("Test 1: read_fetch functionality");
    $display("---------------------------------------------------------------------------------\n");
    @(negedge clk_i);
    start_from_CPU_i = 1; read_i = 1; tag = 'b0; index = 'b0; block_offset = 'b0;
    #10
    start_from_CPU_i = 0; read_i = 0;
    #10
    
    wait(ready_to_CPU_o);
    if(data_to_CPU_o == 0) begin
        $display("---------------------------------------------------------------------------------");
        $display("Test 1 Success :D !");
        $display("---------------------------------------------------------------------------------\n");
    end
    else begin
        $display("---------------------------------------------------------------------------------");
        $display("Test 1 Failure D: !");
        $display("Data received to CPU: %d", data_to_CPU_o);
        $display("---------------------------------------------------------------------------------\n");
    end
    
    $display("---------------------------------------------------------------------------------");
    $display("Test 2: write functionality");
    $display("---------------------------------------------------------------------------------\n");
    @(negedge clk_i);
    start_from_CPU_i = 1; write_i = 1; tag = 'b0; index = 'b1; block_offset = 'b0; data_from_CPU_i = 'b0;
    #10
    start_from_CPU_i = 0; write_i = 0;
    #10
    
    wait(ready_to_CPU_o);
    if(data_to_CPU_o == 0) begin
        $display("---------------------------------------------------------------------------------");
        $display("Test 2 Success :D !");
        $display("---------------------------------------------------------------------------------\n");
    end
    else begin
        $display("---------------------------------------------------------------------------------");
        $display("Test 2 Failure D: !");
        $display("Data received to CPU: %d", data_to_CPU_o);
        $display("---------------------------------------------------------------------------------\n");
    end
    
    #100
    
    $finish;
end

//Generate Clock
always begin
#5 clk_i <= !clk_i;
end

endmodule
