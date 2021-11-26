module shift_left_16(
    input wire [15:0] ShiftLeft16_input,
    output wire [31:0] Shifleft16_output
);
    wire [31:0] help;

    assign help = {{16{1'b0}}, ShiftLeft16_input};
    assign Shifleft16_output = help << 16; 

endmodule