module mux_PCsource (
    input wire [1:0] PCsource, 
    input wire [31:0] Shift_left_26to28_out,
    input wire [31:0] EPC_out,
    input wire [31:0] result,
    input wire [31:0] ALU_out,
    output reg [31:0] PCsource_out
    
);

always @(*) begin
    case(PCsource)
        2'b00:
            PCsource_out <= Shift_left_26to28_out;
        2'b01:
            PCsource_out <= EPC_out;
        2'b10:
            PCsource_out <= result;
        2'b11:
            PCsource_out <= ALU_out;
        

    endcase
end
endmodule