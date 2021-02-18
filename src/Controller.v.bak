//Verilog HDL for "HDL_Lab_vhdlp1", "Controller" "functional"
module Controller (clk, Find_Setting, rst_n, V_ADC, DC_Comp, LED_Drive, LED_IR, LED_RED, Out_IR, Out_RED, PGA_Gain, clk_filter);
	input clk, Find_Setting, rst_n, clk_filter;	//clk_filter is another clk for filter, which is faster than 500Hz
	input [7:0] V_ADC;
	output reg [6:0] DC_Comp;
	output reg [3:0] LED_Drive, PGA_Gain; 
	output reg LED_IR, LED_RED;
	output wire [19:0] Out_IR, Out_RED;

	//boundary for finding DC_Comp
	parameter ADC_HALF_MAX = 8'b10000111, ADC_HALF_MIN = 8'b01110000;
	
	//boundary for finding PGA_Gain
   	parameter ADC_MAX_1 = 8'b11001100, ADC_MAX_2 = 8'b11111110, ADC_MIN_1 = 8'b00011001, ADC_MIN_2 = 8'b00000001;
        parameter COUNT_100HZ = 10, COUNT_1HZ = 1000;	//how many times we need to count for a certain clk frequency

	//used for state: S0: search for a suitable DC_Comp for LEDs; S1: search for DC_Comp exactly; sS2: search for a suitable PGA_Gain for LEDs;	S3: change LEDs for a certain frequency after we have found right settings for both of LEDs
	parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011;
	//used for find_state: IR_DC_FINDING: find DC_Comp for LED IR;  IR_GAIN_FINDING: find PGA_Gain for LED IR; 
						// RED_DC_FINDING: find DC_Comp for LED RED; RED_GAIN_FINDING: find PGA_Gain for LED RED
	parameter IR_DC_FINDING = 3'b000, IR_GAIN_FINDING = 3'b001, RED_DC_FINDING = 3'b010, RED_GAIN_FINDING = 3'b011; 
	reg [2:0] state, find_state;
	reg [9:0] count;	//We need a long period of counting when we search for PGA_Gain of LED
	
	reg [3:0] PGA_red_max, PGA_infrared_max;	//PGA_Gain of red and infrared LED which we have already found
	reg [6:0] DC_Comp_red, DC_Comp_infrared;	//DC_Comp of red and infrared LED which we have already found
	reg [7:0] ADC_max, ADC_min;	//find the max and min value of V_ADC, it helps us to find the right setting of PGA_Gain
	wire [7:0] ADC_RED, ADC_IR;	//output of ADC signal of RED_LED and IR_LED
	wire [2:0] dc_pos, pga_pos;	//position of bit "1" in the setting of DC_Comp and PGA_Gain (using a funtion from other file)

	//maxmin_init == 1: begin to find the max and min value of V_ADC; maxmin_init == 0: stop finding;
	//clock_sampling: the frequency of FIR_Filter, which is 500Hz
	reg maxmin_init, clock_sampling;	 
	reg find_setting_previous;	//save the find_setting signal of the last clk period 

	
	always @(V_ADC or maxmin_init) begin
	    if (!maxmin_init) begin	//initial values to a middel value, 0.9V
	    	ADC_max = 8'b10000000;
		ADC_min = 8'b10000000;	 
	    end
	    else begin		//save max and min value of one cycle
		if(V_ADC > ADC_max)
			ADC_max = V_ADC;
		if(V_ADC < ADC_min)
			ADC_min = V_ADC;
	    end
	end 

	always @(posedge clk or negedge rst_n) begin
		//reset: clean all the setting and keep swtiching the LED without DC_Comp and PGA_Gain
		if(!rst_n) begin
			DC_Comp <= 0;
			PGA_Gain <= 0;
			state <= S2;
			PGA_red_max <= 0;
			DC_Comp_red <= 0;
			PGA_infrared_max <= 0;
			DC_Comp_infrared <= 0;
 			LED_Drive <= 10;
			count <= 0;
			LED_IR <= 0;
			LED_RED <= 1;
			maxmin_init <= 0;
		end
		//when there is a Find_Setting signal, begin to search settings for both LEDs
		else if(find_setting_previous == 0 && Find_Setting == 1) begin
			state <= S0;
			find_state <= RED_DC_FINDING;
			DC_Comp <= 7'b1000000;
			PGA_Gain <= 0;
			LED_IR <= 0;
			LED_RED <= 1;
			maxmin_init <= 0;	//don't find max and min value, this is only for PGA_Gain
			count <= 0;
			find_setting_previous <= Find_Setting;	//save the state of Find_Setting signal for every clk cycle
		end
		else begin
			find_setting_previous <= Find_Setting;	//save the state of Find_Setting signal for every clk cycle
			case (state)	//begin the statemachine	 
				S0: begin
					if(V_ADC > ADC_HALF_MAX)	//V_ADC is too large, increase the DC_Comp to reduce V_ADC
							case(dc_pos)
		  					1: DC_Comp <= DC_Comp | 7'b0000001;
							2: DC_Comp <= DC_Comp | 7'b0000010;
		  					3: DC_Comp <= DC_Comp | 7'b0000100;
		 					4: DC_Comp <= DC_Comp | 7'b0001000;
		  					5: DC_Comp <= DC_Comp | 7'b0010000;
		  					6: DC_Comp <= DC_Comp | 7'b0100000;		
		 				endcase		
	    			 else if(V_ADC < ADC_HALF_MIN)	//V_ADC is too small, decrease the DC_Comp to increase V_ADC
		  				case(dc_pos)
		  					0: DC_Comp <= DC_Comp & 7'b1111110;
		  					1: DC_Comp <= (DC_Comp & 7'b1111101)|7'b0000001;
	      					2: DC_Comp <= (DC_Comp & 7'b1111011)|7'b0000010;
		  					3: DC_Comp <= (DC_Comp & 7'b1110111)|7'b0000100;
		  					4: DC_Comp <= (DC_Comp & 7'b1101111)|7'b0001000;
		  					5: DC_Comp <= (DC_Comp & 7'b1011111)|7'b0010000;
		 					6: DC_Comp <= (DC_Comp & 7'b0111111)|7'b0100000;	
		 				endcase
		 			 else begin
	  	  				if(find_state == RED_DC_FINDING) begin	//save setting for RED LED
		   					DC_Comp_red <= DC_Comp;
		   					find_state <= RED_GAIN_FINDING;
		  				end 
		  				else if(find_state == IR_DC_FINDING) begin	///save setting for IR LED
		   					DC_Comp_infrared <= DC_Comp;
		   					find_state <= IR_GAIN_FINDING;
		  				end
		  				state <= S1;
          					maxmin_init <= 0;
					 end
	     		 	end 
				S1: begin
						maxmin_init <= 1;	//start to find max and min value
						if(count < 500)	//collect data for one minute
		  					count <= count + 1;
						else begin
							count <= 0;	
							
              						if((ADC_max + ADC_min)/2 > ADC_HALF_MAX)
								DC_Comp <= DC_Comp + 1;
              			    			else if((ADC_max + ADC_min)/2 < ADC_HALF_MIN)
								DC_Comp <= DC_Comp - 1;
						    	else begin
		 						state <= S2;
								PGA_Gain <= 4'b0100;
								maxmin_init <= 0;
							end

	      					if(find_state == RED_GAIN_FINDING)
                					DC_Comp_red <= DC_Comp;
 	      					else if(find_state == IR_GAIN_FINDING)
                					DC_Comp_infrared <= DC_Comp;

							maxmin_init <= 0;
						end
				end
	 			S2: begin
					maxmin_init <= 1;	//start to find max and min value
					if(count < COUNT_1HZ)	//collect data for one minute
		  				count <= count + 1;
					else begin
						count <= 0;	
						if((ADC_max < ADC_MAX_1) && (ADC_min > ADC_MIN_1))	//V_ADC is too small, increase PGA_Gain to increase V_ADC
		  					case(pga_pos)
							//	0: PGA_Gain <= PGA_Gain + 1;
		   						1: PGA_Gain <= PGA_Gain | 4'b0001;
		   						2: PGA_Gain <= PGA_Gain | 4'b0010;
		   						3: PGA_Gain <= PGA_Gain | 4'b0100;
		  					endcase
						else if((ADC_max > ADC_MAX_2) || (ADC_min < ADC_MIN_2))	//V_ADC is too large, decrease PGA_Gain to decrease V_ADC
		  					case(pga_pos)
		   						0: PGA_Gain <= PGA_Gain & 4'b1110;
		   						1: PGA_Gain <= (PGA_Gain & 4'b1101) | 4'b0001;
		   						2: PGA_Gain <= (PGA_Gain & 4'b1011) | 4'b0010;
		   						3: PGA_Gain <= (PGA_Gain & 4'b0111) | 4'b0100;
		  					endcase
						else begin 
		  					if(find_state == RED_GAIN_FINDING) begin	//save setting for RED LED
           						PGA_red_max <= PGA_Gain;
		   						DC_Comp <= 7'b1000000;
		   						PGA_Gain <= 4'b0000;
		   						LED_RED <= 0;
		   						LED_IR <= 1;
		   						find_state <= IR_DC_FINDING;
		   						state <= S0;
		  					end
		  					else if(find_state == IR_GAIN_FINDING) begin	//save setting for IR LED
		   						PGA_infrared_max <= PGA_Gain;
		   						DC_Comp_infrared <= DC_Comp;
		   						state <= S3;
		  					end
						end
		  				maxmin_init <= 0;
					end
				end
				S3: begin
	    				if(count < COUNT_100HZ)	//frequency of switching LEDs
		  				count <= count + 1;
					else begin 
		 				count <= 0;
		 				LED_IR <= !LED_IR;	
 		 				LED_RED <= !LED_RED;
		 				if(LED_IR == 1) begin	//use the corresponding setting for LED_IR
		   					PGA_Gain <= PGA_red_max;
		   					DC_Comp <= DC_Comp_red;
		 				end
		 				else if(LED_RED == 1) begin	//use the corresponding setting for LED_RED
		   					PGA_Gain <= PGA_infrared_max;
		   					DC_Comp <= DC_Comp_infrared;
		 				end
					end 
	     			end
	 		endcase
	 	end
	end
	
	always @(posedge clk)
		if(!rst_n)
	  		clock_sampling <= 0;
	 	else
	  		clock_sampling <= !clock_sampling;	//The frequency of filter of the half of the frequency of Controller

	Demux_1to2 demux_bitstream(.in(V_ADC), .s(LED_RED), .out0(ADC_IR), .out1(ADC_RED), .rst(rst_n));
	Position_check pos_check(.dc_pos(dc_pos), .DC_Comp(DC_Comp), .PGA_Gain(PGA_Gain), .pga_pos(pga_pos));
	FIR_filter red_fir_filter(.clk(clk_filter), .rst(rst_n), .filter_in(ADC_RED), .filter_out(Out_RED), .clk_sampling(clock_sampling));
	FIR_filter ir_fir_filter(.clk(clk_filter), .rst(rst_n), .filter_in(ADC_IR), .filter_out(Out_IR), .clk_sampling(clock_sampling));
endmodule


  

  

