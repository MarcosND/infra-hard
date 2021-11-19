module ctrl_unit {
    
    input wire  clk,
    input wire  reset,
    


    //fios de controle 
    output reg          PC_write,
    output reg          MEM_write,    
    output reg          IR_write,
    output reg          RB_w,
    output reg          AB_w,
    output reg          Regwrite,
    output reg [1:0]    AluSrcA,
    output reg [1:0]    AluSrcB, 
                    
    output reg      [2:0] Alu_control,
    output reg      [3:0] MEMtoReg, 
    output reg      [2:0] PCsource ,
    output reg      [1:0] Exception,
    output reg      [2:0] IorD,

    
    
    //controladores dos muxes
    output reg      M_writeReg,
    output reg     mux_ulaA,
    output reg      M_ULAB,
    
    //Controlador especial para instrução reset
    output reg      rst_out,
    
    
    //Flags
    input wire      Overflow,
    input wire      Ng,
    input wire      Zr,
    input wire      Eq,
    input wire      Gt,
    input wire      Lt,
    
    //Fios de Dados
   input wire [5:0] OPCODE,
   input wire [4:0] RS,
   input wire [4:0] RT,
   input wire [15:0] OFFSET,
   input wire [4:0] WriteReg_in,
   input wire [31:0] ULA_out,
   input wire [31:0] PC_out,
   input wire [31:0] MEM_out,
   input wire [31:0] regA_out,
   input wire [31:0] regB_out,
   input wire [31:0] B_out,
   input wire [31:0] A_out,
   input wire [31:0] SE16_out,
   input wire [31:0] AluA_out,
   input wire [31:0] AluB_out,
   input wire [2:0] PCsource,
   input wire [31:0] Shift_left_26to28_out,
   input wire [31:0] EPC_out,
   input wire [31:0] result,
   input wire [31:0] ALU_out,
   input wire [31:0] PCsource_out,
   input wire [31:0] LS_out,
   input wire [31:0] HI_out,
   input wire [31:0] LO_out,
   input wire [31:0] Sign_extend_1to32_out,
   input wire [31:0] Shift_Left_16_out,
   input wire [31:0] Shift_Reg_out,
   input wire [31:0] MEMtoReg_out,
   input wire [31:0] Excepction_out,
   input wire [31:0] Expction_out,
   input wire [31:0] IorD_out,
    


    

    


};   

//variaveis usadas

reg[1:0] STATE;
reg[2:0] COUNTER;

// Parametros (Constantes)

    //Estados principais da maquina
    parameter ST_FETCH_1 = 3'b000 ;
    parameter ST_FETCH_2 = 3'b001 ;
    parameter DECODE = 3'b010;
    parameter ST_ADD_1 = 3'b011;
    parameter ST_ADD_2 = 3'b100;
    parameter ST_RESET = 3'b101 ;    
    parameter ST_CLOSE_WRITE = 3'b110

    //Opcode codes as aliases
    parameter  ADD = 6'b000000 ;
    parameter  ADDI = 6'b001000 ;
    parameter  RESET = 6'b111111 ;


initial begin
  //reset inicial na maquina
  rst_out = 1'b1
end

always @(posedge clk) begin
        if (reset)begin
          
       

        //Define os sinais, zerando eles
        PC_write            = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0;
        RB_w                = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b1;
        AluSrcA             = 2'b00;
        AluSrcB             = 2'b00;
        [2:0] Alu_control   = 2'b0;
        [3:0] MEMtoReg      = 4'b1000;
        [2:0] PCsource      = 2'b0;
        [1:0] Exception     = 1'b0;
        [2:0] IorD          = 2'b0;
        
        
         end

        STATE = ST_FETCH_1:
    

    
    
    else begin
        case (STATE)
            ST_FETCH_1: begin
             //Define os sinais
        PC_write            = 1'b0; 
        MEM_write           = 1'b0;
        IR_write            = 1'b0;
        RB_w                = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b0; // 
        AluSrcA             = 2'b00;
        AluSrcB             = 2'b01; // 
        [2:0] Alu_control   = 2'b0;
        [3:0] MEMtoReg      = 4'b0000; //
        [2:0] PCsource      = 2'b0;
        [1:0] Exception     = 1'b0;
        [2:0] IorD          = 2'b0;   
                
        STATE = ST_FETCH_2;   
            
        end
            
        ST_FETCH_2: begin
           
              //Define os sinais
        PC_write            = 1'b1; // 
        MEM_write           = 1'b0;
        IR_write            = 1'b0;
        RB_w                = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 2'b00;
        AluSrcB             = 2'b01; 
        [2:0] Alu_control   = 2'b0;
        [3:0] MEMtoReg      = 4'b0000; 
        [2:0] PCsource      = 2'b10;
        [1:0] Exception     = 1'b0;
        [2:0] IorD          = 2'b0; 
        
        STATE = ST_DECODE;
        
        end
            ST_DECODE: begin
             //Define os sinais
        PC_write            = 1'b1;  
        MEM_write           = 1'b0;
        IR_write            = 1'b1; //
        RB_w                = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        [1:0]AluSrcA        = 2'b00; //
        [1:0]AluSrcB        = 2'b10; //
        [2:0] Alu_control   = 2'b01;
        [3:0] MEMtoReg      = 4'b0000; 
        [2:0] PCsource      = 2'b10;
        [1:0] Exception     = 1'b0;
        [2:0] IorD          = 2'b0; 
        
        
            
        end
            ST_ADD_1: begin
             //Define os sinais
        PC_write            = 1'b1;  
        MEM_write           = 1'b0;
        IR_write            = 1'b1; 
        RB_w                = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        [1:0]AluSrcA        = 2'b01; //
        [1:0]AluSrcB        = 2'b00; //
        [2:0] Alu_control   = 2'b01;
        [3:0] MEMtoReg      = 4'b0000; 
        [2:0] PCsource      = 2'b10;
        [1:0] Exception     = 1'b0;
        [2:0] IorD          = 2'b0; 
            
                STATE = ST_ADD_2
        end
            ST_ADD_2: begin
              //Define os sinais
        PC_write            = 1'b1;  
        MEM_write           = 1'b0;
        IR_write            = 1'b1; 
        RB_w                = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        [1:0]AluSrcA        = 2'b01; 
        [1:0]AluSrcB        = 2'b00; 
        [2:0] Alu_control   = 2'b01;
        [3:0] MEMtoReg      = 4'b0010; //
        [2:0] PCsource      = 2'b10;
        [1:0] Exception     = 1'b0;
        [2:0] IorD          = 2'b0; 
        

        STATE = CLOSE_WRITE;

            end
        ST_CLOSE_WRITE: begin
               //Define os sinais, vai zerar tudo
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        RB_w                = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        [1:0]AluSrcA        = 2'b01; 
        [1:0]AluSrcB        = 2'b00; 
        [2:0] Alu_control   = 2'b01;
        [3:0] MEMtoReg      = 4'b0000; 
        [2:0] PCsource      = 2'b00;
        [1:0] Exception     = 1'b0;
        [2:0] IorD          = 2'b0; 
        
        
        

        end

        

            
            
            
            
            
            
            
            
                


            

        endcase     
    
    
    end
    
end





endmodule