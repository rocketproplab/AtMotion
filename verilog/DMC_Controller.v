//Direct Mapped Cache Controller
//Interfaces between CPU, Main Memory, and Cache
module DMC_Controller #(
                            parameter       BLOCK_SIZE = 32,
                            parameter       NUM_OF_BLOCKS_PER_LINE = 4,
                            parameter       NUM_OF_CACHE_LINES = 4,
                            parameter       ADDRESS_SIZE = 32
)
(
input                                                   clk_i,
input                                                   rst_n_i,
input                                                   write_i,
input                                                   read_i,
input                                                   hit_i,
input                                                   start_from_CPU_i,
input                                                   read_flush_i,
input                                                   read_fetch_i,
input                                                   write_flush_i,
input                                                   write_fetch_i,
input       [ADDRESS_SIZE - 1: 0]                       address_from_CPU_i,
input       [ADDRESS_SIZE - 1: 0]                       address_from_cache_i,
input       [BLOCK_SIZE - 1: 0]                         data_from_CPU_i,
input       [BLOCK_SIZE - 1: 0]                         data_from_cache_i,
input       [BLOCK_SIZE - 1: 0]                         data_from_memory_i,
input       [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1: 0]  line_i,
output  reg [BLOCK_SIZE - 1: 0]                         data_to_CPU_o,
output  reg [BLOCK_SIZE - 1: 0]                         data_to_cache_o,
output  reg [BLOCK_SIZE - 1: 0]                         data_to_memory_o,
output  reg [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1: 0]  line_o,
output  reg [ADDRESS_SIZE - 1: 0]                       address_to_cache_o,
output  reg [ADDRESS_SIZE - 1: 0]                       address_to_memory_o,
output  reg                                             ready_to_CPU_o,
output  reg                                             mem_read_o,
output  reg                                             mem_write_o,
output  reg                                             read_o,
output  reg                                             read_line_o,
output  reg                                             write_o,
output  reg                                             write_line_o
        );


//Local Parameters
localparam HIT = 0;
localparam READ_FLUSH = 1;
localparam READ_FETCH = 2;
localparam WRITE_FLUSH = 3;
localparam WRITE_FETCH = 4;

localparam READY = 0;
localparam READ = 1;
localparam READ_RESPONSE = 2;
localparam WRITE = 3;
localparam WRITE_RESPONSE = 4;
localparam FLUSH_CACHE_LINE = 5;
localparam READ_LINE = 6;
localparam WRITE_TO_MEM = 7;
localparam READ_FROM_MEM = 8;
localparam WAIT_MEM_READ = 9;
localparam RECEIVE_FROM_MEM = 10;
localparam WRITE_LINE = 11;

//Variables
reg [$clog2(NUM_OF_BLOCKS_PER_LINE): 0] block_count;
reg [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1: 0] local_line;
reg [ADDRESS_SIZE - 1: 0] address_reg, address_from_cache_reg;
reg [BLOCK_SIZE - 1: 0] data_from_CPU_reg, data_from_cache_reg;
reg read_reg, write_reg;
reg [5:0] state = READY;

wire [4:0] response; //eww hardcoded length

integer i;

//Assignments

