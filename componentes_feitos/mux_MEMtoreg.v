module mux_MEMtoReg (
    input wire [3:0] MEMtoReg,
    input wire [31:0] ALU_out,
    input wire [31:0] LS_out,
    input wire [31:0] HI_out,
    input wire [31:0] LO_out,
    input wire [31:0] Sign_extend_1to32_out,
    input wire [31:0] result,
    input wire [31:0] Shift_Left_16_out,
    input wire [31:0] Shift_Reg_out,
    output reg [31:0] MEMtoReg_out
    
);

always @(*) begin
    case(MEMtoReg)
        4'b0000:
            MEMtoReg_out <= HI_out;
        4'b0001:
            MEMtoReg_out <= LO_out;
        4'b0010:
            MEMtoReg_out <= result;
        4'b0011:
            MEMtoReg_out <= LS_out;
        4'b0100:
            MEMtoReg_out <= Shift_Left_16_out;
        4'b0101:
            MEMtoReg_out <= ALU_out;
        4'b0110:
            MEMtoReg_out <= Shift_Reg_out;
        4'b0111:
            MEMtoReg_out <= Sign_extend_1to32_out;
        4'b1000:
            MEMtoReg_out <= 32'd227;
    endcase
end

endmodule