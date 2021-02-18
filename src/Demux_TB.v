`timescale 100ms/100ps
module Demux_TB();
	wire [7:0] out0, out1;
	reg [7:0] in;
	reg s, rst;

	Demux_1to2 dut(.out0(out0), .out1(out1), .in(in), .s(s), .rst(rst));

	initial begin 
		#1 rst = 1;
		#1 rst = 0;
		#1 rst = 1; 
		#2 s=0; 
		#10 in = 8'b11110001;
 		#10 in = 8'b11110000; 
		#2 s=1;
		#10 in = 8'b01010101;
		
	end
endmodule 
