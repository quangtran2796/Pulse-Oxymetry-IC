//Verilog HDL for "HDL_Lab_vhdlp1", "Position_check" "functional"

module Position_check(DC_Comp, PGA_Gain, dc_pos, pga_pos);

	input [6:0] DC_Comp; 
 	input [3:0] PGA_Gain; 
	output reg [2:0] dc_pos;
	output reg [2:0] pga_pos;

	always @(DC_Comp)
  		if(DC_Comp & 7'b0000001)
   			dc_pos = 0;
  		else if(DC_Comp & 7'b0000010)
  	 		dc_pos = 1;
  		else if(DC_Comp & 7'b0000100)
   			dc_pos = 2;
  		else if(DC_Comp & 7'b0001000)
   			dc_pos = 3;
  		else if(DC_Comp & 7'b0010000)
   			dc_pos = 4;
  		else if(DC_Comp & 7'b0100000)
   			dc_pos = 5;
  		else if(DC_Comp & 7'b1000000)
   			dc_pos = 6;
  

 	always @(PGA_Gain)
  		if(PGA_Gain & 4'b0001)
   			pga_pos = 0;
  		else if(PGA_Gain & 4'b0010)
   			pga_pos = 1;
  		else if(PGA_Gain & 4'b0100)
   			pga_pos = 2;
  		else if(PGA_Gain & 4'b1000)
   			pga_pos = 3;

endmodule 


