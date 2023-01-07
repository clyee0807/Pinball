`timescale 1ps/1ps

module Top(
    input clk,
    input [8-1:0] ball,
    input start_btn, round_btn, rst_btn,
    output reg [8-1:0] LED,
    output reg [3:0] AN,
    output reg [6:0] seg
);

wire Sbtn_db, Rbtn_db, rst_db, Sbtn_op, Rbtn_op, rst_op;
debounce db1(Sbtn_db, start_btn, clk);
debounce db2(Rbtn_db, round_btn, clk);
debounce db3(rst_db, rst_btn, clk);
onepulse op1(Sbtn_db, clk, Sbtn_op);
onepulse op2(Rbtn_db, clk, Rbtn_op);
onepulse op3(rts_db, clk, rst_op);


parameter RESET = 3'd0;
parameter WAIT = 3'd1;
parameter START = 3'd2;
parameter GET = 3'd3;
parameter OVER = 3'd4;

reg [2:0] state, next_state;
reg [15-1:0] score, next_score; // 現在總得分
reg [4-1:0] ball_num; // 剩幾顆球
reg [8-1:0] getball; //記球進哪個洞
reg [3-1:0] selected_group;  // 可以得分的洞口組合
reg [30-1:0] secCounter, next_secCounter; // 秒數計時器(最多記到5秒)


ball_sensor BS(  // 更新球數、判斷是否有得分、球進哪個洞
    .clk(clk),
    .ball(ball),
    .state(state),
    .ball_num(ball_num), //
    .getball(getball) //
);

generate_LED led(
    .clk(clk),
    .state(state),
    .LED(LED),  //
    .selected_group(selected_group) //
);

get_score GS(
    .clk(clk),
    .state(state),
    .getball(getball),
    .selected_group(selected_group), 
    .score(score) //
);

// second counter
always @(*) begin
    if(secCounter == 30'd5000000) next_secCounter = 30'd0;
    else begin
        next_secCounter = secCounter + 1'b1;
    end
end

// state transfer
always @(posedge clk) begin
    if(rst_op == 1'b1) begin
        state <= RESET;
        secCounter <= 0;
    end
    else begin
        state <= next_state;
        secCounter <= next_secCounter;
    end
end

always @(*) begin
    case(state)
        RESET: begin
            if(Sbtn_op)  next_state = WAIT;
            else next_state = RESET;
        end
        WAIT: begin
            if(Rbtn_op) next_state = START;
            else next_state = WAIT;
        end
        START: begin
            if(ball != 8'b00000000) next_state = GET; // 有球滾過去了
            else next_state = START;
        end
        GET: begin
            if(secCounter >= 30'd2000000 && ball_num > 3'd0) next_state = WAIT;
            else if(ball_num == 3'd0) next_state = OVER;
            else next_state = GET;
        end
        OVER: begin
            if(Sbtn_op == 1'b1) next_state = RESET;
            else next_state = OVER;
        end
        default: next_state = state;
    endcase
end

// what state do

endmodule



module debounce (pb_debounced, pb, clk);
    output pb_debounced; 
    input pb;
    input clk;
    reg [4:0] DFF;
    
    always @(posedge clk) begin
        DFF[4:1] <= DFF[3:0];
        DFF[0] <= pb; 
    end
    assign pb_debounced = (&(DFF)); 
endmodule

module onepulse (PB_debounced, clk, PB_one_pulse);
    input PB_debounced;
    input clk;
    output reg PB_one_pulse;
    reg PB_debounced_delay;

    always @(posedge clk) begin
        PB_one_pulse <= PB_debounced & (! PB_debounced_delay);
        PB_debounced_delay <= PB_debounced;
    end 
endmodule

