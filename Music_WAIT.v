module Music_WAIT (
	input [32-1:0] beat_cnt,	
	output reg [5-1:0] note
);

    parameter [5-1:0] S = 5'd0;

    parameter [5-1:0] F4 = 5'd4;
    parameter [5-1:0] A4 = 5'd6;

    always @(*) begin
        if(beat_cnt == 32'b0)
            note = S;
        else begin
            if(beat_cnt[0] == 1'b0)
                note = F4;
            else
                note = A4;
        end
    end

endmodule