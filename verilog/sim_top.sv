module sim_top (
	input clk, rst_n,
	output done
);
    logic state;
    always_ff @( posedge clk ) begin : toggle_state
        if(!rst_n ) begin
            state <= 0;
        end else begin
            state <= !state;
        end
     end
     assign done = state;
endmodule

