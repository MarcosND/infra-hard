module mux_Shift_Src (
    input wire Shift_Src,
    input wire [31:0] Reg_A_info,
    input wire [31:0] Reg_B_info,
    output reg  [31:0] Shift_Src_out
);
always @(*) begin
        case (Shift_Src)
            1'b0:
                Shift_Src_out <= Reg_A_info;
            1'b1:
                 Shift_Src_out <= Reg_B_info;
        endcase
end   
endmodule