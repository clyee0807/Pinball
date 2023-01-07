module ball_sensor(
    input clk,
    input [8-1:0] ball,
    input [2:0] state,
    output reg [4-1:0] ball_num,
    output wire [8-1:0] getball  // 球進哪個洞
);

parameter RESET = 3'd0;
parameter WAIT = 3'd1;
parameter START = 3'd2;
parameter GET = 3'd3;
parameter OVER = 3'd4;

wire [8-1:0] ball_db, ball_op;
debounce db0(ball_db[0], ball[0], clk);
debounce db1(ball_db[1], ball[1], clk);
debounce db2(ball_db[2], ball[2], clk);
debounce db3(ball_db[3], ball[3], clk);
debounce db4(ball_db[4], ball[4], clk);
debounce db5(ball_db[5], ball[5], clk);
debounce db6(ball_db[6], ball[6], clk);
debounce db7(ball_db[7], ball[7], clk);
onepulse op0(ball_db[0], clk, ball_op[0]);
onepulse op1(ball_db[1], clk, ball_op[1]);
onepulse op2(ball_db[2], clk, ball_op[2]);
onepulse op3(ball_db[3], clk, ball_op[3]);
onepulse op4(ball_db[4], clk, ball_op[4]);
onepulse op5(ball_db[5], clk, ball_op[5]);
onepulse op6(ball_db[6], clk, ball_op[6]);
onepulse op7(ball_db[7], clk, ball_op[7]);

wire has_pass;  // 有球通過
assign has_pass = (ball_op[0] || ball_op[1] || ball_op[2] || ball_op[3] ||
                   ball_op[4] || ball_op[5] || ball_op[6] || ball_op[7]); 

// which hole
assign getball = ball_op;

// update the # of ball
always @(*) begin
    case(state)
        RESET: begin
            ball_num = 4'd8;
        end
        GET: begin
            if(has_pass) ball_num = ball_num - 1;
            else ball_num = ball_num;
        end
        default: ball_num = ball_num;
    endcase
end


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
