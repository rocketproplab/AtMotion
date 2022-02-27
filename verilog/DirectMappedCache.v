module DirectMappedCache #( parameter       BLOCK_SIZE = 32;
                            parameter       NUM_OF_BLOCKS_PER_LINE = 4;
                            parameter       NUM_OF_CACHE_LINES = 4;
                            parameter       ADDRESS_SIZE = 32;
                            )
(clk, read, write, address, data_i, data_o, hit, miss);
//Inputs
input clk, read, write;
input [ADDRESS_SIZE - 1: 0] address;
input [BLOCK_SIZE - 1: 0] data_i;

//Outputs
output reg [BLOCK_SIZE - 1: 0] data_o;
output reg hit; //Should this be a reg or wire?
output reg miss;

//Calculate localparams
localparam BLOCK_OFFSET_LENGTH = $clog2(NUM_OF_BLOCKS_PER_LINE);
localparam INDEX_LENGTH = $clog2(NUM_OF_CACHE_LINES);
localparam TAG_LENGTH = ADDRESS_SIZE - BLOCK_OFFSET_LENGTH - INDEX_LENGTH;
localparam DIRTY_BIT = 1'b1;
localparam VALID_BIT = 1'b1;
localparam CACHE_LINE_LENGTH = DIRTY_BIT + VALID_BIT + TAG_LENGTH + NUM_OF_BLOCKS_PER_LINE * BLOCK_SIZE - 1;
localparam DIRTY_BIT_INDEX = CACHE_LINE_LENGTH;
localparam VALID_BIT_INDEX = CACHE_LINE_LENGTH - DIRTY_BIT;
localparam TAG_INDEX = CACHE_LINE_LENGTH - DIRTY_BIT - VALID_BIT;

/* 
Cache Line format is (big endian) {DIRTY_BIT, VALID_BIT, TAG (TAG_LENGTH bits), DATA BLOCKS (BLOCK_SIZE * NUM_OF_BLOCKS_PER_LINE bits)}
*/

/*
Address format is (big endian) {TAG (TAG_LENGTH bits), index (INDEX_LENGTH bits), block_offset(BLOCK_OFFSET_LENGTH bits)}
*/

//Local Variables
reg [BLOCK_OFFSET_LENGTH - 1: 0] block_offset;
reg [INDEX_LENGTH - 1: 0] index;
reg cache [NUM_OF_CACHE_LINES - 1: 0][CACHE_LINE_LENGTH : 0];

//Grab index and block offset from address. IDK if this needs to be done every clock cycle
//Consider if this should be an assign block (which can change in clock cycle) or needs to be sequential
always @(posedge clk ) begin

    //Also I think this will be invalid for the first clock cycle. Since this will likely become a FSM, I could add a STALL cycle here?
    block_offset <= address[BLOCK_OFFSET_LENGTH - 1 -: BLOCK_OFFSET_LENGTH];
    index <= address[INDEX_LENGTH + BLOCK_OFFSET_LENGTH - 1 -: INDEX_LENGTH];

end

//Read Functionality
always @(posedge clk) begin

    if(read) begin
        if(cache[index][VALID_BIT_INDEX]) begin
            if(cache[index][DIRTY_BIT_INDEX]) begin
            //Cache line is valid but dirty. This counts as a miss, the controller will handle this
                hit <= 0;
                miss <= 1;
        
                //I will not change data_o. The controller should know that if miss is high, data is not valid regardless
                //TODO: Setup controller to read miss, fetch data, and write it valid then rerurn the read request
            end
            else begin
            //Cache line is valid and not dirty. This could be a hit!
                if(address[ADDRESS_SIZE - 1 -: TAG_LENGTH] == cache[index][TAG_INDEX -: TAG_LENGTH]) begin
                //If Address tag matches cache line tag, its a hit!:
                    hit <= 1;
                    miss <= 0;
            
                    data_o <= cache[index][block_offset*BLOCK_SIZE - 1 -: BLOCK_SIZE];
                end
                else begin
                //Cache line does not match tag, its a miss
                    hit <= 0;
                    miss <= 1;
            
                    //I will not change data_o. The controller should know that if miss is high, data is not valid regardless
                    //TODO: Setup controller to read miss, fetch data, and write it valid then rerurn the read request
                end
            end
            
        end
        else begin
        //Line was not valid, miss
            hit <= 0;
            miss <= 1;
    
            //I will not change data_o. The controller should know that if miss is high, data is not valid regardless
            //TODO: Setup controller to read miss, fetch data, and write it valid then rerurn the read request
        end
    end
end

//TODO: Add Write functionality
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
    
            //I will not change data_o. The controller should know that if miss is high, data is not valid regardless
            //TODO: Setup controller to read miss, fetch data, and write it valid then rerurn the read request
        end

    end

end





endmodule