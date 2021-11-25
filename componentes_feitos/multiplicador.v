module multiplicador(
    input wire [31:0] outA,
    input wire [31:0] outB,
    input wire clock,
    input wire reset,
    input wire divOrMult,
    output reg [31:0] lo,
    output reg [31:0] hi
);

integer index;
reg [63:0] subtracao;
reg [63:0] produto;
reg [63:0] soma;

always @(posedge clock) begin
  if(reset == 1'b1) begin 
    subtracao = 64'b0;
    soma = 64'b0;
    produto = 64'b0;
    lo = 32'b0;
    hi = 32'b0;
  end
  else if (divOrMult == 0) begin
    produto = {32'b0, outB, 1'b0};
    subtracao = {outA, 33'b0, 1'b0};
    soma = {outA, 33'b0, 1'b0};
  end
  for (index = 0; index < 32; index = index + 1) begin
    if(produto[62] == 0 && produto[63] == 1) begin
        produto = produto + soma;
    end
    else if(produto[62] == 1 && produto[63]== 0) begin
      produto = produto + subtracao;
    end
    produto = produto >> 1;
  end
  hi = produto[64:33];
  lo = produto[32:1];
end

endmodule