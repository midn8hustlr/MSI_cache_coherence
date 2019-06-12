`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: avisekh007
// 
// Create Date:    09:28:34 06/11/2019 
// Design Name: 
// Module Name:    cache_datapath 
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
module cache_datapath(
    input [7:0]   p_addr,
    input         clk,
	 input         snoop_in, invalidate_in, snoop_out, snoop_hit_in, 
	 input [1:0]   func,
	 
	 inout [5:0]   b_addr, snoop_addr,
	 inout [31:0]  b_data, snoop_data,
	 inout [7:0]   p_data,
	 
	 output        read_hit, write_hit, snoop_hit_out,
    output [1:0]  stat,
    output reg    snoop_ready, invalidate_out
    );
	 
	                                  //      DATA       |       ADDR      
	 parameter p_read  = 2'b00,       // cache -> prcsr  |  prcsr -> cache   (Processor Read)
	           p_write = 2'b01,       // prcsr -> cache  |  prcsr -> cache   (Processor Write)
				  b_read  = 2'b10,       // bus   -> cache  |  cache -> bus     (Bus Read)
				  b_write = 2'b11;       // cache -> bus    |  cache -> bus     (Write Back)
				  
	 parameter excl = 2'b11,          // exclusive State
	           shrd = 2'b10,          // shared State
				  invl = 2'b00;          // invalid State
	 
	 reg [31:0]   cache_mem [0:3];    // cache memory
	 reg [3:0]    tag_mem [0:3];      // tag memory
	 reg [1:0]    stat_mem [0:3];     // status memory = {valid, dirty}
	 
	 integer i;
	 
	 initial 
	   for (i=0; i<4; i=i+1)
		begin
		  stat_mem[i]  <= 2'b00;
		  tag_mem[i]   <= 1'h0;
		  cache_mem[i] <= 32'h00000000;
		end
	 
	 reg [7:0]    p_data_out;
    reg [31:0]   b_data_out, snoop_data_out;
    reg [5:0]	  b_addr_out;
	 
	 wire [3:0]   tag, sn_tag;
	 wire [1:0]   index, offset, sn_index;	 
	 
	 assign tag    = p_addr[7:4],          // p_addr = {tag, index, offset}
		     index  = p_addr[3:2],
		     offset = p_addr[1:0];
		  
	 assign Z = (tag == tag_mem[index]),
	        V = stat_mem[index][1],
			  D = stat_mem[index][0];
			  
			  
	 assign sn_tag    = snoop_addr[5:2],   // snoop_addr = {sn_tag, sn_index}
		     sn_index  = snoop_addr[1:0];
			  
	 assign sn_Z = (sn_tag == tag_mem[sn_index]),
	        sn_V = stat_mem[sn_index][1];
	   
	  		  
		  
	 always @(posedge clk)
	 begin
	   invalidate_out = 1'b0;
	   case (func)	 
	     p_read  : case (offset)
		              2'b00   : p_data_out <= cache_mem[index][31:24];
		              2'b01   : p_data_out <= cache_mem[index][23:16];
		              2'b10   : p_data_out <= cache_mem[index][15:8];
		              2'b11   : p_data_out <= cache_mem[index][7:0]; 
		              default : p_data_out <= 8'bz;
	               endcase		
		  p_write : begin
		              case (offset)
		                2'b00 : cache_mem[index][31:24] <= p_data;
		                2'b01 : cache_mem[index][23:16] <= p_data;
		                2'b10 : cache_mem[index][15:8]  <= p_data;
		                2'b11 : cache_mem[index][7:0]   <= p_data; 
	                 endcase		
                    stat_mem[index][0] <= 1'b1;    // assign dirty on processor write
						  invalidate_out      = 1'b1;    // invalidate other cache entries on processor write
                  end
        b_read  : begin
		              b_addr_out         <= p_addr[7:2];
					     cache_mem[index]   <= b_data;
		              tag_mem[index]     <= b_addr[5:2];
					     stat_mem[index][1] <= 1'b1;    // assign valid on freshly read data
					     stat_mem[index][0] <= 1'b0;    // assign clean on freshly read data
				      end				  
		  b_write : begin
		              b_addr_out          <= {tag_mem[index], index};
					     b_data_out          <= cache_mem[index];
					     stat_mem[index][0]  <= 1'b0;   // assign clean on write-back
				      end	  
	   endcase
	 end
	 
	 
	 always @(posedge clk)
	 begin
	   snoop_ready = 1'b0;
		
      if (invalidate_in)
        stat_mem[sn_index] <= 2'b00;		  
		  
      if (snoop_in)
      begin
	     snoop_data_out <= cache_mem[sn_index];
		  snoop_ready     = 1'b1;
		end
		
		if (snoop_hit_in)
      begin
		  cache_mem[index] <= snoop_data;
		  tag_mem[index]   <= snoop_addr[5:2];
		end
		
    end		
		
	 
	 assign read_hit  = V && Z,
	        write_hit = V && Z && D;
			  
	 assign snoop_hit_out = sn_V && sn_Z;
	 
	
	 assign b_addr = (func==b_write || func==b_read) ? b_addr_out :  6'bz,
	        b_data = (func==b_write)                 ? b_data_out : 32'bz,
	        p_data = (func==p_read)                  ? p_data_out :  8'bz;
			  
	 assign snoop_addr = (snoop_out || invalidate_out) ? p_addr[7:2]    :  6'bz,
	        snoop_data =  snoop_in                     ? snoop_data_out : 32'bz, 
	        stat       =  stat_mem[index];
		 
	 
endmodule
