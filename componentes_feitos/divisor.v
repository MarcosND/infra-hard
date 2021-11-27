module divisor (
    input wire clock,
		input wire reset,
		input wire DIV_START,
    input wire [31:0] A,
		input wire [31:0] B,
		
    output reg DIV_END,
		output reg [31:0] HI,
		output reg [31:0] LO,
		output reg DIV_0
	);

  integer contador = 32;
	reg [31:0] quociente;
	reg [31:0] resto;
	reg [31:0] divisor; 
	assign DIV_0 = !B;
	wire [32:0] subtraido = {resto[30:0], quociente[31]} - divisor; 

	always @(posedge clock) begin
		
    if (reset == 1'd1) 
    
    begin
			
			resto = 32'b0;
		  contador = 32;
			DIV_END = 1'd0;
			divisor = 32'b0;
			HI = 32'd0;
			LO = 32'd0;
			quociente = 65'b0;

		end 
    
    else begin

			if (DIV_START == 1'b1) 
      
      begin
				divisor = B;
				quociente = A;

				resto = 32'b0;
			contador = 32;
				DIV_END = 1'd0;
				HI = 32'd0;
				LO = 32'd0;
			end 
      
      else begin

				if (subtraido[32] == 0) begin
					resto = subtraido[31:0];
					quociente = {quociente[30:0], 1'b1};
				end 
        
        else 
        
        begin
					resto = {resto[30:0], quociente[31]};
					quociente = {quociente[30:0], 1'b0};
				end

				if (contador > 0) 
        
        
        begin
				  contador = contador -1;
				end

				if (contador == 0) 
        
        begin
					HI = resto;
				contador = -1;
					LO = quociente;
					DIV_END = 1'b1;
				end

			end
		end
	end
endmodule