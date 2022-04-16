module DirectMappedCache_tb();

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

    //Initialize local variables
    reg clk = 1'b0;
    reg rst_n = 1'b1;
    reg read = 1'b0;
    reg write = 1'b0;
    reg write_line = 1'b0;

    reg [ADDRESS_SIZE - 1: 0] address;
    reg [BLOCK_SIZE - 1: 0] data_i;
    reg [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_i;
    reg [INDEX_LENGTH - 1: 0] index;
    reg [TAG_LENGTH - 1: 0] tag;

    wire hit, miss;

    wire [TAG_LENGTH - 1: 0] tag;
    wire [INDEX_LENGTH - 1: 0] index;
    wire [BLOCK_OFFSET_LENGTH - 1: 0] block_offset;
    wire [BLOCK_SIZE - 1: 0] data_o;
    wire temp_blocks[NUM_OF_BLOCKS_PER_LINE - 1: 0][BLOCK_SIZE - 1: 0];
    

    //Test Cache
    reg [CACHE_LINE_LENGTH - 1: 0] local_cache[NUM_OF_CACHE_LINES - 1: 0];

    //Iterator Variables
    integer i = 0;


    //Initialize DUT
    DirectMappedCache #(    .BLOCK_SIZE(BLOCK_SIZE),
                            .NUM_OF_BLOCKS_PER_LINE(NUM_OF_BLOCKS_PER_LINE),
                            .NUM_OF_CACHE_LINES(NUM_OF_CACHE_LINES),
                            .ADDRESS_SIZE(ADDRESS_SIZE)
                            )
    DUT (.clk(clk), .rst_n(rst_n), .read(read), .write(write), .write_line(write_line), .address(address), 
    .data_i(data_i), .line_i(line_i), .data_o(data_o), .hit(hit), .miss(miss));


    /*
    ---------------------------------------------------------------------------------
    Direct Mapped Cache Test Cases
    ---------------------------------------------------------------------------------

    1. Attempt to read a block from a line that is not valid (miss)
    2. Attempt to write a block to a line that is not valid (miss)
    3. Attempt to write a full line using write_line and line_i (hit)
    4. Attempt to read a block from a valid, clean line (hit)
    5. Attempt to read a block from a valid, clean line (miss)
    6. Attempt to write a block to a valid, dirty line (hit)
    7. Attempt to write a block to a line that is valid, clean (hit)
    8. Attempt to write a block to a line that is invalid (miss)

    */


    initial begin

        $display("---------------------------------------------------------------------------------");
        $display("Beginning DirectMappedCache Testbench");
        $display("---------------------------------------------------------------------------------");

        //initialize all values to reasonable stuff
        clk = 1'b0; rst_n = 1'b1; read = 1'b0; write = 1'b0; write_line = 1'b0; address = 0; 
        data_i = 0; line_i = 0;

        //Reset the cache
        rst_n = 0; clk = 1;
        #10
        rst_n = 1; clk = 0;
        #10

        //Cycle the clock a few times to ensure reset
        for(i = 0; i < 4; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 1: Attempt to read a block from a line that is not valid (miss)");
        $display("--------------------------------------------------------------------");

        //We have just reset the cache, every line is invalid. Therefore we can just attempt to read address 0

        //Setup variables to read address 0
        clk = 1; address = 0; read = 1;
        #10
        clk = 0; read = 0;
        #10

        //wait one clock cycle to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( miss == 1 ) begin
            $display("Test Case 1 Success!");
        end
        else begin
            $display("Test Case 1 Failure :(");
        end

        //Reset the cache
        rst_n = 0; clk = 1;
        #10
        rst_n = 1; clk = 0;
        #10

        //Cycle the clock a few times to ensure reset
        for(i = 0; i < 4; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end


        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 2: Attempt to write a block to a line that is not valid (miss)");
        $display("--------------------------------------------------------------------");

        //Cache is still fully reset, just attempt to write

        //initialize variables to write. It doesn't matter where so just keep address as 0
        //Setup variables to read address 1
        clk = 1; address = 0; write = 1;
        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycle to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( miss == 1 ) begin
            $display("Test Case 2 Success!");
        end
        else begin
            $display("Test Case 2 Failure :(");
        end

        //For the next test cases, I will need to actually populate the Cache.
        //All of the remaining tests depend on writing cache lines, and that test depends on being able to read blocks
        //So time to start doing all this stuff I guess

        //Reset the cache
        rst_n = 0; clk = 1;
        #10
        rst_n = 1; clk = 0;
        #10

        //Cycle the clock a few times to ensure reset
        for(i = 0; i < 4; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 3: Attempt to write a full line using write_line and line_i (hit)");
        $display("--------------------------------------------------------------------");

        //initialize variables to write line. It doesn't matter where so just keep address as 0
        //Setup variables to write line
        clk = 1; address = 0; write_line = 1;
        index = address[INDEX_LENGTH + BLOCK_OFFSET_LENGTH - 1 -: INDEX_LENGTH];
        tag = address[ADDRESS_SIZE - 1 -: TAG_LENGTH];

        //setup line_i, and use it to populate local_cache
        line_i = $urandom_range(1, 1 << (NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1));

        for( i = 0; i < NUM_OF_BLOCKS_PER_LINE; i = i + 1) begin
            local_cache[index] = line_i[BLOCK_SIZE*i - 1 -: BLOCK_SIZE];
        end


        //Set dirty and valid bits
        local_cache[index][TAG_INDEX -: TAG_LENGTH] = tag;
        local_cache[index][DIRTY_BIT_INDEX] = 1'b0;
        local_cache[index][VALID_BIT_INDEX = 1'b1;


        #10
        clk = 0; write_line = 0;
        #10





    end



endmodule