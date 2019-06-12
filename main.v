`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: avisekh007
// 
// Create Date:    09:29:28 06/11/2019 
// Design Name: 
// Module Name:    main 
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
module main(
    input [7:0] p_addr0, p_addr1,
    inout [7:0] p_data0, p_data1,
	 input clk,
	 
    input p_func0, reset0, req0, p_func1, reset1, req1,
	 
	 output ready0, ready1
    );
	 
	 wire [31:0] data_bus, snoop_data_bus;
	 wire [5:0]  addr_bus, snoop_addr_bus;
	 
	 
	 cache CORE0 (
		.p_addr(p_addr0), 
		.p_data(p_data0), 
		.p_func(p_func0), 
		.clk(clk), 
		.req(req0), 
		.reset(reset0), 
		.mem_ready(mem_ready), 
		.snoop_in(snoop10), 
		.invalidate_in(invalidate10), 
		.snoop_hit_in(snoop_hit10),
      .snoop_hit_out(snoop_hit01),		
		.snoop_ready_in(snoop_ready10), 
		.b_addr(addr_bus), 
		.snoop_addr(snoop_addr_bus), 
		.b_data(data_bus), 
		.snoop_data(snoop_data_bus), 
		.mem_rd(mem_rd0), 
		.mem_cs(mem_cs0), 
		.mem_wr(mem_wr0), 
		.ready(ready0), 
		.snoop_out(snoop01), 
		.invalidate_out(invalidate01),  
		.snoop_ready_out(snoop_ready01)
	);
	
	
	 cache CORE1 (
		.p_addr(p_addr1), 
		.p_data(p_data1), 
		.p_func(p_func1), 
		.clk(clk), 
		.req(req1), 
		.reset(reset1), 
		.mem_ready(mem_ready), 
		.snoop_in(snoop01), 
		.invalidate_in(invalidate01), 
		.snoop_hit_in(snoop_hit01),
      .snoop_hit_out(snoop_hit10),		
		.snoop_ready_in(snoop_ready01), 
		.b_addr(addr_bus), 
		.snoop_addr(snoop_addr_bus), 
		.b_data(data_bus), 
		.snoop_data(snoop_data_bus), 
		.mem_rd(mem_rd1), 
		.mem_cs(mem_cs1), 
		.mem_wr(mem_wr1), 
		.ready(ready1), 
		.snoop_out(snoop10), 
		.invalidate_out(invalidate10), 
		.snoop_ready_out(snoop_ready10)
	);
	
	memory MEM (
		.addr(addr_bus), 
		.data(data_bus), 
		.clk(clk), 
		.rd(mem_rd0 || mem_rd1), //
		.wr(mem_wr0 || mem_wr1), //
		.cs(mem_cs0 || mem_cs1),//
		.ready(mem_ready)//
	);


endmodule