module mux_Hi (
    input wire  seletor, 
    input wire [31:0] Hi0_out,
    input wire [31:0] Hi1_out,
    output reg [31:0] result
);
always @(*) begin 
        case(seletor)
            2'b00:
                result <= Hi0_out;
            2'b01:
                result <= Hi1_out;                        
        endcase
end    
endmodule