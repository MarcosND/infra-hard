module sign_extend_8to32 (
    input wire [31:0] MD_out,
    output wire [31:0] resultado
);
    assign resultado = {{24{1'b0}}, MD_out[7:0]};
endmodule