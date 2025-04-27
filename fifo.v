module fifo #(parameter abits = 4, dbits = 8)
            ( clk, rst, wr, rd, din, dout, empty, full);
    input   clk, rst, wr, rd;
    input   [dbits-1:0] din;
    output  reg [dbits-1:0] dout;
    output  empty, full;
           
    reg     [dbits-1:0] mem [(1<<abits)-1:0];
    reg     [abits-1:0] read, write;
     
    fifo_ctrl #(.abits(abits)) fctl (.clk(clk), .rst(rst), .inc(wr), .dec(rd), .e(empty), .f(full) );         
            
    always @(posedge clk)
        if(rst)
            write <= 0;
        else if (wr) begin
            if(!full)
              if(!rd)
                mem[write] <= din;	            
            write <= (full || rd)?  write:write + 1;
        end
                
    always @(posedge clk)
        if(rst)begin
            read <= 0;    
            dout <= 0;            
        end else if(rd)begin
                if(!wr)
                    dout <= (empty)? 0:mem[read];
               	else
               	    dout <= din;
                read <= (empty || wr)? read: read + 1;
        end 
endmodule
