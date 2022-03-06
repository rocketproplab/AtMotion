module DirectMappedCache_tb ();

    //Calculate localparams
    localparam BLOCK_SIZE = 4;
    localparam NUM_OF_BLOCKS_PER_LINE = 2;
    localparam NUM_OF_CACHE_LINES = 4;
    parameter ADDRESS_SIZE = 16;

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
    reg [BLOCK_SIZE - 1: 0] data_i, data_o;
    reg [CACHE_LINE_LENGTH - 1: 0] line_i;

    wire hit, miss;

    wire [TAG_LENGTH - 1: 0] tag;
    wire [INDEX_LENGTH - 1: 0] index;
    wire [BLOCK_OFFSET_LENGTH - 1: 0] block_offset;
    wire temp_blocks[NUM_OF_BLOCKS_PER_LINE - 1: 0][BLOCK_SIZE - 1: 0];

    //Test Input
    reg local_cache[NUM_OF_CACHE_LINES - 1: 0][CACHE_LINE_LENGTH - 1: 0];


    //Initialize DUT
    DirectMappedCache #(    .BLOCK_SIZE(BLOCK_SIZE)
                            .NUM_OF_BLOCKS_PER_LINE(NUM_OF_BLOCKS_PER_LINE)
                            .NUM_OF_CACHE_LINES(NUM_OF_CACHE_LINES)
                            .ADDRESS_SIZE(ADDRESS_SIZE)
                            )
    (.clk(clk), .rst_n(rst_n).read(read), .write(write), .write_line(write_line), .address(address), 
    .data_i(data_i), .line_i(line_i), .data_o(data_o), .hit(hit), .miss(miss));

    initial begin
        clk = 1'b0;
        rst_n = 1'b1;
        read = 1'b0;
        write = 1'b0;
        write_line = 1'b0;
        address = 0;
        data_i = 0;
        line_i = 0;
    end

    //Reset
    #10 clk = 1;
    #10 clk = 0; rst_n = 0;

    #10 clk = 1;
    #10 clk = 0;
    #10 clk = 1;
    #10 clk = 0;

    for()





endmodule