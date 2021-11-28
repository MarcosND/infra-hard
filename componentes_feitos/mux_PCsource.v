module mux_PCsource (
    input wire [2:0] PCsource, 
    input wire [31:0] Shift_left_26to28_out,
    input wire [31:0] EPC_out,
    input wire [31:0] result,
    input wire [31:0] ALU_out,
    input wire [31:0] SE8_32_out,
    output reg [31:0] PCsource_out
    
);

always @(*) begin
    case(PCsource)
        3'b000:
            PCsource_out <= Shift_left_26to28_out;
        3'b001:
            PCsource_out <= EPC_out;
        3'b010:
            PCsource_out <= result;
        3'b011:
            PCsource_out <= ALU_out;
        3'b100:
            PCsource_out <= SE8_32_out;
    endcase
end
endmodule