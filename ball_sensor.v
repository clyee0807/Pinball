module ball_sensor(
    input clk,
    input [8-1:0] ball,
    input [2:0] state,
    // output has_pass,
    output reg [4-1:0] ball_num,
    output reg [8-1:0] getball  // 球進哪個洞
);

parameter RESET = 3'd0;
parameter WAIT = 3'd1;
parameter START = 3'd2;
parameter GET = 3'd3;
parameter OVER = 3'd4;

// which hole
// assign getball = ball_op;
reg [8-1:0] next_getball;
always @(posedge clk) begin
    getball <= next_getball;
end

always @(*) begin
    case(state)
        START: begin
            if(ball != 8'b0)
                next_getball = ball;
            else
                next_getball = getball;
        end
        default: next_getball = getball;
    endcase
end

// update the # of ball
reg [4-1:0] next_ball_num;
always @(posedge clk) begin
    ball_num <= next_ball_num;
end
always @(*) begin
    case(state)
        RESET: begin
            next_ball_num = 4'd8;
        end
        START: begin
            // if(has_pass) next_ball_num = ball_num - 1;
            if(ball != 8'b0) next_ball_num = ball_num - 1;
            else next_ball_num = ball_num;
        end
        default: next_ball_num = ball_num;
    endcase
end


endmodule

