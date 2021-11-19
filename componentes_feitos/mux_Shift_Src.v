module mux_Shift_Src (
    input wire [1:0] Shift_Src,
    input wire [31:0] Reg_A_info,
    input wire [31:0] Reg_B_info,
    output wire [31:0] Shift_Src_out
);
always @(*) begin
        case (Shift_Src)
            2'b00:
                Shift_Src_out <= Reg_A_info;
            2'b01:
                 Shift_Src_out <= Reg_B_info;
        endcase
end   
endmodule