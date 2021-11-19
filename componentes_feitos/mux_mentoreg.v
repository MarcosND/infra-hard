module mux_MENtoReg (
    input wire [3:0] MENtoReg,
    input wire [31:0] ALU_out,
    input wire [31:0] LS_out,
    input wire [31:0] HI_out,
    input wire [31:0] LO_out,
    input wire [31:0] Sign_extend_1to32_out,
    input wire [31:0] result,
    input wire [31:0] Shift_Left_16_out,
    input wire [31:0] Shift_Reg_out,
    output reg [31:0] MENtoReg_out
    
);

always @(*) begin
    case(MENtoReg)
        4'b0000:
            MENtoReg_out <= HI_out;
        4'b0001:
            MENtoReg_out <= LO_out;
        4'b0010:
            MENtoReg_out <= result;
        4'b0011:
            MENtoReg_out <= LS_out;
        4'b0100:
            MENtoReg_out <= Shift_Left_16_out;
        4'b0101:
            MENtoReg_out <= ALU_out;
        4'b0110:
            MENtoReg_out <= Shift_Reg_out;
        4'b0111:
            MENtoReg_out <= Sign_extend_1to32_out;
        4'b1000:
            MENtoReg_out <= 32'd227;
    endcase
end

endmodule