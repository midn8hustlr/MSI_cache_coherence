`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:29:17 06/11/2019 
// Design Name: 
// Module Name:    memory 
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
module memory(
    input [5:0] addr,
    inout [31:0] data,
    input clk, rd, wr, cs,
	 output reg ready
    );
	 
	 reg [31:0] mem [0:63];
	 reg [31:0] d_out;
	 
	 assign data = (cs && rd) ? d_out : 32'bz;
	
	 
	 always @(posedge clk)
	 begin
	 
	 ready = 0;
	 
	   if (cs && wr && !rd)
		begin
		  mem[addr] = data;
		  ready = 1;
		end
		
		if (cs && rd && !wr) 
		begin
		  d_out = mem[addr];
		  ready = 1;
		end
		  
	 end
	 
endmodule

