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
    reg read_line = 1'b0;

    wire [ADDRESS_SIZE - 1: 0] address;
    reg [BLOCK_SIZE - 1: 0] data_i;
    reg [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_i;


    wire hit, read_flush_o, read_fetch_o, write_flush_o, write_fetch_o;

    reg [BLOCK_OFFSET_LENGTH - 1: 0] block_offset;
    reg [INDEX_LENGTH - 1: 0] index;
    reg [TAG_LENGTH - 1: 0] tag;
    wire [BLOCK_SIZE - 1: 0] data_o;
    wire [NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE - 1 : 0] line_o;
    

    //Test Cache
    reg [CACHE_LINE_LENGTH - 1: 0] local_cache[NUM_OF_CACHE_LINES - 1: 0];

    //Iterator Variables
    integer i = 0, j = 0;


    //Initialize DUT
    //NOTE: I will change this once I think I have finished the full list of inputs and outputs
    DirectMappedCache #(    .BLOCK_SIZE             (BLOCK_SIZE),
                            .NUM_OF_BLOCKS_PER_LINE (NUM_OF_BLOCKS_PER_LINE),
                            .NUM_OF_CACHE_LINES     (NUM_OF_CACHE_LINES),
                            .ADDRESS_SIZE           (ADDRESS_SIZE)
                            )
    DUT (   .rst_n_i(rst_n), 
            .clk_i(clk), 
            .read_i(read), 
            .write_i(write), 
            .write_line_i(write_line), 
            .read_line_i(read_line), 
            .address_i(address), 
            .data_i(data_i), 
            .line_i(line_i), 
            .data_o(data_o), 
            .line_o(line_o), 
            .hit_o(hit), 
            .read_flush_o(read_flush_o),
            .read_fetch_o(read_fetch_o), 
            .write_flush_o(write_flush_o), 
            .write_fetch_o(write_fetch_o));

    assign address = {tag, index, block_offset};


    /*
    ---------------------------------------------------------------------------------
    Direct Mapped Cache Test Cases
    Attempt to cover every path in DirectMappedCache flow.
    NOTE: I don't know how to cover default cases, these shouldnt happen
    ---------------------------------------------------------------------------------
    1. Test all functionality related to invalid lines before populating Cache:
        a. Read Case 4: Read from invalid line (read_fetch_o = 1)
        b. Write Case 4: Write to invalid line (write_fetch_o = 1)
    2. Test write_line_i functionality by populating all cache rows with values (hit = 1)
    3. Write Case 1: Write to valid line with matching tag (hit = 1)
    4. Write Case 2: Write to valid, dirty line with wrong tag (write_flush_o = 1)
    5. Write Case 3: Write to valid, not dirty line with wrong tag (write_fetch_o = 1)
    6. Read Case 1: Read valid line with matching tag (hit = 1)
    7. Read Case 2: Read valid, dirty line with wrong tag (read_flush_o = 1)
    8. Read Case 3: Read valid, not dirty line with wrong tag (read_fetch_o = 1)
    9. Test read_line_i functionality (hit = 1)

    */


    initial begin

        $display("---------------------------------------------------------------------------------");
        $display("Beginning DirectMappedCache Testbench");
        $display("---------------------------------------------------------------------------------\n");

        //initialize all values to reasonable stuff
        clk = 1'b0; rst_n = 1'b1; read = 1'b0; write = 1'b0; write_line = 1'b0; tag = 'b0; index = 'b0; block_offset = 'b0; 
        data_i = 0; line_i = 0;
        
        //Cycle the clock a few times to ensure module is ready
        for(i = 0; i < 4; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
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
        $display("Begin Test Case 1. Test all functionality related to invalid lines before populating Cache");
        $display("--------------------------------------------------------------------\n");

        //We have just reset the cache, every line is invalid. Therefore we can just attempt to read address 0
        
        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 1a. Read Case 4: Read from invalid line (read_fetch_o = 1)");
        $display("--------------------------------------------------------------------\n");

        //Setup variables to read address 0
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; read = 1;
        #10
        clk = 0; read = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( read_fetch_o == 1 ) begin
            $display("Test Case 1a Success!");
        end
        else begin
            $display("Test Case 1a Failure :(");
        end
        
        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 1b. Write Case 4: Write to invalid line (write_fetch_o = 1)");
        $display("--------------------------------------------------------------------\n");

        //Setup variables to write address 0
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; write = 1; data_i = 'b0;
        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( write_fetch_o == 1 ) begin
            $display("Test Case 1b Success!");
        end
        else begin
            $display("Test Case 1b Failure :(");
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
        $display("Begin Test Case 2. Test write_line_i functionality by populating all cache rows with values (hit = 1)");
        $display("--------------------------------------------------------------------\n");

        for(j = 0; j < NUM_OF_CACHE_LINES; j = j+1) begin
            
            //Setup variables to write a line
            clk = 1; tag = j; index = j; block_offset = 'b0; write_line = 1; line_i = j;
    
    
            #10
            clk = 0; write_line = 0;
            #10
    
        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end
            
            //Write to local cache
            local_cache[index] = {1'b0, 1'b1, tag, line_i};

    
            if( hit == 1 ) begin
                $display("Test Case 2 iteration %d Success!", j);
            end
            else begin
                $display("Test Case 2 iteration %d Failure! :(", j);
            end
        end


        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 3. Write Case 1: Write to valid line with matching tag (hit = 1)");
        $display("--------------------------------------------------------------------\n");

        //Write line populated cache lines with tag = index = line
        //Write to index = 0 = tag
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; write = 1; data_i = 'h4;
        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end
            
        //Write to local cache
        local_cache[index][ CACHE_LINE_LENGTH -: ( VALID_BIT + DIRTY_BIT + TAG_LENGTH ) ]  = {1'b0, 1'b1, tag};
        local_cache[index][ block_offset * BLOCK_SIZE + BLOCK_SIZE -1 -: BLOCK_SIZE ] = data_i;

        if( hit == 1) begin
            $display("Test Case 3 Success!");
        end
        else begin
            $display("Test Case 3 Failure :(");
        end


        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 4. Write Case 2: Write to valid, dirty line with wrong tag (write_flush_o = 1)");
        $display("--------------------------------------------------------------------\n");

        //Previous line succesfully wrote to index = tag = 0
        //Write again to index = 0, with the wrong tag
        clk = 1; tag = 'b1; index = 'b0; block_offset = 'b0; write = 1; data_i = 'h8;


        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end
        
        //Do not write local cache because this is a miss

        if( write_flush_o == 1 ) begin
            $display("Test Case 4 Success!");
        end
        else begin
            $display("Test Case 4 Failure :(");
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 5. Write Case 3: Write to valid, not dirty line with wrong tag (write_fetch_o = 1)");
        $display("--------------------------------------------------------------------\n");

        //After initial population of cache, all indexes besides 0 are vaild and clean right now
        //Setup variables to write a block to a valid, clean line (wrong tag)
        clk = 1; tag = 'b0; index = 'b1; block_offset = 'b0; write = 1; data_i = 'h8;

        #10
        clk = 0; write = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end
        
        //Do not write local cache because this is a miss

        if( write_fetch_o == 1 ) begin
            $display("Test Case 5 Success!");
        end
        else begin
            $display("Test Case 5 Failure :(");
        end
        

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 6. Read Case 1: Read valid line with matching tag (hit = 1)");
        $display("--------------------------------------------------------------------\n");

        //index 0 line has tag = 0, line = 'h4;
        //Setup variables to read a block
        clk = 1; tag = 'b0; index = 'b0; block_offset = 'b0; read = 1;

        #10
        clk = 0; read = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( hit == 1 && ( data_o == local_cache[index][ block_offset * BLOCK_SIZE + BLOCK_SIZE -1 -: BLOCK_SIZE] )) begin
            $display("Test Case 6 Success!");
        end
        else begin
            $display("data_o: %d, local_cache: %d", data_o, local_cache[index][ block_offset * BLOCK_SIZE + BLOCK_SIZE -1 -: BLOCK_SIZE]);
            $display("Test Case 6 Failure :(");
        end
        
        $display("Local Cache Tag: %b, Tag: %b", local_cache[index][TAG_INDEX -: TAG_LENGTH], tag);

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 7. Read Case 2: Read valid, dirty line with wrong tag (read_flush_o = 1)");
        $display("--------------------------------------------------------------------\n");

        //index =0, tag = 0 is the only succesful write so it is valid and dirty
        //Setup variables to read a block with wrong tag
        clk = 1; tag = 'b1; index = 'b0; block_offset = 'b0; read = 1;

        #10
        clk = 0; read = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( read_flush_o == 1 ) begin
            $display("Test Case 7 Success!");
        end
        else begin
            $display("Test Case 7 Failure :(");
        end

        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 8. Read Case 3: Read valid, not dirty line with wrong tag (read_fetch_o = 1)");
        $display("--------------------------------------------------------------------\n");

        //index = 1, tag = 1 is valid and not dirty
        //Setup variables to read a block
        clk = 1; tag = 'b0; index = 'b1; block_offset = 'b0; read = 1;

        #10
        clk = 0; read = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( read_fetch_o == 1 ) begin
            $display("Test Case 8 Success!");
        end
        else begin
            $display("Test Case 8 Failure :(");
        end
        
        $display("--------------------------------------------------------------------");
        $display("Begin Test Case 9. Test read_line_i functionality (hit = 1)");
        $display("--------------------------------------------------------------------\n");

        //index = 1, tag = 1 is valid and not dirty, contains 'h1
        //Setup variables to read a line
        clk = 1; tag = 'b1; index = 'b1; block_offset = 'b0; read_line = 1;

        #10
        clk = 0; read_line = 0;
        #10

        //wait one clock cycles to receive hit or miss
        for(i = 0; i < 1; i = i + 1) begin
            clk = 1;
            #10
            clk = 0;
            #10;
        end

        if( hit == 1 && ( line_o == 'h1 )) begin
            $display("Test Case 9 Success!");
        end
        else begin
            $display("line_o: %d, local_cache: %d", line_o, local_cache[index][ (TAG_INDEX - TAG_LENGTH) -: NUM_OF_BLOCKS_PER_LINE*BLOCK_SIZE]);
            $display("Test Case 9 Failure :(");
        end
        
        $finish;

    end

endmodule