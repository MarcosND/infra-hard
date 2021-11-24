module ss_component(
    input wire [31:0] dataRegOut,
    input wire [31:0] b_out,
    input wire [0:1] controleSS,
    output reg [31:0] ss_out
);


    primeiro_caso = 2'b00;
    segundo_caso = 2'b01;
    terceiro_caso = 2'b10;

    always @(*)
        begin
            if(controleSS = primeiro_caso) begin
                ss_out = b_out;
            end
            if(controleSS = segundo_caso) begin
                ss_out = {dataRegOut[31:8], b_out[7:0]};
            end
            if(controleSS = terceiro_caso) begin
                ss_out = {dataRegOut[31:16], b_out[15:0]};
            end
        end

endmodule