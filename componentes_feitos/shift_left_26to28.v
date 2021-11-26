module shift_left_26to28(
    input wire [25:0] entrada,
    output wire [27:0] saida
);

    assign saida = {entrada, 2'b00};

endmodule