module Music_NO_SCORE (
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

    always @(*) begin
        case(beat_cnt)
            5'd0: note = S;
            5'd1: note = C5;
            5'd2: note = B4;
            5'd3: note = A4;
            5'd4: note = G4;
            5'd5: note = F4;
            5'd6: note = E4;
            5'd7: note = D4;
            5'd8: note = C4;
            default: note = S;
        endcase
    end

endmodule