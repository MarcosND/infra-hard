module mux_divA (
    input  wire div_selector,
    input  wire [31:0] AB_out,
    input  wire [31:0] MEM_out,
    output wire [31:0] MEM_Div_out
);

    assign MEM_Div_out = (div_selector) ? MEM_out : AB_out;
    
endmodule