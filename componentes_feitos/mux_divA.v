module mux_divA (
    input  wire div_selector,
    input  wire [31:0] A_out,
    input  wire [31:0] MEM_out,
    output wire [31:0] MEM_Div_A_out
);

    assign MEM_Div_A_out = (div_selector) ? MEM_out : A_out;
    
endmodule