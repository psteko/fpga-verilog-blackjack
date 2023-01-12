`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:06:12 05/25/2022 
// Design Name: 
// Module Name:    edge_detector 
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
module edge_detector(
input clk, input in,
output reg out
    );
	
	reg [1:0] state;
		
	always @ (posedge clk) begin
	case (state)
		0: begin
		out=0;
		if(in) 
			state<=0;
		else 
			state<=1;
		end
		
		1: begin
		out=0;
		if(in) 
			state<=2;
		else 
			state<=1;
		end
		
		2: begin
		out=1;
		if(in) 
			state<=0;
		else 
			state<=1;
		end
		
		default: begin 
		state<=0;
		out=0;
		end
		
	endcase
	end


endmodule
