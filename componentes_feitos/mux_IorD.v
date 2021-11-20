module mux_IorD (
    input wire [1:0] IorD,
    input wire [31:0] PC_out,
    input wire [31:0] Expction_out,
    input wire [31:0] ALU_out,
    input wire [31:0] result,
    output reg  [31:0] IorD_out
);
always @(*) begin
        case (IorD)
            2'b00:
                IorD_out <= PC_out;
            2'b01:
                IorD_out <= Expction_out;
            2'b10:
                IorD_out <= ALU_out;
            2'b11:
                IorD_out <= result;    
        endcase
end
endmodule