module multiplicador(
    input wire clock,
    input wire reset,
    input wire mult_start,
    input wire [31:0] outA,
    input wire [31:0] outB,
    output reg [31:0] hi,
    output reg [31:0] lo,
    output reg ciclos_end
);

  reg signed [31:0] comparador;
  reg signed [64:0] soma;
  reg signed [64:0] subtracao;

  integer cont = -2;
  reg signed [64:0] produto;

  always @(posedge clock) begin
      if(reset == 1'b1) begin
        subtracao = 65'd0;
        hi = 32'd0;
        lo = 32'd0;
        cont = -2;
        soma = 65'd0;
        ciclos_end = 1'b0;
        comparador = 32'd0;
        produto = 65'd0;
      end else begin

        if (mult_start == 1'b1) begin
         ciclos_end = 1'b0;
         soma = {outB, 33'd0};
         comparador = ~outB + 1'd1;
         cont = 32;
         subtracao = {comparador, 33'd0};
         produto = {32'd0, outA, 1'd0};
        end else begin
          case(produto[1:0])
              2'b01: begin
                produto = produto + soma;
              end
              2'b10: begin
                produto = produto + subtracao;
              end
          endcase

          produto = produto >>> 1;

          if (cont > 0) begin
            cont = cont -1;
          end

          if(cont == 0) begin
            hi = produto[64:33];
            lo = produto[32:1];
            ciclos_end = 1'b1;
            produto = 65'd0;
            comparador = 32'd0;
            subtracao = 65'd0;
            soma = 65'd0;
            cont = -1;
          end
        end
      end
  end

endmodule