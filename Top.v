`timescale 1ps/1ps

module Top(
    input clk,
    input [8-1:0] ball,
    input start_btn, round_btn, rst_btn, // ?Ñ°Ê≥ïreset
    // output reg [3-1:0] state,
    output [8-1:0] show_ball,
    output reg [0:8-1] scoreLED,
    output wire [8-1:0] LED,
    output reg [3:0] AN,
    output reg [6:0] seg,
    output AIN,
    output GAIN,
    
    output SHUTDOWN
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

// wire has_pass; // ??âÁ?ÉÈ?öÈ??
reg [2:0] state, next_state;
wire [15-1:0] score; // ?èæ?ú®Á∏ΩÂ?óÂ??
reg [3:0] show_score; // È°ØÁ§∫?ú®7segment‰∏äÁ?ÑÂ?ÜÊï∏
wire [4-1:0] ball_num; // ?â©ÂπæÈ?ÜÁ??
wire [8-1:0] getball; //Ë®òÁ?ÉÈ?≤Âì™?ãÊ??
wire [3-1:0] selected_group;  // ?èØ‰ª•Â?óÂ?ÜÁ?ÑÊ?ûÂè£ÁµÑÂ??
reg [30-1:0] secCounter, next_secCounter; // ÁßíÊï∏Ë®àÊ?ÇÂô®(??Â§öË?òÂà∞5Áß?)
wire flash_clk, led_clk, display_clk; 
wire win; // ?à§?ñ∑?òØ‰∏çÊòØË¥è‰??
wire match; // ?≤Â?çÁ?ÑÊ??

assign show_ball = ball;

ClockDivider17 clk17(clk, rst_op, display_clk);
ClockDivider23 clk23(clk, rst_op, flash_clk);
ClockDivider24 clk24(clk, rst_op, led_clk);

audio OD(
    .clk(clk), 
    .reset(rst_op), 
    .state(state), 
    .match(match),
    .AIN(AIN),          //
    .GAIN(GAIN),        //
    .SHUTDOWN(SHUTDOWN) //
);

ball_sensor BS(  // ?õ¥?ñ∞??ÉÊï∏?ÅÂà§?ñ∑?òØ?ê¶??âÂ?óÂ?Ü„?ÅÁ?ÉÈ?≤Âì™?ãÊ??
    .clk(clk),
    .ball(ball),
    .state(state),
    // .has_pass(has_pass), //
    .ball_num(ball_num), //
    .getball(getball) //
);

LED_control led(
    .clk(clk),
    .led_clk(led_clk),
    .reset(rst_op),
    .state(state),
    .win(win),
    .selected_group(selected_group), //
    .LED(LED)  //
);


Group_select GSL(
    .clk(clk),
    .flash_clk(flash_clk),
    .reset(rst_op),
    .state(state),
    .btn_down(Rbtn_op),
    .selected_group(selected_group)  
);

get_score GS(
    .clk(clk),
    .state(state),
    .ball(ball),
    .getball(getball),
    .selected_group(selected_group), 
    .score(score), //
    .win(win), //
    .match(match)
);

// show score on 7segment
reg [1:0] display_cnt;
wire [1:0] next_display_cnt;
assign next_display_cnt = display_clk ? (display_cnt + 1'b1) : display_cnt;

always @(posedge clk) begin
    if(rst_op)  display_cnt <= 2'b00;
    else display_cnt <= next_display_cnt;
end

always @(*) begin
    case(display_cnt) 
        2'b00: begin
            AN = 4'b1111;  // debug(origin: AN = 1111)
        end
        2'b01: begin
            if(score >= 15'd100) begin 
                AN = 4'b1011;
            end
            else begin
                AN = 4'b1111;
            end
        end
        2'b10: begin
            if(score >= 15'd10) begin
                AN = 4'b1101;
            end
            else begin
                AN = 4'b1111;
            end
        end
        2'b11: begin
            AN = 4'b1110;
        end
        default: begin
            AN = 4'b1111;
        end
    endcase
end


always @(*) begin
    case(display_cnt) 
        2'b00: begin
            show_score = 4'd12;
            // case(getball)
            //     8'b1000_0000: show_score = 4'd7;
            //     8'b0100_0000: show_score = 4'd6;
            //     8'b0010_0000: show_score = 4'd5;
            //     8'b0001_0000: show_score = 4'd4;
            //     8'b0000_1000: show_score = 4'd3;
            //     8'b0000_0100: show_score = 4'd2;
            //     8'b0000_0010: show_score = 4'd1;
            //     8'b0000_0001: show_score = 4'd0;
            //     default: show_score = 4'd8;
            // endcase
        end
        2'b01: begin
            show_score = score / 15'd100;
        end
        2'b10: begin
            show_score = (score / 15'd10) % 15'd10;
        end
        2'b11: begin
            show_score = score % 15'd10;
        end
        default: begin
            show_score = 4'd10;
        end
    endcase
end


always @(*) begin
    case(show_score)
        4'd0:  seg = 7'b0000001;
        4'd1:  seg = 7'b1001111; 
        4'd2:  seg = 7'b0010010;
        4'd3:  seg = 7'b0000110;
        4'd4:  seg = 7'b1001100;   
        4'd5:  seg = 7'b0100100;
        4'd6:  seg = 7'b0100000;
        4'd7:  seg = 7'b0001111;
        4'd8:  seg = 7'b0000000;
        4'd9:  seg = 7'b0000100; 
        4'd10: seg = 7'b0001000; 
        default: seg = 7'b1111111;
    endcase
end


// show the number of ball
always @(*) begin
    case(ball_num)
        4'd8: scoreLED = 8'b11111111;
        4'd7: scoreLED = 8'b11111110;
        4'd6: scoreLED = 8'b11111100;
        4'd5: scoreLED = 8'b11111000;
        4'd4: scoreLED = 8'b11110000;
        4'd3: scoreLED = 8'b11100000;
        4'd2: scoreLED = 8'b11000000;
        4'd1: scoreLED = 8'b10000000;
        4'd0: scoreLED = 8'b00000000;
        default: scoreLED = 8'b00000000;
    endcase
end

always @(posedge clk) begin
    if(state == GET) begin
        secCounter <= next_secCounter; 
    end
    else begin
        secCounter <= 30'd0;
    end
end

// second counter
always @(*) begin
    if(state == GET) begin
        next_secCounter = secCounter + 30'b1;
    end
    else begin
        next_secCounter = 30'b0;
    end
end

// state transfer
always @(posedge clk) begin
    if(rst_btn == 1'b1) begin  // op
        state <= RESET;
        // secCounter <= 30'b0;
    end
    else begin
        state <= next_state;
        // secCounter <= next_secCounter;
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
            if(ball != 8'b0) next_state = GET; // ??âÁ?ÉÊªæ??éÂéª‰∫?
            else next_state = START;
        end
        GET: begin
            if(secCounter >= 30'd2_0000_0000) begin
                if(ball_num > 4'd0)
                    next_state = WAIT;
                else
                    next_state = OVER;
            end
            else next_state = GET;
        end
        OVER: begin
            if(Sbtn_op == 1'b1) next_state = RESET;
            else next_state = OVER;
        end
        default: next_state = state;
    endcase
end


endmodule


// ClockDivider25 - flash
module ClockDivider23 (clk, rst_n, newclk);
    input clk, rst_n;
    output reg newclk;

    reg [23-1:0] ctr_co;
    always @(posedge clk) begin
        if(rst_n) begin
            ctr_co <= 23'b0;
        end
        else begin
            ctr_co <= ctr_co + 23'b1;
        end 
    end
    always @(posedge clk) begin
        if(rst_n) begin
            newclk <= 23'b0;
        end
        else begin
            newclk <= ctr_co == 23'b11111111111111111111111;
        end
    end
endmodule

// ClockDivider24 - led
module ClockDivider24 (clk, rst_n, newclk);
    input clk, rst_n;
    output reg newclk;

    reg [24-1:0] ctr_co;
    always @(posedge clk) begin
        if(rst_n) begin
            ctr_co <= 24'b0;
        end
        else begin
            ctr_co <= ctr_co + 24'b1;
        end 
    end
   always @(posedge clk) begin
        if(rst_n) begin
            newclk <=1'b0;
        end
        else begin
            newclk <= ctr_co == 24'b111111111111111111111111;
        end
    end
endmodule

module ClockDivider17 (clk, rst_n, display_clk);
    input clk, rst_n;
    output reg display_clk;

    reg [17:0] ctr_co;
    always @(posedge clk) begin
        if(rst_n) begin
            ctr_co <= 1'b0;
        end
        else begin
            ctr_co <= ctr_co+1'b1;
        end 
    end
    always @(posedge clk) begin
        if(rst_n) begin
            display_clk <=1'b0;
        end
        else begin
            display_clk <= ctr_co== 18'b111111111111111111;
        end
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

