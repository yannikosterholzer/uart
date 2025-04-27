module uart_rx #(parameter dbits = 8, sample = 16)
    (
        input  clk,
        input  rst,
        input  tick,
        input  rx,
        output rx_done,
        output reg [dbits-1:0] dout
    );
    
    wire ready, data_ready;
    reg  [1:0] state, next_state;
    reg  rx_buff, rx_data;


    tim #(.bbits(bbits))
    counter
    (
        .clk(clk), 
        .rst(cnt_rst),
        .enable(tick),
        .cnt_val(cnt_val),
        .alarm(ready)
    );
    
    tim #(.bbits(bbits))
    bit_counter
    (
        .clk(clk), 
        .rst(bcn_rst),
        .enable(ready),
        .cnt_val(bit_num),
        .alarm(data_ready)
    );
    
    // Synchronisierung wg CDC
    always @(posedge clk) begin
        rx_buff <= rx;
        rx_data <= rx_buff;
        end
    
    parameter idle = 0, start = 1,  get_bits = 2, stop = 3;   
    always @(posedge clk)
        if(rst) 
            state <= idle;
        else 
            state <= next_state;
    

    always @(*) begin
        next_state = idle;
            case(state)
                idle     :   next_state = (rx_data)   ?         idle     : start;
                start    :   next_state = (ready)     ?         get_bits : start;
                get_bits :   next_state = (data_ready)?         stop     : get_bits;
                stop     :   next_state = (rx_data && ready )?  idle     : stop;
            endcase
        end
     
    
    parameter bbits = 16;
    reg [bbits-1:0] cnt_val, bit_num;
    reg cnt_rst, bcn_rst;
    
    always @(*)
        if(rst) begin
            cnt_rst   = 1;
            bcn_rst   = 1;
            cnt_val   = 0;  
            bit_num   = 0;          
        end else begin
            cnt_rst   = 1;
            bcn_rst   = 1;
            cnt_val   = 0;  
            bit_num   = 0;         
            case(state)
                start    :   begin
                                 cnt_rst   = 0;
                                 cnt_val   = dbits-1;                            
                             end
                get_bits :   begin
                                 cnt_rst   = 0;
                                 bcn_rst   = 0;
                                 cnt_val   = sample-1;
                                 bit_num   = 8;                            
                             end
                stop     :   begin
                                 cnt_rst   = 0;
                                 cnt_val   = sample-1;
                             end             
            endcase
        end
    
    always @(posedge clk)
                if(ready)
                    dout <= {rx_data, dout[dbits-1:1]};   

    assign rx_done = rst? 0:(state == stop && (rx_data && ready ));              

endmodule
