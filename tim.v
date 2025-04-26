module tim #(parameter bbits = 16)
    (
        input  clk, 
        input  rst,
        input  enable, 
        input  [bbits-1:0] cnt_val,
        output alarm
    );
    
    
    reg  [bbits-1:0] count; 
    wire [bbits-1:0] count_next;
    
    always @(posedge clk)
        if(rst)
            count <= 0;
        else 
            if(enable)
                count <= count_next;
            
    assign count_next = (count == (cnt_val))? 0: count + 1;
    assign alarm      = rst? 0:(count == (cnt_val));
endmodule
