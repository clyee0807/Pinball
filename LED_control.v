module LED_control(
    input clk,
    input flash_clk,
    input reset,
    input [3-1:0] state,
    input btn_down,
    output reg [8-1:0] LED,
    output reg [3-1:0] selected_group
);

    parameter RESET = 3'd0;
    parameter WAIT = 3'd1;
    parameter START = 3'd2;
    parameter GET = 3'd3;
    parameter OVER = 3'd4;

    reg [3-1:0] flash_cnt;
    wire [3-1:0] next_flash_cnt;

    //flash_cnt
    always @(posedge clk) begin
        if(reset == 1'b1)
            flash_cnt <= 3'd0;
        else begin
            if(flash_clk == 1'b1)
                flash_cnt <= next_flash_cnt;
            else
                flash_cnt <= flash_cnt;
        end
    end

    assign next_flash_cnt = flash_cnt + 3'd1;

    //selected_group
    always @(*) begin
        case(state)
            RESET: selected_group = 3'd0;
            WAIT: selected_group = 3'd0;
            START: selected_group = (btn_down == 1'b1)? flash_cnt : 3'd0;
            GET: selected_group = selected_group;
            OVER: selected_group = 3'd0;
            default: selected_group = 3'd0;
        endcase
    end

    //LED
    always @(*) begin
        case(state)
            RESET:
                LED = 8'b0000_0000; 
            WAIT:
                LED = 8'b1111_1111;
            START: begin
                case(flash_cnt)
                    3'd0: LED = 8'b0101_0101;   //1/3/5/7
                    3'd1: LED = 8'b0100_1001;   //1/4/7
                    3'd2: LED = 8'b0001_0010;   //3/6
                    3'd3: LED = 8'b0010_0000;   //2
                    3'd4: LED = 8'b1010_1010;   //0/2/4/6
                    3'd5: LED = 8'b1001_0010;   //0/3/6
                    3'd6: LED = 8'b0100_1000;   //1/4
                    3'd7: LED = 8'b0000_0100;   //5
                    default: LED = 8'b1111_1111;
                endcase
            end
            GET:
                LED = LED;
            OVER:
                LED = 8'b0000_0000;
            default:
                LED = 8'b0000_0000;
        endcase
    end

endmodule