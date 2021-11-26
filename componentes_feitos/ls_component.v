module ls_component(
    input wire [1:0] LScontroler,
    input wire [31:0] MDR_out,
    output reg [31:0] ls_component_out
);

always @(*) begin
        case (lscontroler)
            2'b00: 
                ls_component_out <= MDR_out;
            2'b10:
                ls_component_out <= {16'd0, MDR_out[15:0]};
            2'b01:
                 ls_component_out <= {24'd0, MDR_out[7:0]};
        endcase
    
end
endmodule