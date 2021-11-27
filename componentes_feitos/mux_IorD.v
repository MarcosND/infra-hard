module mux_IorD (
    input wire [2:0] IorD,
    input wire [31:0] PC_out,
    input wire [31:0] Expction_out,
    input wire [31:0] ALU_out,
    input wire [31:0] result,
    input wire [31:0] B_out,
    output reg  [31:0] IorD_out
);
always @(*) begin
        case (IorD)
            3'b000:
                IorD_out <= PC_out;
            3'b001:
                IorD_out <= Expction_out;
            3'b010:
                IorD_out <= ALU_out;
            3'b011:
                IorD_out <= result;
            3'b100:
                IorD_out <= B_out;    
        endcase
end
endmodule