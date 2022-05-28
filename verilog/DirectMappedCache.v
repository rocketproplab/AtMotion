/*
Direct Mapped Cache
Written by Chase Bastian 2022 for UCSD RPL
I don't know legal speak but this is probably broken so I don't recommend using it.
*/

module DirectMappedCache #( parameter       BLOCK_SIZE = 32,
                            parameter       NUM_OF_BLOCKS_PER_LINE = 4,
                            parameter       NUM_OF_CACHE_LINES = 4,
                            parameter       ADDRESS_SIZE = 32
                            )
(

//Inputs
input rst_n_i, clk_i, read_i, write_i, write_line_i, read_line_i,
input [ADDRESS_SIZE - 1: 0] address_i,
input [BLOCK_SIZE - 1: 0] data_i,
input [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_i, //input data only not including tag or index. Still uses address input for this

//Outputs
output reg [BLOCK_SIZE - 1: 0] data_o,
output reg [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_o,
output reg [ADDRESS_SIZE - 1: 0]                        address_o,
output reg hit_o, read_flush_o, read_fetch_o, write_flush_o, write_fetch_o
);

//Local Registers
reg rst_n_reg, read_reg, write_reg, write_line_reg, read_line_reg;
reg [ADDRESS_SIZE - 1: 0] address_reg;
reg [BLOCK_SIZE - 1: 0] data_i_reg;
reg [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_i_reg;

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

//Cache Line

reg  [CACHE_LINE_LENGTH - 1: 0] cache [NUM_OF_CACHE_LINES - 1: 0]; //Individual Cache Lines are packed, but the collection of lines is unpacked

//Iterator Variables
integer i = 0;

//Assigns
assign index = address_reg[INDEX_LENGTH + BLOCK_OFFSET_LENGTH - 1 -: INDEX_LENGTH];
assign block_offset = address_reg[BLOCK_OFFSET_LENGTH - 1 -: BLOCK_OFFSET_LENGTH];
assign tag = address_reg[ADDRESS_SIZE - 1 -: TAG_LENGTH];

//Input registering
always @(posedge clk_i) begin
     rst_n_reg <= rst_n_i;
     read_reg <= read_i;
     write_reg <= write_i;
     write_line_reg <= write_line_i;
     read_line_reg <= read_line_i;
     address_reg <= address_i;
     data_i_reg <= data_i;
     line_i_reg <= line_i;
end

//Reset Functionality
//Note: Internally there will be no reset. Instead, the controller will execute the order to reset the cache. Used only for testbench
always @(posedge clk_i ) begin
    if(!rst_n_reg) begin
        hit_o <= 0;
        read_flush_o <= 0;
        read_fetch_o <= 0;
        write_flush_o <= 0;
        write_fetch_o <= 0;

        for(i = 0; i < NUM_OF_CACHE_LINES; i = i + 1) begin
            cache[i][VALID_BIT_INDEX] <= 0;
        end
    end
end

//Read Functionality
/*
If line index of read is Valid:
    If line is dirty:
        If tag matches:
            return requested data
        If tag does not match:
            Flush it (write it to memory), then read in data from address in memory, then return requested data
    If line is not dirty:
        If tag matches:
            return requested data
        If tag does not match:
            Read in data from address in memory, then return requested data
If line index of read is invalid:
    Read in data from address in memory, then return requested data
    
Case 1: line is valid and tag matches:
    return requested data
    hit = 1
    
Case 2: line is valid, dirty, and tag does not match:
    Flush it (write it to memory), then read in data from address in memory, then return requested data
    read_flush = 1
    
Case 3: line is valid, not dirty, and tag does not match:
    Read in data from address in memory, then return requested data
    read_fetch = 1
    
Case 4: line is invalid:
    Read in data from address in memory, then return requested data
    read_fetch = 1
    
Default: Just set every signal to 0
    

    
Required output signals:
    hit
    read_flush
    read_fetch
*/
always @(posedge clk_i) begin
   
    //Default Values
    hit_o <= 0;
    read_flush_o <= 0;
    read_fetch_o <= 0;
    write_flush_o <= 0;
    write_fetch_o <= 0;
    
    if(read_reg) begin 
    
        //Case 1: line is valid and tag matches:
        if(cache[index][VALID_BIT_INDEX] && cache[index][TAG_INDEX -: TAG_LENGTH] == tag) begin
            hit_o <= 1;
            data_o <= cache[index][block_offset*BLOCK_SIZE + BLOCK_SIZE - 1 -: BLOCK_SIZE];
        end
//      Case 2: line is valid, dirty, and tag does not match:
        else if(cache[index][VALID_BIT_INDEX] && cache[index][DIRTY_BIT_INDEX] && !(cache[index][TAG_INDEX -: TAG_LENGTH] == tag)) begin
            read_flush_o <= 1;
        end
//      Case 3: line is valid, not dirty, and tag does not match:
        else if(cache[index][VALID_BIT_INDEX] && !cache[index][DIRTY_BIT_INDEX] && !(cache[index][TAG_INDEX -: TAG_LENGTH] == tag)) begin
            read_fetch_o <= 1;
        end
//      Case 4: line is invalid:
        else if(!cache[index][VALID_BIT_INDEX]) begin
            read_fetch_o <= 1;
        end
    end
end


//Write Functionality
/*
    If Line is valid:
        If Tag matches, write input data into cache
        If Tag does not match:
            If the line is dirty, first flush it (write it to memory), then read in data from address in memory, then write data to cache
            If the line is not dirty, read in data from address in memory, then write data to cache
    If Line is invalid:
        read in data from address in memory, then write data to cache
    
    Case 1: Line is valid and tag matches:
        hit = 1
        
    Case 2: Line is valid, dirty, and tag does not match:
        write_flush_o = 1
        
    Case 3: Line is valid, not dirty, and tag does not match:
        write_fetch_o = 1
        
    Case 4: Line is invalid
        write_fetch_o = 1
    
    Default: all signals to 0
    
    
required output signals:
    hit_o
    write_flush_o
    write_fetch_o
*/
always @(posedge clk_i ) begin
    if(write_reg) begin
    
//        Case 1: Line is valid and tag matches:
        if(cache[index][VALID_BIT_INDEX] && cache[index][TAG_INDEX -: TAG_LENGTH] == tag) begin
            hit_o <= 1;
            read_flush_o <= 0;
            read_fetch_o <= 0;
            write_flush_o <= 0;
            write_fetch_o <= 0;
            
            //Succesful write, write data_i to cache
            cache[index][ DIRTY_BIT_INDEX ] <= 1;
            cache[index][ block_offset*BLOCK_SIZE + BLOCK_SIZE - 1 -: BLOCK_SIZE] <= data_i_reg;
        end
//        Case 2: Line is valid, dirty, and tag does not match:
        else if(cache[index][VALID_BIT_INDEX] && cache[index][DIRTY_BIT_INDEX] && !(cache[index][TAG_INDEX -: TAG_LENGTH] == tag)) begin
            hit_o <= 0;
            read_flush_o <= 0;
            read_fetch_o <= 0;
            write_flush_o <= 1;
            write_fetch_o <= 0;
        end
//        Case 3: Line is valid, not dirty, and tag does not match:
        else if(cache[index][VALID_BIT_INDEX] && !cache[index][DIRTY_BIT_INDEX] && !(cache[index][TAG_INDEX -: TAG_LENGTH] == tag)) begin
            hit_o <= 0;
            read_flush_o <= 0;
            read_fetch_o <= 0;
            write_flush_o <= 0;
            write_fetch_o <= 1;
        end
//        Case 4: Line is invalid
        else if(!cache[index][VALID_BIT_INDEX]) begin
            hit_o <= 0;
            read_flush_o <= 0;
            read_fetch_o <= 0;
            write_flush_o <= 0;
            write_fetch_o <= 1;
        end
        //Default
        else begin
            hit_o <= 0;
            read_flush_o <= 0;
            read_fetch_o <= 0;
            write_flush_o <= 0;
            write_fetch_o <= 0;
        end
    end
end

//Write line functionality
//Input address, when paired with line_write, will give us the tag to be written and which index its at
//This will be used to flush lines. If a line is not being flushed, we will be writing one block of data. If its being flushed,
//We would be writing an entire line.
always @(posedge clk_i ) begin
    if(write_line_reg) begin
        //Write cache line as valid, clean, and with line_i data
        cache[index] = {1'b0, 1'b1, tag, line_i_reg};

        //hit_o <= 1;
    end
end

//Read line functionality
//Reads entire cache line data based on input address
//Note: No checking for conditions, assume this command only comes from controller when trying to flush lines (so should not miss)
always@(posedge clk_i) begin
    if(read_line_reg) begin
        hit_o <= 1;
        read_flush_o <= 0;
        read_fetch_o <= 0;
        write_flush_o <= 0;
        write_fetch_o <= 0;
        
        line_o <= cache[index][(TAG_INDEX - TAG_LENGTH) -: NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE];
        address_o <= { cache[index][ TAG_INDEX -: TAG_LENGTH ], index, 'b0};
    end
end


endmodule