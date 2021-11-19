module mux_ulaA(
    input wire seletor,
    input wire [31:0] PC_info,
    input wire [31:0] Reg_A_info,
    output wire [31:0] mux_ulaA_out
);

    assign mux_ulaA_out = (seletor) ? Reg_A_info : PC_info;

endmodule