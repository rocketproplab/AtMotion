module DirectMappedCache #( parameter       BLOCK_SIZE = 32;
                            parameter       NUM_OF_BLOCKS_PER_LINE = 4;
                            parameter       NUM_OF_CACHE_LINES = 4;
                            parameter       ADDRESS_SIZE = 32;
                            )
(clk, rst_n, read, write, write_line, address, data_i, line_i, data_o, hit, miss);

//Inputs
input clk, read, write, write_line;
input [ADDRESS_SIZE - 1: 0] address;
input [BLOCK_SIZE - 1: 0] data_i;
input [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_i;

//Outputs
output reg [BLOCK_SIZE - 1: 0] data_o;
output reg hit; //Should this be a reg or wire?
output reg miss;

//Calculate localparams
localparam BLOCK_OFFSET_LENGTH = $clog2(NUM_OF_BLOCKS_PER_LINE);
localparam INDEX_LENGTH = $clog2(NUM_OF_CACHE_LINES);
localparam TAG_LENGTH = ADDRESS_SIZE - BLOCK_OFFSET_LENGTH - INDEX_LENGTH;
localparam DIRTY_BIT = 1'b1; //constant value used in address indexing for clarity, not used in address
localparam VALID_BIT = 1'b1; //constant value used in address indexing for clarity, not used in address
localparam CACHE_LINE_LENGTH = DIRTY_BIT + VALID_BIT + TAG_LENGTH + NUM_OF_BLOCKS_PER_LINE * BLOCK_SIZE;
localparam DIRTY_BIT_INDEX = CACHE_LINE_LENGTH - 1;
localparam VALID_BIT_INDEX = CACHE_LINE_LENGTH - 1 - DIRTY_BIT;
localparam TAG_INDEX = CACHE_LINE_LENGTH -1 - DIRTY_BIT - VALID_BIT;

/* 
Cache Line format is (big endian) {DIRTY_BIT, VALID_BIT, TAG (TAG_LENGTH bits), DATA BLOCKS (BLOCK_SIZE * NUM_OF_BLOCKS_PER_LINE bits)}
*/

/*
Address format is (big endian) {TAG (TAG_LENGTH bits), index (INDEX_LENGTH bits), block_offset(BLOCK_OFFSET_LENGTH bits)}
*/

//Local Variables
wire [BLOCK_OFFSET_LENGTH - 1: 0] block_offset;
wire [INDEX_LENGTH - 1: 0] index;
wire [TAG_LENGTH - 1: 0] tag;
reg cache [NUM_OF_CACHE_LINES - 1: 0][CACHE_LINE_LENGTH - 1: 0];

//NOTE: Assume all inputs are registered, so that tag, index, block_offset can be set via assign
//      and therefore be available on the same clock cycle
assign index = address[INDEX_LENGTH + BLOCK_OFFSET_LENGTH - 1 -: INDEX_LENGTH];
assign block_offset = address[BLOCK_OFFSET_LENGTH - 1 -: BLOCK_OFFSET_LENGTH];
assign tag = address[ADDRESS_SIZE - 1 -: TAG_LENGTH];

//Reset Functionality
always @(posedge clk ) begin
    if(!rst_n) begin
        cache <= 0;
        data_o <= 0;
        hit <= 0;
        miss <= 0;
    end
end

//Read Functionality
always @(posedge clk) begin
    if(read) begin
        if(cache[index][VALID_BIT_INDEX] & !cache[index][DIRTY_BIT_INDEX]) begin
            //If given cache line is valid and not dirty:
            if(cache[index][TAG_INDEX -: TAG_LENGTH] == tag) begin
                //If Address tag matches cache line tag, its a hit!
                    hit <= 1;
                    miss <= 0;
            
                    data_o <= cache[index][block_offset*BLOCK_SIZE - 1 -: BLOCK_SIZE];
            end
            else begin
                //Cache line tag did not match input tag, its a miss
                hit <= 0;
                miss <= 1;
            end
        end
        else begin
            //Line not valid or its dirty, its a miss
            hit <= 0;
            miss <= 1;
        end
    end
end

//Write Functionality
always @(posedge clk ) begin
    if(write) begin
        //NOTE: I think I do not need to check if the cache line being written to is dirty or not, as the line has not been flushed
        //      So there is no reason to write the dirty line, read it back in, then update it again. Instead just update the dirty line.
        if(cache[index][VALID_BIT_INDEX]) begin
            //Cache line is valid
            //Write the input data into the cache line block
            cache[index][[block_offset*BLOCK_SIZE - 1 -: BLOCK_SIZE] <= data_i;

        end
        else begin
            //Cache line is not valid. Still need to read in data before writing to it.
            hit <= 0;
            miss <= 1;
        end
    end
end

//Write line functionality
//Input address, when paired with line_write, will give us the tag to be written and which index its at
always @(posedge clk ) begin
    if(write_line) begin
        //Write cache line as valid, clean, and with line_i data
        //I hope this construction works!
        cache[index] = {1'b0, 1'b1, tag, line_i};
    end
end


endmodule