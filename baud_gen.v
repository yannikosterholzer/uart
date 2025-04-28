module baud_gen #(parameter bbits = 16)
    (
        input  clk, 
        input  rst,
        input  [bbits-1:0] dvsr,
        output bd_tick,
        output os_tick //oversampling
    );
    
    wire [bbits-1:0] os_cnt = dvsr >> 4;
    
    tim #(.bbits(16))
    baud_timer
    (
        .clk(clk), 
        .rst(rst),
        .enable(1'b1),
        .cnt_val(dvsr-1),
        .alarm(bd_tick)
    );
    
    tim #(.bbits(16))
    oversampling_timer
    (
        .clk(clk), 
        .rst(rst),
        .enable(1'b1),
        .cnt_val(os_cnt-1),
      .alarm(os_tick)
    );
      
endmodule
