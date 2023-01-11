module LED_control(
    input clk,
    input led_clk,
    input reset,
    input win,
    input [3-1:0] state,
    input [8-1:0] selected_group,
    input [15-1:0] score,  
    output reg [8-1:0] LED
);

    parameter RESET = 3'd0;
    parameter WAIT = 3'd1;
    parameter START = 3'd2;
    parameter GET = 3'd3;
    parameter OVER = 3'd4;

    reg [3-1:0] led_cnt, next_led_cnt;
    reg direction, next_direction;

    wire winclk, loseclk;
    Clock_Divider_25 clkk25(clk, winclk); // 越高越慢 
    Clock_Divider_27 clkk27(clk, loseclk); // 越高越慢 

    //led_cnt
    always @(posedge clk) begin
        if(reset == 1'b1) begin
            led_cnt <= 3'd0;
            direction <= 1'b0;
        end
        else begin
            if(led_clk == 1'b1) begin
                led_cnt <= next_led_cnt;
                direction <= next_direction;
            end
            else begin
                led_cnt <= led_cnt;
                direction <= next_direction;
            end
        end
    end

    always @(*) begin
        //up
        if(direction == 1'b0) begin
            if(led_cnt == 3'd7)
                next_direction = 1'b1;
            else
                next_direction = direction;
        end
        //down
        else begin
            if(led_cnt == 3'b0)
                next_direction = 1'b0;
            else
                next_direction = direction;
        end
    end

    always @(*) begin
        if(direction == 1'b0) begin
            if(led_cnt == 3'd7)
                next_led_cnt = 3'd6;
            else
                next_led_cnt = led_cnt + 3'b1;
        end
        else begin
            if(led_cnt == 3'b0)
                next_led_cnt = 3'b1;
            else
                next_led_cnt = led_cnt - 3'b1;
        end
    end


    always @(*) begin
        case(state)
            RESET: begin
                case(led_cnt)
                    3'd0: LED = 8'b1000_0000;   
                    3'd1: LED = 8'b0100_0000;   
                    3'd2: LED = 8'b0010_0000;   
                    3'd3: LED = 8'b0001_0000;   
                    3'd4: LED = 8'b0000_1000;   
                    3'd5: LED = 8'b0000_0100;   
                    3'd6: LED = 8'b0000_0010;   
                    3'd7: LED = 8'b0000_0001;   
                    default: LED = 8'b0;
                endcase
            end
            // WAIT:
                // LED = 8'b1111_1111;
            START, WAIT, GET: begin
                case(selected_group)
                    3'd0: LED = 8'b1010_1010;   //1/3/5/7
                    3'd1: LED = 8'b1001_0010;   //1/4/7
                    3'd2: LED = 8'b0100_1000;   //3/6
                    3'd3: LED = 8'b0000_0100;   //2
                    3'd4: LED = 8'b0101_0101;   //0/2/4/6
                    3'd5: LED = 8'b0100_1001;   //0/3/6
                    3'd6: LED = 8'b0001_0010;   //1/4
                    3'd7: LED = 8'b0010_0000;   //5
                    default: LED = 8'b1111_1111;
                endcase
            end
            OVER: begin
                if(win) begin
                    LED = (winclk == 1'b1) ? 8'b1111_1111 : 8'b0000_0000;
                    // LED = 8'b0000_0000;
                end
                else begin
                    LED = (loseclk == 1'b1) ? 8'b0000_0000 : 8'b1000_0001;
                end
            end
            default:
                LED = 8'b0000_0000;
        endcase
    end

endmodule

module Clock_Divider_25(clk, clkdiv);  // divided by 17
input clk;   
output clkdiv;

reg [25-1:0] num;
wire [25-1:0] next_num;

always @(posedge clk) begin
    num <= next_num;
end
assign next_num = num + 1;
assign clkdiv = num[25-1];
endmodule


module Clock_Divider_27(clk, clkdiv);  // divided by 20
input clk;   
output clkdiv;

reg [27-1:0] num;
wire [27-1:0] next_num;

always @(posedge clk) begin
    num <= next_num;
end

assign next_num = num + 1;
assign clkdiv = num[27-1];
endmodule