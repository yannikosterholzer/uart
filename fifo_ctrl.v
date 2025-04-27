module fifo_ctrl #(parameter abits = 4)(clk, rst, inc, dec , e, f);
    input clk, rst, inc, dec;
    output e; //empty
    output f; //full

    assign e = (counter == 0); 
    assign f = (counter[abits] == 1);
    
    reg [abits:0] counter;
    
    wire [1:0] state = {inc, dec};
    
    always @(posedge clk)
        if(rst)
            counter <= 0;
        else begin
            case(state)
                2      :  counter <= (counter[abits] == 1)? counter: counter + 1;  
                1      :  counter <= (counter == 0)? counter :counter - 1; 
                default:  counter <= counter;
            endcase
        end
     

    
endmodule
