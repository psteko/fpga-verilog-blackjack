`timescale 1ns / 1ps


module edge_detector_test;

	// Inputs
	reg clk;
	reg in;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	edge_detector uut (
		.clk(clk), 
		.in(in), 
		.out(out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		in = 0;
		
		#4 in=0;
		#10 in=1;
		#8 in=0;
		#10 in=1;
		#8 in=1;
		#20 in=0;
		#8 in=1;
		#8 in=0;
		

		// Wait 100 ns for global reset to finish
		#100 $stop;
        
		// Add stimulus here

	end
		
	always 
	#4 clk=~clk;
      
endmodule
