module mux_regDst(
    input wire [1:0] seletor,
    input wire [31:0] Register,
    input wire  [31:0] instruction15_11,
    output wire [31:0] mux_regDst_out
)

assign mux_regDst_out = (seletor == 2'b00) ? Register : (seletor == 2'b10) ? 32'd29: 
                      (seletor == 2'b01) ? instruction15_11 : (seletor == 2'b11) ? 32'd31;


endmodule
