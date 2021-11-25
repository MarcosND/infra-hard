module divisor(
    input wire clock,
    input wire multOrDiv,
    input wire reset,
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [31:0] lo,
    output reg [31:0] hi,
    output reg div0
);

reg [31:0] divisor;
reg [31:0] dividendo;
reg sinal;
integer index;
reg finalizado;

initial begin
  finalizado = 0;
  div0 = 0;
  sinal = 0;
end

always @(posedge clock) begin
    if(reset == 1'b1) begin
      div0 = 1'b0;
      finalizado = 1'b0;
      dividendo = 32'b0; 
      divisor = 32'b0; 
      lo = 32'b0; 
      hi = 32'b0; 
    end
    else if (B == 32'b0 && multOrDiv == 1)begin
      div0 = 1'b1;
    end
    else if(multOrDiv == 1) begin
      divisor = B;
      dividendo = A;
      if(divisor[31] == 1'b1) begin
        divisor = ~divisor + 1;
        if(sinal == 0) begin
          sinal = 1;
        end
      end
      if(dividendo[31] == 1'b1) begin
        dividendo = ~dividendo + 1;
        sinal = 1;
      end
    end
    else if(final == 0) begin
      for (index = 1; dividendo >= divisor; index= index + 1) begin
      dividendo = dividendo - divisor;
      lo = index;
    end
       if(sinal == 1) begin
         lo = ~lo + 1;
       end
       hi = dividendo;
       final = 1;
end
endmodule