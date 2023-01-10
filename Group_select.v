module Group_select(
    input clk,
    input flash_clk,
    input reset,
    input [3-1:0] state,
    input btn_down,
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

endmodule