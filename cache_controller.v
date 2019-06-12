`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: avisekh007
// 
// Create Date:    09:28:51 06/11/2019 
// Design Name: 
// Module Name:    cache_controller 
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
module cache_controller(
    input reset, read_hit, write_hit, clk, req, pfunc, mem_ready, snoop_ready, snoop_hit,
	 input [1:0] stat,
	 
    output reg ready, mem_rd, mem_wr, mem_cs, snoop_out, 
	 output reg [1:0] func
    );
	 
	  
	                              //      DATA       |       ADDR      
	 parameter p_read  = 2'b00,   // cache -> prcsr  |  prcsr -> cache   (Processor Read)
	           p_write = 2'b01,   // prcsr -> cache  |  prcsr -> cache   (Processor Write)
				  b_read  = 2'b10,   // bus   -> cache  |  cache -> bus     (Bus Read)
				  b_write = 2'b11;   // cache -> bus    |  cache -> bus     (Write Back)
				  
	 parameter excl = 2'b11,      // Exclusive State
	           shrd = 2'b10,      // Shared State
				  invl = 2'b00;      // Invalid State
	 
	 parameter S0 = 3'b00,
	           S1 = 3'b01,
				  S2 = 3'b10,
				  S3 = 3'b11;
	 
	 reg [1:0]  state, next_state;		  
	 
    always @(posedge clk, negedge reset)
    begin
      if (~reset)
		  state <= S0;
		else
		  state <= next_state;
	 end
	 
	 
	 always @(state, reset, req, read_hit, write_hit, pfunc, mem_ready, snoop_ready, snoop_hit, stat)
	 begin
	   next_state = state;
	   case(state)   
					  
		  S0      :  if (req)  next_state = S1; 
					  
		  S1      :  begin
		               if      (read_hit)                              next_state = S0;
						   else if (!read_hit && (stat==excl))             next_state = S2;
						   else if (!read_hit && (stat==shrd||stat==invl)) next_state = S3;
					    end
					  
		  S2      :  if (mem_ready) next_state = S3;
		        
		  S3      :  if ((snoop_hit && snoop_ready) || (!snoop_hit && mem_ready)) next_state = S1;
		
	   endcase
	 end
	 
	 
	 
	 always @(state, read_hit, write_hit, pfunc, mem_ready, snoop_hit, stat)
	 begin
	
	   ready       = 0;
		mem_rd      = 0;
		mem_wr      = 0; 
		mem_cs      = 0;
		snoop_out   = 0;
		func        = 2'b00;
		
	   case(state) 
		  S0  :  ready = 1;
		  
		  S1  :  begin
		           if (read_hit)
                 begin
					    func = pfunc;
					  end
					  else if ((!read_hit||!write_hit) && (stat==excl))             func = b_write;
					  else if ((!read_hit||!write_hit) && (stat==shrd||stat==invl)) begin func = b_read; snoop_out = 1; end
				   end				  
		  
		  S2  :  begin
		           func = b_write;
					  mem_wr = 1;
					  if (!mem_ready) 
					    mem_cs = 1;
					  else if (mem_ready) 
					  begin
					    func      = b_read;
					    snoop_out = 1;
					  end
					end
		  
		  S3  :  begin
		           func      = b_read;
                 mem_rd    = 1;
					  mem_cs    = 1; 
                 snoop_out = 1;	
                 if (snoop_hit) mem_cs = 0;					  
					end
	   endcase
	 end
     		
endmodule
