module DirectMappedCache #( parameter       BLOCK_SIZE = 32;
                            parameter       NUM_OF_BLOCKS_PER_LINE = 4;
                            parameter       NUM_OF_CACHE_LINES = 4;
                            parameter       ADDRESS_SIZE = 32;
                            )
(clk, address, data_o, hit);
//Inputs
input clk;
input [ADDRESS_SIZE - 1: 0] address;

//Outputs
output reg [BLOCK_SIZE - 1: 0] data_o;
output reg hit; //Should this be a reg or wire?

//Calculate parameters
parameter BLOCK_OFFSET_LENGTH = $clog2(NUM_OF_BLOCKS_PER_LINE);
parameter INDEX_LENGTH = $clog2(NUM_OF_CACHE_LINES);
parameter TAG_LENGTH = ADDRESS_SIZE - block_offset_length - index_length;
parameter DIRTY_BIT = 1;
parameter VALID_BIT = 1;
parameter CACHE_LINE_LENGTH = DIRTY_BIT + VALID_BIT + TAG_LENGTH + NUM_OF_BLOCKS_PER_LINE * BLOCK_SIZE - 1;

//Local Variables
reg [block_offset_length - 1: 0] block_offset;
reg [index_length - 1: 0] index;
reg cache [NUM_OF_CACHE_LINES - 1: 0][CACHE_LINE_LENGTH : 0];

//Grab index and block offset from address. IDK if this needs to be done every clock cycle
always @(posedge clk ) begin

    //Also I think this will be invalid for the first clock cycle. Since this will likely become a FSM, I could add a STALL cycle here?
    block_offset <= address[block_offset_length - 1 +: block_offset_length];
    index <= address[index_length + block_offset - 1 +: index_length];

end

//Read Functionality
always @(posedge clk) begin

    if(address[ADDRESS_SIZE - 1 -: TAG_LENGTH] == cache[index][CACHE_LINE_LENGTH - DIRTY_BIT - VALID_BIT -: TAG_LENGTH]) begin //Address tag matches cache line tag
        hit <= 1;
        data_o <= cache[index][block_offset*BLOCK_SIZE - 1 -: BLOCK_SIZE];
    end

end

//TODO: Add Write functionality
//      Add valid bit functionality (initialize cache to all zeros, write valid bit each time theres a write?)
//      Probably more stuff I am forgetting
always @(posedge clk ) begin
    
end





endmodule