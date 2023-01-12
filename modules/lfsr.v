`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:21:51 06/10/2022 
// Design Name: 
// Module Name:    lfsr 
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
module lfsr (out, clk, rst);

  output reg [3:0] out;
  reg [3:0] number;
  input clk, rst;

  wire feedback;

  assign feedback = ~(number[3] ^ number[2]);


always @(posedge clk, posedge rst)
  begin
    if (rst)
      number = 4'b0;
    else
      number = {number[2:0],feedback};
  end
  
  always @(*) begin
  case(number)
  0: out=5;
  1: out=11;
  14: out=8;
  13: out=3;
  12: out=10;
  default: out=number;
  endcase
  end
endmodule
