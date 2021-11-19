module mux_regDst(
    input wire [1:0] seletor,
    input wire [4:0] registerRT,
    input wire  [15:0] instruction15_11,
    output wire [4:0] mux_regDst_out
)

assign mux_regDst_out = (seletor == 2'b00) ? RegisterRT : (seletor == 2'b10) ? 5'd29: 
                      (seletor == 2'b01) ? instruction15_11[15:11] : (seletor == 2'b11) ? 5'd31;


endmodule
