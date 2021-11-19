module mux_ulaB(
    input wire [1:0] seletor,
    input wire [31:0] Reg_B_info,
    input wire  [31:0] sigLef,
    input wire [31:0] sigEx,
    output wire [31:0] mux_ulaB_out
)

assign mux_ulaB_out = (seletor == 2'b00) ? Reg_B_info: (seletor == 2'b10) ? sigLef: 
                      (seletor == 2'b01) ? 32'd4: (seletor == 2'b11) ? sigLef:

endmodule