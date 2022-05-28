`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2022 12:06:32 PM
// Design Name: 
// Module Name: memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory #(
                    parameter       BLOCK_SIZE = 32,
                    parameter       ADDRESS_SIZE = 32
)
(
input clk_i,
input read_i, 
input write_i,
input [BLOCK_SIZE - 1: 0] data_i,
input [$clog2(ADDRESS_SIZE) - 1: 0] address_i,
output reg [BLOCK_SIZE - 1: 0] data_o 
    );
    
localparam DEPTH = 16;
    
reg [BLOCK_SIZE - 1: 0] memory [DEPTH - 1: 0];
    
    always@(posedge clk_i ) begin
        if(read_i) begin
            data_o <= memory[ address_i ];
        end
        else if(write_i) begin
            memory[ address_i ] <= data_i;
        end
    end
endmodule
