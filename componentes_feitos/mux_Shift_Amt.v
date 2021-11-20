module mux_Shift_Amt (
    input wire [1:0] Shift_Amt,
    input wire [31:0] Reg_B_info,
    input wire [15:0] Imediato,
    input wire [31:0] MDR_out,
    output reg [4:0] Shift_Amt_out
);
always @(*) begin
        case (Shift_Amt)
            2'b00:
                Shift_Amt_out <= Reg_B_info;
            2'b01:
                Shift_Amt_out <= Imediato;
            2'b10:
                Shift_Amt_out <= MDR_out;
        endcase
end    
endmodule