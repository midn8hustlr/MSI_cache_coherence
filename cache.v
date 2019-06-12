`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:29:05 06/11/2019 
// Design Name: 
// Module Name:    cache 
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
module cache(
    input [7:0] p_addr,
    inout [7:0] p_data,
    input p_func, clk, req, reset, mem_ready,  
	 input snoop_in, invalidate_in, snoop_hit_in, snoop_ready_in,
	 
    inout [5:0] b_addr, snoop_addr,
    inout [31:0] b_data, snoop_data,
	 
    output mem_rd, mem_cs, mem_wr, ready, 
	 output snoop_out, invalidate_out, snoop_hit_out, snoop_ready_out
    );
	 
	 
	 wire [1:0] func, stat;
	 
	 
	 cache_datapath DP (
		.p_addr(p_addr), 
		.clk(clk), 
		.snoop_in(snoop_in), 
		.invalidate_in(invalidate_in),
		.snoop_out(snoop_out), 
		.func(func), 
		.b_addr(b_addr), 
		.snoop_addr(snoop_addr),
		.b_data(b_data), 
		.snoop_data(snoop_data),
		.p_data(p_data), 
		.read_hit(read_hit), 
		.write_hit(write_hit), 
		.snoop_hit_in(snoop_hit_in),
		.snoop_hit_out(snoop_hit_out),
		.stat(stat), 
		.snoop_ready(snoop_ready_out),
		.invalidate_out(invalidate_out)
	);
	
	 
	 cache_controller CTRL (
		.reset(reset), 
		.read_hit(read_hit), 
		.write_hit(write_hit), 
		.clk(clk), 
		.req(req), 
		.pfunc(p_func), 
		.mem_ready(mem_ready), 
		.snoop_ready(snoop_ready_in), 
		.snoop_hit(snoop_hit_in), 
		.stat(stat), 
		.ready(ready),
		.mem_rd(mem_rd),
		.mem_wr(mem_wr), 
		.mem_cs(mem_cs), 
		.snoop_out(snoop_out),
		.func(func)
	);
	
	
endmodule
