module mux_CTRL_Exception (
    input wire [1:0] Exception,
    output wire [31:0] Expction_out
);
always @(*) begin
    case(Exception)
        2'b00:
            Expction_out <= 32'd253;  
        2'b01:
            Expction_out <= 32'd254;
        2'b10:
            Expction_out <= 32'd255;    
    endcase
end
endmodule