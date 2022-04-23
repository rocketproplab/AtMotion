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

    wire [ADDRESS_SIZE - 1: 0] address;
    reg [BLOCK_SIZE - 1: 0] data_i;
    reg [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_i;


    wire hit, miss;

    reg [BLOCK_OFFSET_LENGTH - 1: 0] block_offset;
    reg [INDEX_LENGTH - 1: 0] index;
    reg [TAG_LENGTH - 1: 0] tag;
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

    assign address = {tag, index, block_offset};


    /*
    ---------------------------------------------------------------------------------
    Direct Mapped Cache Test Cases
    ---------------------------------------------------------------------------------

    1. Attempt to read a block from a line that is not valid (miss)
    2. Attempt to write a block to a line that is not valid (miss)
    3. Attempt to write a full line using write_line and line_i (hit)
    4. Attempt to read a block from a valid, clean line (hit)
    5. Attempt to read a block from a valid, clean line (miss)
    6. Attempt to write a block to a line that is valid, clean (hit)
    7. Attempt to write a block to a valid, dirty line (hit)
    8. Attempt to write a block to a line that is invalid (miss)

    */


    initial begin

        $display("---------------------------------------------------------------------------------");
        $display("Beginning DirectMappedCache Testbench");
        $display("---------------------------------------------------------------------------------\n");

        //initialize all values to reasonable stuff
        clk = 1'b0; rst_n = 1'b1; read = 1'b0; write = 1'b0; write_line = 1'b0; tag = 'b0; index = 'b0; block_offset = 'b0; 
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
        $display("--------------------------------------------------------------------\n");

        //We have just reset the cache, every line is invalid. Therefore we can just attempt to read address 0

        //Setup variables to read address 0
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; read = 1;
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
        $display("Begin Test Case 8. Attempt to write a block to a line that is invalid (miss)");
        $display("--------------------------------------------------------------------\n");

        //any index besides index = 0 has not been initialized and is invalid. Attempt to write to index = 1
        //Setup variables to write a block
        clk = 1; tag = 'b0; index = 'b1; block_offset = 'b0; write = 1; data_i = 'h2;

        //don't write to local cache since this write should fail

        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycle to receive hit or miss and data
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( miss == 1 ) begin
            $display("Test Case 8 Success!");
        end
        else begin
            $display("Test Case 8 Failure :(");
        end


        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 2: Attempt to write a block to a line that is not valid (miss)");
        $display("--------------------------------------------------------------------\n");

        //Cache is still fully reset, just attempt to write

        //initialize variables to write. It doesn't matter where so just keep address as 0
        //Setup variables to read address 1
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; write = 1;
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
        $display("--------------------------------------------------------------------\n");

        //initialize variables to write line. It doesn't matter where so just keep address as 0
        //Setup variables to write line
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; write_line = 1;

        //setup line_i, and use it to populate local_cache

        //This is how I would do it if I were cool:
        //line_i = $urandom_range(1, 1 << (NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1));

        //This is how I must do it :(
        line_i = 'h4; //bro this is straight nasty wtf


        //actual setting of local_cache
        local_cache[index] = {1'b0, 1'b1, tag, line_i};


        #10
        clk = 0; write_line = 0;
        #10

        //wait one clock cycle to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( hit == 1 ) begin
            $display("Test Case 3 Success!");
        end
        else begin
            $display("Test Case 3 Failure :(");
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 4. Attempt to read a block from a valid, clean line (hit)");
        $display("--------------------------------------------------------------------\n");

        //At the end of the last test, we have a clean valid line stored from Address 0
        //Setup variables to read a block
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; read = 1;

        #10
        clk = 0; read = 0;
        #10

        //wait one clock cycle to receive hit or miss and data
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        $display("DUT output data: %b, Expected output data: %b", data_o, local_cache[index][block_offset*BLOCK_SIZE + BLOCK_SIZE - 1 -: BLOCK_SIZE]);
        if( hit == 1 ) begin
            $display("Test Case 4: Read Hit");

            if(data_o == local_cache[index][block_offset*BLOCK_SIZE + BLOCK_SIZE - 1 -: BLOCK_SIZE]) begin
                $display("Data received succesfully!");
                $display("Test Case 4 Success!");
            end else begin
                $display("Incorrect Data received.");
                $display("Test Case 4 Failure!");
            end
        end
        else begin
            $display("Test Case 4: Read miss :(");
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 5. Attempt to read a block from a valid, clean line (miss)");
        $display("--------------------------------------------------------------------\n");

        //address 0 line written as 'h4. To read a valid, clean line and miss we need same index but different tag
        //Setup variables to read a block
        clk = 1; tag = 'b1; index = 'b0; block_offset = 'b0; read = 1;

        #10
        clk = 0; read = 0;
        #10

        //wait one clock cycle to receive hit or miss and data
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( miss == 1 ) begin
            $display("Test Case 5 Success!");
        end
        else begin
            $display("Test Case 5 Failure :(");
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 6. Attempt to write a block to a line that is valid, clean (hit)");
        $display("--------------------------------------------------------------------\n");

        //tag = 0, index = 0, block_offset = 0 still contains 'h4 and is valid. We will write to that.
        //Setup variables to write a block
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; write = 1; data_i = 'b1;

        //write to local_cache to track our changes incase we need to later compare
        local_cache[index][block_offset*BLOCK_SIZE + BLOCK_SIZE - 1 -: BLOCK_SIZE] = data_i;

        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycle to receive hit or miss and data
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( hit == 1 ) begin
            $display("Test Case 6 Success!");
        end
        else begin
            $display("Test Case 6 Failure :(");
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 7. Attempt to write a block to a valid, dirty line (hit)");
        $display("--------------------------------------------------------------------\n");

        //tag = 0, index = 0, block_offset = 0 contains 'b1 and is valid but dirty. We will write to that.
        //Setup variables to write a block
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; write = 1; data_i = 'h2;

        //write to local_cache to track our changes incase we need to later compare
        local_cache[index][block_offset*BLOCK_SIZE + BLOCK_SIZE - 1 -: BLOCK_SIZE] = data_i;

        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycle to receive hit or miss and data
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( hit == 1 ) begin
            $display("Test Case 7 Success!");
        end
        else begin
            $display("Test Case 7 Failure :(");
        end

    end

endmodule