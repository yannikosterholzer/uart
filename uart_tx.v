module uart_tx #(parameter dbits = 8, bbits = 16)(
        input  clk,
        input  rst, 
        input  [dbits-1:0] din,
        input  tx_start,        
        input  tick,
        output reg tx,
        output tx_done
    );

    localparam TOTAL_BITS = dbits + 2;
    
    reg [dbits+1:0] data;
    reg [1:0] state, next_state;
    wire ready, data_ready;
    reg [bbits-1:0] cnt_val, bit_num;
    reg cnt_rst, bcn_rst;

    assign tx_done = data_ready;
    
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
    
    parameter idle = 0, start = 1, set_bits = 2, stop = 3;     
    always @(posedge clk)
        if(rst)
            state <= idle;
        else
            state <= next_state;
     
    always @(*) begin
        case(state)
            idle:       next_state = (tx_start)?      start: idle;
            start:      next_state =  set_bits;
            set_bits:   next_state = (data_ready)?    idle: set_bits;       
        endcase
    end
    
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
            if(state == set_bits) begin
                cnt_rst   = 0;
                bcn_rst   = 0;
                cnt_val   = 0;
                bit_num  = TOTAL_BITS;                          
                end    
             end
    
    
    always @(posedge clk)  
            if(rst)
                data <= 10'b11_1111_1111;
            else 
            if(state == start) begin
                data <= {1'b1, din[7:0], 1'b0};
                end
            else               
                if((state == set_bits) && ready)begin  
                    data <= {1'b1, data[9:1]};  
                    end
            

    always @(posedge clk)
        if(rst)
            tx <= 1; 
        else begin               
                if((state == set_bits) && ready)begin  
                    tx <= data[0];
                    end
                end
                        
          
endmodule
