module tim #(parameter bbits = 16)
    (
        input  clk, 
        input  rst,
        input  enable, 
        input  [bbits-1:0] cnt_val,
        output alarm
    );
    
    
    reg  [bbits-1:0] count, count_prev; 
    wire [bbits-1:0] count_next;
    wire  pulse;
    wire  zero = (cnt_val == 0);
    wire  cnt_end = (count == cnt_val);
    
    assign count_next = (count == (cnt_val))? 0: count + 1;
    assign alarm = rst ? 1'b0 :((zero)? enable:(cnt_end)&& pulse);
    
    always @(posedge clk)
        count_prev <= count;
    
    assign pulse = count_prev != count;
    
    always @(posedge clk)
        if(rst)
            count <= 0;
        else 
            if(enable)
                count <= count_next;
            
endmodule
