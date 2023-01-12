`timescale 1ns / 1ps

// Company: Alchemax
// Engineer: Tobey
// Create Date:    21:57:49 03/08/2099 
// TestLCD.v test LCD of Spartan e+ board, XCS500E model, 320-pin package 
// Additional Comments: https://www.youtube.com/watch?v=lQ6YKQt6Rz4

module TestLCD( clk, sf_e, e, rs, rw, d, c, b, a, number );

	 input [3:0] number;
	 input clk; // pin C9 is the 50-MHz on-board clock
	 output reg sf_e; // 1 LCD access (0 StrataFlash access)
	 output reg e; // enable (1)
	 output reg rs; // Register Select (1 data bits for R/W)
	 output reg rw; // Read/Write, 1/0
	 output reg d; // 4th data bits (to from a nibble)
	 output reg c; // 3rd data bits (to from a nibble)
	 output reg b; // 2nd data bits (to from a nibble)
	 output reg a; // 1st data bits (to from a nibble)
	
	reg [ 26 : 0 ] count = 0;	// 27-bit count, 0-(128M-1), over 2 secs
	reg [ 5 : 0 ] code;			// 6-bit different signals to give out
	reg refresh;					// refresh LCD rate @ about 25Hz
	
	always @ (posedge clk) begin
		count <= count +1;
		
		case ( count[ 26 : 21 ] )	// as top 6 bits change
// power-on init can be carried out before this loop to avoid the flickers
			0: code <= 6'h03;			// power-on init sequence
			1: code <= 6'h03;			// this is needed at least once
			2: code <= 6'h03;			// when LCD's powered on
			3: code <= 6'h02;			// it flickers existing char display
			
// Table 5-3, Function Set
// send 00 and upper nibble 0010, then 00 and lower nibble 10xx
			4: code <= 6'h02;			// Function Set, upper nibble 0010
			5: code <= 6'h08;			// lower nibble 1000 (10xx)
			
// Table 5-3, Entry Mode
// send 00 and upper nibble 0000, then 00 and lower nibble 0 1 I/D S
// last 2 bits of lower nibble: I/D bit (Incr 1, Decr 0), S bit (Shift 1, 0 no)
			6: code <= 6'h00; 		// see table, upper nibble 0000, then lower nibble:
			7: code <= 6'h06;			//  0110: Incr, Shift disabled
			
// Table 5-3, Display On/Off
// send 00 and upper nibble 0000, then 00 and lower nibble 1DCB:
// D: 1, show char represented by code in DDR, 0 don't, but code remains
// C: 1, show cursor, 0 don't
// B: 1, cursor blinks (if shown), 0 don't blink (if shown)
			8: code <= 6'h00;			// Display On/Off, upper nibble 0000
			9: code <= 6'h0C;			// lower nibble 1100 (1 D C B)
			
// Table 5-3 Clear Display, 00 and upper nibble 0000, 00 and lower nibble 0001
			10: code <= 6'h00;		// Clear Display, 00 and upper nibble 0000
			11: code <= 6'h01;		// then 00 and lower nibble 0001

// Characters are then given out, the cursor will advance to the right
// Table 5-3, Write Data to DD RAM (or CG RAM)
// Fig 5-4, 'H,' send 10 and upper nibble 0100, then 10 and lower nibble 1000
			12: code <= 6'h24;		// 'H' high nibble
			13: code <= 6'h28;		// 'H' low nibble
			14: code <= 6'h26;		// e
			15: code <= 6'h25;
			16: code <= 6'h26;		// l
			17: code <= 6'h2C;
			18: code <= 6'h26;		// l
			19: code <= 6'h2C;
			20: code <= 6'h26;		// o
			21: code <= 6'h2F;
			22: code <= 6'h22;		// ,
			23: code <= 6'h2C;
			
// Table 5-3, Set DD RAM (DDR) Address
// position the cursor onto the start of the 2nd line
// send 00 and upper nibble 1???, ??? is the highest 3 bits of the DDR
// address to move the cursor to, then 00 and lower 4 bits of the addr
// so ??? is 100 and then 0000 for h40
			24: code <= 6'b001100;	// pos cursor to 2nd line upper nibble h40 (...)
			25: code <= 6'b000000;	// lower nibble: h0
			
// Characters are then given out, the cursor will advance to the right
			26: code <= 6'h25;		// W
			27: code <= 6'h27;
			28: code <= 6'h26;		// o
			29: code <= 6'h2F;
			30: code <= 6'h27;		// r
			31: code <= 6'h22;
			32: code <= 6'h26;		// l
			33: code <= 6'h2C;
			34: code <= 6'h26;		// d
			35: code <= 6'h24;
			36: code <= {2'b10, 4'b0011};		// neki broj - input
			37: code <= {2'b10, number};
			
// Table 5-3, Read Busy Flag and Address
// send 01 BF (Busy Flag) x x x, then 01xxxx
// idling
			default: code <= 6'h10;	// the rest un-used time
		endcase

// refresh (enable) the LCD when
// (it flips when counted upto 2M, and flips again after another 2M)
			refresh <= count[ 20 ]; // flip rate almost 25 (50Mhz / 2^21-2M)
			sf_e <= 1;
			{ e, rs, rw, d, c, b, a } <= { refresh, code };
			
	end // always

endmodule