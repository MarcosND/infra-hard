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
        0:
            mentoreg_out <= HI_out;
        1:
            mentoreg_out <= LO_out;
        2:
            mentoreg_out <= result;
        3:
            mentoreg_out <= LS_out;
        4:
            mentoreg_out <= Shift_Left_16_out;
        5:
            mentoreg_out <= ALU_out;
        6:
            mentoreg_out <= Shift_Reg_out;
        7:
            mentoreg_out <= Sign_extend_1to32_out;
        8:
            mentoreg_out <= 32'd227;
    endcase
end

endmodule