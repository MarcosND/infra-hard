module mux_mentoreg (
    input wire [3:0] mentoreg,
    input wire [31:0] ALU_out,
    input wire [31:0] LS_out,
    input wire [31:0] HI_out,
    input wire [31:0] LO_out,
    input wire [31:0] Sign_extend_1to32_out,
    input wire [31:0] result,
    input wire [31:0] Shift_Left_16_out,
    input wire [31:0] Shift_Reg_out,
    output reg [31:0] mentoreg_out
    
);

always @(*) begin
    case(mentoreg)
        4'b0000:
            mentoreg_out <= HI_out;
        4'b0001:
            mentoreg_out <= LO_out;
        4'b0010:
            mentoreg_out <= result;
        4'b0011:
            mentoreg_out <= LS_out;
        4'b0100:
            mentoreg_out <= Shift_Left_16_out;
        4'b0101:
            mentoreg_out <= ALU_out;
        4'b0110:
            mentoreg_out <= Shift_Reg_out;
        4'b0111:
            mentoreg_out <= Sign_extend_1to32_out;
        4'b1000:
            mentoreg_out <= 32'd227;
    endcase
end

endmodule