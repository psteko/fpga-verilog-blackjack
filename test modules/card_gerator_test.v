`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:51:01 06/27/2022
// Design Name:   card_generator
// Module Name:   E:/primjeri/bj/card_gerator_test.v
// Project Name:  bj
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: card_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module card_gerator_test;

	// Inputs
wire [3:0] card, prev_card;
reg hit, clk;

card_generator uut(.hit(hit), .clk(clk), .card(card), .prev_card(prev_card));

initial begin
clk=0;
hit=0;

#10 hit=1;
#10 hit=0;

#14 hit=1;
#10 hit=0;

#6 hit=1;
#10 hit=0;

#7 hit=1;
#10 hit=0;

#100 $stop;

end


always begin
#4 clk=~clk;
end

      
endmodule

