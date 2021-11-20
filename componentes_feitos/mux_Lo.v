module mux_Lo (
    input wire [1:0] seletor, //Não tenho certeza de são 2 bits
    input wire [31:0] Lo0_out,
    input wire [31:0] Lo1_out,
    output reg  [31:0] result
);
always @(*) begin
        case (seletor)
            2'b00:
                result <= Lo0_out;
            2'b01:
                result <= Lo1_out;
        endcase
end    
endmodule