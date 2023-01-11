module get_score(  // 算可以加幾分
    input clk,
    input [2:0] state,
    input [8-1:0] ball,
    input [3-1:0] selected_group, // 現在是哪一個得分組合
    output [8-1:0] getball,  // 球進哪個洞
    output reg [15-1:0] score, //
    output wire win,
    output match
);

parameter RESET = 3'd0;
parameter WAIT = 3'd1;
parameter START = 3'd2;
parameter GET = 3'd3;
parameter OVER = 3'd4;


reg [15-1:0] next_score;

// 看現在哪幾個洞進去會得分
reg [8-1:0] have_score;
reg [15-1:0] add_score;
always @(*) begin
    case(selected_group)
        3'd0: begin
            add_score = 15'd10;
            have_score = 8'b1010_1010; //1/3/5/7
        end
        3'd1: begin
            add_score = 15'd20;
            have_score = 8'b1001_0010; //1/4/7
        end
        3'd2: begin
            add_score = 15'd50;
            have_score = 8'b0100_1000; //3/6
        end
        3'd3: begin
            add_score = 15'd100;
            have_score = 8'b0000_0100;  //2
        end
        3'd4: begin
            add_score = 15'd10;
            have_score = 8'b0101_0101;  //0/2/4/6
        end
        3'd5: begin
            add_score = 15'd20;
            have_score = 8'b0100_1001;  //0/3/6
        end
        3'd6: begin
            add_score = 15'd50;
            have_score = 8'b0001_0010;  //1/4
        end
        3'd7: begin
            add_score = 15'd100;
            have_score = 8'b0010_0000;   //5
        end
        default: begin
            add_score = 15'd0;
            have_score = 8'b0000_0000;
        end
    endcase 
end

always @(posedge clk) begin
    score <= next_score;
end 

wire match; // 有進到有分數的洞的話會是1
assign match = ((ball & have_score) != 8'd0);
assign win = (score >= 15'd100) ? 1'b1 : 1'b0;

// 更新分數
always @(*) begin
    case(state)
        RESET: begin
            next_score = 0;
        end
        START: begin
            if(match != 1'b0)
                next_score = score + add_score;
            else
                next_score = score;
        end
        default: next_score = score;
    endcase
end


endmodule