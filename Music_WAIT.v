module Music_WAIT (
	input [7:0] beat_cnt,	
	output reg [5-1:0] note
);

    reg [5-1:0] next_note;

    parameter [5-1:0] S = 5'd0;

    parameter [5-1:0] F4 = 5'd4;
    parameter [5-1:0] A4 = 5'd6;

    always @(*) begin
        if(beat_cnt == 7'b0)
            note = S;
        else begin
            if(beat_cnt % 2 == 0)
                note = A4;
            else
                note = F4;
        end
    end

endmodule