module sign_extend_1to32 (
    input wire LT_out,
    output wire [31:0] resultado
);
    assign resultado = {{32{1'b0}}, LT_out};
endmodule