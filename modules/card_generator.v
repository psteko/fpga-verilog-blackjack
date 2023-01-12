`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:10:24 06/27/2022 
// Design Name: 
// Module Name:    card_generator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module card_generator(input hit, input clk, output reg [3:0] card, output reg [3:0] prev_card);

reg [3:0] counter;

initial begin
counter=2;
end 

always@(posedge clk) begin
counter<=counter+1'b1;
if(counter==11)
counter<=2;
end

always@(posedge hit) begin
card<=counter;
prev_card<= card;
end


endmodule


