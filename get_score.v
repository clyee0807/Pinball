module get_score(  // 算可以加幾分
    input clk,
    input [2:0] state,
    input [8-1:0] getball,  // 球進哪個洞
    input [3-1:0] selected_group, // 現在是哪一個得分組合
    output reg [15-1:0] score //
);

parameter RESET = 3'd0;
parameter WAIT = 3'd1;
parameter START = 3'd2;
parameter GET = 3'd3;
parameter OVER = 3'd4;

// reg match; // 看是否有進正確的洞
reg [15-1:0] next_score;
always @(posedge clk) begin
    score <= next_score;
end 

// 看現在哪幾個洞進去會得分
reg [8-1:0] have_score;
reg [15-1:0] add_score;
always @(*) begin
    case(selected_group)
        3'd0: begin
            add_score = score + 2;
            have_score = 8'b0101_0101; //1/3/5/7
        end
        3'd1: begin
            add_score = score + 4;
            have_score = 8'b0100_1001; //1/4/7
        end
        3'd2: begin
            add_score = score + 8;
            have_score = 8'b0001_0010; //3/6
        end
        3'd3: begin
            add_score = score + 16;
            have_score = 8'b0010_0000;  //2
        end
        3'd4: begin
            add_score = score + 2;
            have_score = 8'b1010_1010;  //0/2/4/6
        end
        3'd5: begin
            add_score = score + 4;
            have_score = 8'b1001_0010;  //0/3/6
        end
        3'd6: begin
            add_score = score + 8;
            have_score = 8'b0100_1000;  //1/4
        end
        3'd7: begin
            add_score = score + 16;
            have_score = 8'b0000_0100;   //5
        end
        default: begin
            add_score = score;
            have_score = 8'b0000_0000;
        end
    endcase 
end

// 更新分數
always @(*) begin
    case(state)
        RESET: begin
            next_score = 0;
        end
        GET: begin
            if(getball & have_score != 8'd0) next_score = add_score;
            else next_score = score;
        end
        OVER: begin
            next_score = 0;
        end
        default: next_score = score;
    endcase
end


endmodule