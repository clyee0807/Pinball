module Music_GET_SCORE (
	input [32-1:0] beat_cnt,	
	output reg [5-1:0] note
);

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

    always @(*) begin
        case(beat_cnt)
            5'd0: note = S;
            5'd1: note = C4;
            5'd2: note = D4;
            5'd3: note = E4;
            5'd4: note = F4;
            5'd5: note = G4;
            5'd6: note = A4;
            5'd7: note = B4;
            5'd8: note = C5;
            5'd9: note = D5;
            5'd10: note = E5;
            5'd11: note = F5;
            5'd12: note = G5;
            5'd13: note = A5;
            5'd14: note = B5;
            5'd15: note = C6;
            default: note = S;
        endcase
    end

endmodule