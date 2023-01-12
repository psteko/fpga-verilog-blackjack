`timescale 1ns / 1ps

// triba maknit input card, odkomentirat card gen i var + LCD instanca pa odkomentirat bin2bcd

module blackjack(

	input reset,
	input clk,
	input hit,
	input stay,
	input double_down,
	input split,
	//input [3:0] card,
	
	output reg win,
	output reg tie,
	output reg lose,
	output sf_e, e, rs, rw, d, c, b, a
    );


wire[3:0] card;  
wire [3:0] prev_card;	
wire hit_sp, stay_sp, double_down_sp, split_sp;	
wire [3:0] d_card;
	

// generetes a new card
card_generator new_card(.hit(hit_sp), .clk(clk), .card(card), .prev_card(prev_card));
lfsr d_new_card(.clk(clk), .rst(reset), .out(d_card));

// generates a single pulse if hit, stay, double_down or split button is pressed
edge_detector hit_button(.clk(clk), .in(hit), .out(hit_sp));
edge_detector stay_button(.clk(clk), .in(stay), .out(stay_sp));
edge_detector double_down_button(.clk(clk), .in(double_down), .out(double_down_sp));
edge_detector split_button(.clk(clk), .in(split), .out(split_sp));


// FSM state register
reg [3:0] state;    

// Score and card number FF
reg [4:0] player_score;
reg [4:0] dealer_score;
reg [4:0] number_of_cards_player;
reg [4:0] number_of_cards_dealer;
reg [4:0] split_fh_p_score;
reg [4:0] split_sh_p_score;
reg [4:0] split_fh_d_score;
reg [4:0] split_sh_d_score;

reg [7:0] bet; // Players bet

reg dd_flag;		// Limits player to draw only one card in double down state
reg split_flag;     // To make sure player hits at least once before staying
reg result_flag;
reg splitted;
reg hit_d;

// States	 
localparam state_initial = 0;
localparam state_player = 1;
localparam state_dealer = 2;
localparam state_game_result = 3;
localparam state_player_dd = 4;
localparam state_player_split_fh = 5;
localparam state_player_split_sh = 6;
localparam state_dealer_split_fh = 7;
localparam state_dealer_split_sh = 8;

// For BCD decoder
wire [15:0] p_score_bcd, d_score_bcd, p_fh_bcd, p_sh_bcd, d_fh_bcd, d_sh_bcd;
wire [15:0] bet_bcd;
bin2bcd_5b bcd_p_score(.bin(player_score), .bcd(p_score_bcd));
bin2bcd_5b bcd_d_score(.bin(dealer_score), .bcd(d_score_bcd));
bin2bcd_5b bcd_p_score_fh(.bin(split_fh_p_score), .bcd(p_fh_bcd));
bin2bcd_5b bcd_p_score_sh(.bin(split_sh_p_score), .bcd(p_sh_bcd));
bin2bcd_5b bcd_d_score_fh(.bin(split_fh_d_score), .bcd(d_fh_bcd));
bin2bcd_5b bcd_d_score_sh(.bin(split_sh_d_score), .bcd(d_sh_bcd));
bin2bcd_8b bcd_bet(.bin(bet), .bcd(bet_bcd));

// LCD 
lcd lcdTest(.clk(clk), .p_score_bcd(p_score_bcd), .d_score_bcd(d_score_bcd), .p_fh_bcd(p_fh_bcd), .p_sh_bcd(p_sh_bcd), .d_fh_bcd(d_fh_bcd), .d_sh_bcd(d_sh_bcd),
 .bet_bcd(bet_bcd), .sf_e(sf_e), .e(e), .rs(rs), .rw(rw), .d(d), .c(c), .b(b), .a(a));

always @(posedge clk or posedge reset)
begin
	// Reset to start
	if(reset) begin 
	win = 0;
	tie = 0;
	lose = 0;
	number_of_cards_player = 0;
	number_of_cards_dealer = 0;
	player_score = 0;
	dealer_score = 0;
	dd_flag = 1;
	split_flag = 1;
	result_flag = 1;
	splitted = 1;
	hit_d=1;
	split_fh_p_score = 0;
	split_sh_p_score = 0;
	split_fh_d_score = 0;
	split_sh_d_score = 0;
	bet = 100;
	state <= state_initial;
	end
		// Game logic
	else begin
	
	
	case(state)
	
		state_initial:
			begin
				state <= state_player;
			end
			
		state_player:  // Player turn to draw cards
		if(bet >= 10) 
		begin
				begin
								
				if(hit_sp == 1) begin
					if(card == 11 && player_score > 10)  								// If the player gets another ace, it counts as 1 (in his favour)
						begin
						player_score = player_score + 1'b1;
						number_of_cards_player = number_of_cards_player + 1'b1;
						end
				else 
					begin                                                      			// Add new card to score
					player_score = player_score + card;
					number_of_cards_player = number_of_cards_player + 1'b1;
					end
				end


				if((stay_sp == 1 && number_of_cards_player >=2 ) || player_score >= 21)	// If the player decides to stay with min. 2 cards or the score is over 21
					begin																// it's the dealers turn
						state <= state_dealer;
					end
				// DOUBLE DOWN
								if(double_down_sp == 1 && number_of_cards_player==2 && (player_score==9 || player_score==10 || player_score==11 ) && bet >= 20) 
					begin
						state <= state_player_dd;										// If players score equals 9, 10 or 11 after drawing 2 cards, he's allowed
					end																	// to double down and recieve only one card in advance
				// SPLIT	
								if(split_sp == 1 && number_of_cards_player == 2 && card==prev_card)		// If the first two cards are the same value, player's alowed to split
					begin																// and treat the splitted cards as seperate hands
						split_fh_p_score = card;
						split_sh_p_score = card;
						splitted = 0;
						state <= state_player_split_fh;
					end
					
					
				end
			end
				
		state_player_dd:   // DOUBLE DOWN
			begin
				if(hit_sp == 1 && dd_flag == 1) begin										
					if(card == 11 && player_score > 10)  								// If the player gets another ace, it counts as 1 (in his favour)
						begin
						player_score = player_score + 1'b1;
						number_of_cards_player = number_of_cards_player + 1'b1;
						dd_flag = 0;													// Set dd_flag to 0 to disallow player to draw more than one card
						end
				else 
					begin                                                      			// Add new card to score
					player_score = player_score + card;
					number_of_cards_player = number_of_cards_player + 1'b1;
					dd_flag = 0;														// Set dd_flag to 0 to disallow player to draw more than one card
					end
				end

				if(stay_sp == 1 && dd_flag == 0 )											// Player must stay after drawing one card
					begin																
						state <= state_dealer;
					end
			end
					
		state_player_split_fh:   // Split - players first hand
			begin
			if(hit_sp == 1) begin
					if(card == 11 && split_fh_p_score > 10)  								
						begin
						split_fh_p_score = split_fh_p_score + 1'b1;
						//number_of_cards_player = number_of_cards_player + 1'b1;
						split_flag = 0;
						end
				else 
					begin                                                      			
					split_fh_p_score = split_fh_p_score + card;
					//number_of_cards_player = number_of_cards_player + 1'b1;
					split_flag = 0;
					end
				end

				if((stay_sp == 1 && split_flag==0) || split_fh_p_score >= 21)										
					begin																
						state <= state_dealer_split_fh;
						split_flag=1;
					end
			end
			
		state_dealer_split_fh:   // Split - dealers first hand
		begin
			
				if(hit_d == 1) begin
				split_fh_d_score = split_fh_d_score + d_card;
				number_of_cards_dealer = number_of_cards_dealer + 1'b1;
					if(number_of_cards_dealer >=2 && split_fh_d_score >= 17) 												// If dealers score is under 17, dealer must draw another card until his score
						hit_d=0;		
				end

				else     // If dealer stays with min. 2 cards and his score >=17 move to game result state
					begin
						hit_d=1;
						state <= state_player_split_sh;
					end
			end
					
		state_player_split_sh:   // Split - players second hand
			begin
			if(hit_sp == 1) begin
					if(card == 11 && split_sh_p_score > 10)  								
						begin
						split_sh_p_score = split_sh_p_score + 1'b1;
						//number_of_cards_player = number_of_cards_player + 1'b1;
						split_flag = 0;
						end
				else 
					begin                                                      			
					split_sh_p_score = split_sh_p_score + card;
					//number_of_cards_player = number_of_cards_player + 1'b1;
					split_flag = 0;
					end
				end

				if((stay_sp == 1 && split_flag==0) || split_sh_p_score >= 21)										
					begin																
						state <= state_dealer_split_sh;
						split_flag = 1;
					end
			end
			
			state_dealer_split_sh:   // Split - dealers second hand
			begin
			
				if(hit_d == 1) begin
				split_sh_d_score = split_sh_d_score + d_card;
				number_of_cards_dealer = number_of_cards_dealer + 1'b1;
					if(number_of_cards_dealer >=2 && split_sh_d_score >= 17) 												// If dealers score is under 17, dealer must draw another card until his score
						hit_d=0;		
				end

				else     // If dealer stays with min. 2 cards and his score >=17 move to game result state
					begin
						hit_d=1;
						state <= state_game_result;
					end
			end
			
		state_dealer:   // Dealer turn to draw cards
			begin
			
				if(hit_d == 1) begin
				dealer_score = dealer_score + d_card;
				number_of_cards_dealer = number_of_cards_dealer + 1'b1;
					if(number_of_cards_dealer >=2 && dealer_score >= 17) 												// If dealers score is under 17, dealer must draw another card until his score
						hit_d=0;		
				end

				else     // If dealer stays with min. 2 cards and his score >=17 move to game result state
					begin
						hit_d=1;
						state <= state_game_result;
					end
			end
			
		state_game_result:    // Determines the result of the game (for the player)
		
		begin
		
		if(result_flag) begin
		
		result_flag = 0;
		if(splitted) begin
				if((player_score > 21) && (dealer_score > 21))	 						// If both are over 21, it's a tie
					tie = 1;
				else if(player_score > 21)	begin											// If the player is over 21, he loses
					lose = 1;
					bet = bet - 10;
					end
				else if(dealer_score > 21)	begin											// If the dealer is over 21, player wins
					win = 1;
						if(dd_flag == 0) begin
						bet = bet + 20;
						end
						else begin
							if(player_score==21)
							bet = bet + 15;
							else bet = bet + 10;
						end
					end
				else if (dealer_score > player_score) begin									// If the dealers score is over the players score, player loses
					lose = 1;
						if(dd_flag == 0)
						bet = bet - 20;
						else
						bet = bet - 10;
					end
				else if (dealer_score < player_score) begin									// If player score is over the dealers score, he wins
					win = 1;
					if(dd_flag == 0) begin
						bet = bet + 20;
					end
					else begin
						if(player_score==21)
						bet = bet + 15;
						else bet = bet + 10;
						end
					end
				else if (dealer_score == player_score)									// If scores are equal, it's a tie
					tie = 1;
					
			end
			
			else begin
				// SPLIT - First hand; BET 1:1
				if((split_fh_p_score > 21) && (split_fh_d_score > 21))	 						
					tie = 1;
				else if(split_fh_p_score > 21) begin													
					lose = 1;
					bet = bet - 10;
					end
				else if(split_fh_d_score > 21) begin												
					win = 1;
					bet = bet + 10;
					end
				else if (split_fh_d_score > split_fh_p_score) begin							
					lose = 1;
					bet = bet - 10;
					end
				else if (split_fh_d_score < split_fh_p_score) begin									
					win = 1;
					bet = bet + 10;
					end
				else if (split_fh_d_score == split_fh_p_score && split_fh_p_score != 0 && split_fh_d_score != 0)									
					tie = 1;
					
				// SPLIT - Second hand; BET 1:1
				if((split_sh_p_score > 21) && (split_sh_d_score > 21))  						
					tie = 1;
				else if(split_sh_p_score > 21)	begin													
					lose = 1;
					bet = bet - 10;
					end
				else if(split_sh_d_score > 21) begin														
					win = 1;
					bet = bet + 10;
					end
				else if (split_sh_d_score > split_sh_p_score) begin								
					lose = 1;
					bet = bet - 10;
					end
				else if (split_sh_d_score < split_sh_p_score) begin									
					win = 1;
					bet = bet + 10;
					end
				else if (split_sh_d_score == split_sh_p_score && split_sh_p_score != 0 && split_sh_d_score != 0)									
					tie = 1;
					
			end
			end
					
				// if current bet isn't enough, reset for new game
				// if bet is enough, split to continue
				if (split_sp == 1) begin
					state <= state_initial;
					win = 0;
					tie = 0;
					lose = 0;
					number_of_cards_player = 0;
					number_of_cards_dealer = 0;
					player_score = 0;
					dealer_score = 0;
					dd_flag = 1;
					split_flag = 1;
					result_flag = 1;
					splitted = 1;
					split_fh_p_score = 0;
					split_sh_p_score = 0;
					split_fh_d_score = 0;
					split_sh_d_score = 0;
					end
					
					
			end
	endcase
	end
end


endmodule					