/*
FSM

States:
    READY:
        Signals to CPU that request was complete, outputs data
        Awaits start signal for another request
    READ:
        Sends signals to cache to read an address.
        Always transitions to READ_RESPONSE
    READ_RESPONSE:
        inteprets response from cache. Cases for hit, flush, and fetch.
    WRITE:
        Sends signals to cache to write to an address
        always transitions to WRITE_RESPONSE
    WRITE_RESPONSE:
        interprets response from cache. Cases for hit, flush, and fetch.
    FLUSH_CACHE_LINE:
        Sends signals to cache to read a line
        always transitions to READ_LINE
    READ_LINE:
        reads line from cache, then writes it to memory
        always transitions to WRITE_TO_MEM
    WRITE_TO_MEM:
        Writes a line of data to memory
        always transitions to READ_FROM_MEM
    READ_FROM_MEM
        Reads a line of data from memory
        always transitions to WRITE_LINE
    WRITE_LINE:
        write line received from memory to cache.
        Always retries original instruciton to memory (read/write), as this is the last state when any miss conditions have been handled.
*/
always@(posedge clk_i) begin
    
    case(state)
        READY: begin
        
            data_to_CPU_o <= data_from_cache_reg; //output data, CPU will take it if its relevant
            ready_to_CPU_o <= 1;
            
            if(start_from_CPU_i) begin
            
                //Register input signals
                address_reg <= address_from_CPU_i;
                data_from_CPU_reg <= data_from_CPU_i;
                read_reg <= read_i;
                write_reg <= write_i;
                
                //mark that we are not ready
                ready_to_CPU_o <= 0;
                
                //reset block_count after every loop
                block_count <= 0;
                
                //Transition to next states
                if(read_i) begin
                    state <= READ;
                end
                else if(write_i) begin
                    state <= WRITE;
                end
                else begin //CPU issued a start but with no instruction, just stay in ready state
                    state <= READY;
                    $display("START RECEIEVED FROM CPU WITH NO INSTRUCTION");
                end
            end
        end
        READ: begin
            read_o <= 1;
            address_to_cache_o <= address_reg;
            state <= READ_RESPONSE;
            write_line_o <= 0;
        end
        READ_RESPONSE: begin
            read_o <= 0;
            
            if(hit_i == 1) begin
                data_from_cache_reg <= data_from_cache_i;
                state <= READY;
            end
            else if(read_flush_i == 1) begin
                state <= FLUSH_CACHE_LINE;
            end
            else if(read_fetch_i == 1) begin
                state <= READ_FROM_MEM;
            end
            else begin
                state <= READ_RESPONSE;
            end
        end
        WRITE: begin
            data_to_cache_o <= data_from_CPU_reg;
            write_o <= 1;
            address_to_cache_o <= address_reg;
            write_line_o <= 0;
            state <= WRITE_RESPONSE;
        end
        WRITE_RESPONSE: begin
            write_o <= 0;
            
            if(hit_i == 1) begin
                state <= READY;
            end
            else if(write_flush_i == 1) begin
                state <= FLUSH_CACHE_LINE;
            end
            else if(write_fetch_i == 1) begin
                state <= READ_FROM_MEM;
            end
            else begin
                state <= WRITE_RESPONSE;
            end
        end
        FLUSH_CACHE_LINE: begin
            address_to_cache_o <= address_reg;
            read_line_o <= 1;
            state <= READ_LINE;
        end
        READ_LINE: begin
            read_line_o <= 0;
            
            local_line <= line_i;
            
            address_from_cache_reg <= address_from_cache_i;
            state <= WRITE_TO_MEM;
        end
        WRITE_TO_MEM: begin
            //TODO: Add checking to see if we are overflowing address
            
            //Increment block count each loop
            block_count <= block_count + 1;
            
            if(block_count < NUM_OF_BLOCKS_PER_LINE) begin //write blocks from line to memory
                mem_write_o <= 1;
                data_to_memory_o <= local_line[block_count*BLOCK_SIZE + BLOCK_SIZE  - 1 -: BLOCK_SIZE];  //This might write once more than intended, TBD
                address_to_memory_o <= (address_from_cache_reg + block_count);
            end
            else begin
                block_count <= 0;
                mem_write_o <= 0;
                
                //this state always goes to READ_FROM_MEM next
                state <= READ_FROM_MEM;
            end
            
        end
        
        READ_FROM_MEM: begin
            
            mem_read_o <= 1;
            address_to_memory_o <= (address_reg + block_count);
            state <= WAIT_MEM_READ;
            
        end
        WAIT_MEM_READ: begin
            mem_read_o <= 0;
            state <= RECEIVE_FROM_MEM;
        end
        RECEIVE_FROM_MEM: begin
            local_line[(block_count * BLOCK_SIZE) + BLOCK_SIZE - 1 -: BLOCK_SIZE]  <= data_from_memory_i;
            block_count <= block_count + 1;
            
            if(block_count < NUM_OF_BLOCKS_PER_LINE) begin
                state <= READ_FROM_MEM;
            end
            else begin
                block_count <= 0;
                state <= WRITE_LINE;
            end
        end
        WRITE_LINE: begin
            line_o <= local_line;
            write_line_o <= 1;
            address_to_cache_o <= address_reg;
            
            //After writing line to cache, reattempt to read/write what was missed.
            
            if(read_reg) begin
                state <= READ;
            end
            else if(write_reg) begin
                state <= WRITE;
            end
            else begin
                $display("GOT TO WRITE_LINE WITH INVALID INSTRUCTION");
                state <= READY;
            end
        end
    endcase
    
end

endmodule