`timescale 1us/1ps
module Controller_TB();
 reg clk;
 reg Find_Setting, rst_n, clk_filter;
 wire [6:0] DC_Comp;
 wire [3:0] LED_Drive, PGA_Gain; 
 wire LED_IR, LED_RED;
 wire [19:0] Out_IR, Out_RED;
 wire [7:0] Vppg;
Controller DUT(.clk(clk), 
		.Find_Setting(Find_Setting), 
		.rst_n(rst_n), 
		.V_ADC(Vppg), 
		.DC_Comp(DC_Comp), 
		.LED_Drive(LED_Drive), 
		.PGA_Gain(PGA_Gain), 
		.LED_IR(LED_IR), 
		.LED_RED(LED_RED),
		.Out_IR(Out_IR), 
		.Out_RED(Out_RED),
		.clk_filter(clk_filter));

Fingerclip_Model Fingerclip(.Vppg(Vppg), .DC_Comp(DC_Comp), .PGA_Gain(PGA_Gain));

always #20 clk_filter = !clk_filter; //clock_filter 20000Hz, faster 25 times as clk

always #500 clk = !clk; //Clock 1000Hz

initial 
  begin 
   clk = 1'b0;
   clk_filter = 1'b0;
   Find_Setting = 0;
   rst_n = 1;
   
   #2000 rst_n = 0;
   #2000 rst_n = 1; 
   #2000 Find_Setting = 1;
   #1000000000 $stop;
  end
endmodule

