module audio(clk, reset, state, match, AIN, GAIN, SHUTDOWN);
    input clk;
    input reset;
    input [3-1:0] state;
    input match;
    output AIN, GAIN, SHUTDOWN;

    reg [32-1:0] notes_speed;   //一秒幾note
    parameter DUTY = 10'd512;
    wire beatclk;
    wire [32-1:0] beat_count;
    wire [32-1:0] note_freq;

    reg whether_get_score, next_whether_get_score;

    assign GAIN = 1'd1;
    assign SHUTDOWN = 1'd1;

    parameter RESET = 3'd0;
    parameter WAIT = 3'd1;
    parameter START = 3'd2;
    parameter GET = 3'd3;
    parameter OVER = 3'd4;

    PWM_gen Beat_speed_gen(.clk(clk), .reset(reset), .freq(notes_speed), .duty(DUTY), .PWM(beatclk));

    beat_counter bc(.clk(beatclk), .reset(reset), .state(state), .beat_count(beat_count));

    music_control mc(.clk(clk), .reset(reset), .state(state), .whether_get_score(whether_get_score), .beat_count(beat_count), .tone(note_freq));

    PWM_gen Tone_audio_gen(.clk(clk), .reset(reset), .freq(note_freq), .duty(DUTY), .PWM(AIN));

    //notes_speed
    always @(*) begin
        case(state)
            WAIT: notes_speed = 32'd8;
            GET: notes_speed = 32'd16;
            default: notes_speed = 32'd1;
        endcase
    end    

    always @(posedge clk) begin
        whether_get_score <= next_whether_get_score;
    end

    always @(*) begin
        case(state) 
            START, GET: begin
                if(match == 1'b1)
                    next_whether_get_score = 1'b1;
                else 
                    next_whether_get_score = whether_get_score;
            end
            default:
                next_whether_get_score = 1'b0;
        endcase

    end

endmodule

module beat_counter(
    input clk,
    input reset,
    input [3-1:0] state,
    output reg [32-1:0] beat_count
);

    parameter RESET = 3'd0;
    parameter WAIT = 3'd1;
    parameter START = 3'd2;
    parameter GET = 3'd3;
    parameter OVER = 3'd4;

    reg [32-1:0] next_beat_count;

    always @(posedge clk) begin
        if(reset == 1'b1)
            beat_count <= 32'b0;
        else begin
            beat_count <= next_beat_count;
        end
    end

    always @(*) begin
        case(state)
            WAIT, GET: next_beat_count = beat_count + 32'b1;
            default: next_beat_count = 32'b0;
        endcase
    end

endmodule

module music_control(
    input clk,
    input reset,
    input [3-1:0] state,
    input whether_get_score,
    input [32-1:0] beat_count,
    output reg [32-1:0] tone
);
    parameter RESET = 3'd0;
    parameter WAIT = 3'd1;
    parameter START = 3'd2;
    parameter GET = 3'd3;
    parameter OVER = 3'd4;
    
    parameter [5-1:0] S = 5'd0;

    parameter [5-1:0] C4 = 5'd1;
    parameter [5-1:0] D4 = 5'd2;
    parameter [5-1:0] E4 = 5'd3;
    parameter [5-1:0] F4 = 5'd4;
    parameter [5-1:0] G4 = 5'd5;
    parameter [5-1:0] A4 = 5'd6;
    parameter [5-1:0] B4 = 5'd7;

    parameter [5-1:0] C5 = 5'd8;
    parameter [5-1:0] D5 = 5'd9;
    parameter [5-1:0] E5 = 5'd10;
    parameter [5-1:0] F5 = 5'd11;
    parameter [5-1:0] G5 = 5'd12;
    parameter [5-1:0] A5 = 5'd13;
    parameter [5-1:0] B5 = 5'd14;

    parameter [5-1:0] C6 = 5'd15;
    parameter [5-1:0] D6 = 5'd16;
    parameter [5-1:0] E6 = 5'd17;
    parameter [5-1:0] F6 = 5'd18;
    parameter [5-1:0] G6 = 5'd19;
    parameter [5-1:0] A6 = 5'd20;
    parameter [5-1:0] B6 = 5'd21;

    parameter [5-1:0] C7 = 5'd22;
    parameter [5-1:0] D7 = 5'd23;
    parameter [5-1:0] E7 = 5'd24;
    parameter [5-1:0] F7 = 5'd25;
    parameter [5-1:0] G7 = 5'd26;
    parameter [5-1:0] A7 = 5'd27;
    parameter [5-1:0] B7 = 5'd28;

    parameter [5-1:0] C8 = 5'd29;

    reg [5-1:0] note_name;
    wire [5-1:0] wait_note, get_score_note, no_score_note;

    Music_WAIT mw(.beat_cnt(beat_count), .note(wait_note));
    Music_GET_SCORE mg(.beat_cnt(beat_count), .note(get_score_note));
    Music_NO_SCORE mn(.beat_cnt(beat_count), .note(no_score_note));

    always @(*) begin
        case(state)
            WAIT: note_name = wait_note;
            GET: begin
                if(whether_get_score == 1'b1)
                    note_name = get_score_note;
                else
                    note_name = no_score_note;
            end
            
            default: note_name = S;
        endcase
    end

    always @(*) begin
        case(note_name)
            S: tone = 32'd20000;

            C4: tone = 32'd262;
            D4: tone = 32'd294;
            E4: tone = 32'd330;
            F4: tone = 32'd349;
            G4: tone = 32'd392;
            A4: tone = 32'd440;
            B4: tone = 32'd494;

            C5: tone = 32'd262 << 1;
            D5: tone = 32'd294 << 1;
            E5: tone = 32'd330 << 1;
            F5: tone = 32'd349 << 1;
            G5: tone = 32'd392 << 1;
            A5: tone = 32'd440 << 1;
            B5: tone = 32'd494 << 1;

            C6: tone = 32'd262 << 2;
            D6: tone = 32'd294 << 2;
            E6: tone = 32'd330 << 2;
            F6: tone = 32'd349 << 2;
            G6: tone = 32'd392 << 2;
            A6: tone = 32'd440 << 2;
            B6: tone = 32'd494 << 2;

            C7: tone = 32'd262 << 3;
            D7: tone = 32'd294 << 3;
            E7: tone = 32'd330 << 3;
            F7: tone = 32'd349 << 3;
            G7: tone = 32'd392 << 3;
            A7: tone = 32'd440 << 3;
            B7: tone = 32'd494 << 3;

            C8: tone = 32'd262 << 4;

            default: tone = 32'd20000;
        endcase
    end

endmodule

module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);

wire [31:0] count_max = 100_000_000 / freq;
wire [31:0] count_duty = count_max * duty / 1024;
reg [31:0] count;
    
always @(posedge clk, posedge reset) begin
    if (reset) begin
        count <= 0;
        PWM <= 0;
    end else if (count < count_max) begin
        count <= count + 1;
		if(count < count_duty)
            PWM <= 1;
        else
            PWM <= 0;
    end else begin
        count <= 0;
        PWM <= 0;
    end
end

endmodule
