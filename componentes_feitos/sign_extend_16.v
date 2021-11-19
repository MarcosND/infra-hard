module sign_extend_16(
    input wire [15:0] Imediato,
    output wire [31:0] saida
);

    assign saida = (Imediato[15]) ? {{16{1'b1}}, Imediato} : {{16{1'b0}}, Imediato};

endmodule