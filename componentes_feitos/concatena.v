module concatena(
    input wire conc,
    input wire [27:0] inp_1;
    input wire [31:0] inp_2;
    output wire [31:0] conc_out;
)

    wire [3:0] a;
    assign a = inp_2[3:0];
    assign conc_aut = {inp_1, a}
endmodule
