module ctrl_unit {
    
    input wire  clk,
    input wire  reset,
    


    //fios de controle
    output reg      PC_write,
    output reg     MEM_write,    
    output reg      IR_write,
    output reg      RB_w,
    output reg      AB_w,
    output reg      Regwrite,
    output reg      AluSrcA,
    output reg      AluSrcB,
                    
    output reg  [2:0]    Alu_control,
    
    
    
    //controladores dos muxes
    output reg      M_writeReg,
    output reg     mux_ulaA,
    output reg      M_ULAB,
    
    //Controlador especial para instrução reset
    output reg      rst_out
    
    
    //Flags
    input wire      Overflow,
    input wire      Ng,
    input wire      Zr,
    input wire      Eq,
    input wire      Gt,
    input wire      Lt,
    
    //Fios de Dados
    input wire [5:0]        OPCODE,
    input wire [4:0]        RS,
    input wire [4:0]        RT,
    input wire [15:0]       OFFSET,
    input wire [4:0]        WriteReg_in
    input wire [31:0]       ULA_out,
    input wire [31:0]       PC_out,
    input wire [31:0]       MEM_out,
    input wire [31:0]       regA_out,
    input wire [31:0]       regB_out,
    input wire [31:0]       B_out,
    input wire [31:0]       A_out,
    input wire [31:0]       SE16_out,
    input wire [31:0]       AluA_out,
    input wire [31:0]       AluB_out,
    


    

    


};   

//variaveis usadas

reg[1:0] STATE;
reg[2:0] COUNTER;

// Parametros (Constantes)

    //Estados principais da maquina
    parameter $T_COMMON = 2'b00 ;
    parameter ST_ADD = 2'b01;
    parameter ST_ADDI = 2'b10;
    parameter ST_RESET = 2'b11 ;

    //Opcode codes as aliases
    parameter  ADD = 6'b000000 ;
    parameter  ADDI = 6'b001000 ;
    parameter  RESET = 6'b111111 ;


initial begin
  //reset inicial na maquina
  rst_out = 1'b1
end

always @(posedge clk) begin
    if (reset == 1'b1) begin
    //resolve problema do reset poder ter vindo de 2 lugares: apertado o botão e entrado no reset
      
      if (STATE != ST_RESET)begin
        
        STATE = ST_RESET;

        //Define os sinais
        PC_write        =   1'b0;
       MEM_write       =   1'b0;
        riteIR_write        =   1'b0;
        RB_w        =   1'b0;
        AB_w        =   1'b0;
        Alu_control       =   3'b000;
        M_writeReg      =   1'b0;
       mux_ulaA      =   1'b0;
        M_ULAB      =   2'b00;
        rst_out     =   1'b1; //

        // define o contador para a próxima operação
        COUNTER = 3'b000;
      end
        else begin
         
         STATE = ST_COMMON;
         //Define os sinais
        PC_write        =   1'b0;
       MEM_write       =   1'b0;
        riteIR_write        =   1'b0;
        RB_w        =   1'b0;
        AB_w        =   1'b0;
        Alu_control       =   3'b000;
        M_writeReg      =   1'b0;
       mux_ulaA      =   1'b0;
        M_ULAB      =   2'b00;
        rst_out     =   1'b0; // 

        // define o contador para a próxima operação
        COUNTER = 3'b000;
          
        end

    
    end

    
    
    else begin
        case (STATE)
            ST_COMMON: begin
            
            if (COUNTER == 3'b000 || COUNTER == 3'b001 | COUNTER == 3'b010 )begin
                 STATE = ST_COMMON;
                 //Define os sinais
                PC_write        =   1'b0;
               MEM_write       =   1'b0; // 
                riteIR_write        =   1'b0;
                RB_w        =   1'b0;
                AB_w        =   1'b0;
                Alu_control       =   3'b001; // 
                M_writeReg      =   1'b0;
               mux_ulaA      =   1'b0;//
                M_ULAB      =   2'b01; //
                rst_out     =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = COUNTER +1;
            
                end
            else if (COUNTER == 3'b011) begin
                STATE = ST_COMMON;
                 //Define os sinais
                PC_write        =   1'b1; //
               MEM_write       =   1'b0; 
                riteIR_write        =   1'b1; //
                RB_w        =   1'b0;
                AB_w        =   1'b0;
                Alu_control       =   3'b001; 
                M_writeReg      =   1'b0;
               mux_ulaA      =   1'b0;
                M_ULAB      =   2'b01; 
                rst_out     =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = COUNTER +1;


            end
            else if(COUNTER == 3'b100 ) begin
               STATE = ST_COMMON;
                //Define os sinais
                PC_write        =   1'b0; //
               MEM_write       =   1'b0; 
                riteIR_write        =   1'b0; //
                RB_w        =   1'b0;
                AB_w        =   1'b1; // 
                Alu_control       =   3'b000; 
                M_writeReg      =   1'b0;
               mux_ulaA      =   1'b0;
                M_ULAB      =   2'b00; 
                rst_out     =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = COUNTER +1;

            end
        
            else if(COUNTER == 3b101) begin
                case (OPCODE)
                    ADD: begin
                      STATE = ST_ADD;
                    end
                    ADDI: begin
                      STATE = ST_ADDI;
                    end
                    RESET: begin
                      STATE = ST_RESET;
                    end


                endcase
                
                
                //Define os sinais
                PC_write        =   1'b0; 
               MEM_write       =   1'b0; 
                riteIR_write        =   1'b0; 
                RB_w        =   1'b0;
                AB_w        =   1'b0; //  
                Alu_control       =   3'b000; 
                M_writeReg      =   1'b0;
               mux_ulaA      =   1'b0;
                M_ULAB      =   2'b00; 
                rst_out     =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = 3'b000;
              

            end

            
            end

            ST_ADD: begin
            if (COUNTER == 3'b000) begin
                STATE = ST_ADD;
                //Define os sinais
                PC_write        =   1'b0; //
               MEM_write       =   1'b0; 
                riteIR_write        =   1'b0; //
                RB_w        =   1'b1;
                AB_w        =   1'b0; // 
                Alu_control       =   3'b001; 
                M_writeReg      =   1'b1;
               mux_ulaA      =   1'b1;
                M_ULAB      =   2'b00; 
                rst_out     =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = COUNTER +1;
            
                end

            else if (COUNTER == 3'b001)begin
                STATE = ST_COMMON;
                //Define os sinais
                PC_write        =   1'b0; 
               MEM_write       =   1'b0;
                riteIR_write        =   1'b0; 
                RB_w        =   1'b1;
                AB_w        =   1'b0; 
                Alu_control       =   3'b001; 
                M_writeReg      =   1'b1;
               mux_ulaA      =   1'b1;
                M_ULAB      =   2'b00; 
                rst_out     =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = 3'b000;


            end
            ST_ADDI: begin
            if (COUNTER == 3'b000) begin
                STATE = ST_ADDI;
                //Define os sinais
                PC_write        =   1'b0; //
               MEM_write       =   1'b0; 
                riteIR_write        =   1'b0; //
                RB_w        =   1'b1;
                AB_w        =   1'b0; // 
                Alu_control       =   3'b001; 
                M_writeReg      =   1'b0;
               mux_ulaA      =   1'b1;
                M_ULAB      =   2'b10; 
                rst_out     =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = COUNTER +1;
            
                end

            else if (COUNTER == 3'b001)begin
                STATE = ST_COMMON;
                //Define os sinais
                PC_write        =   1'b0; 
                MEM_write       =   1'b0;
                riteIR_write    =   1'b0; 
                RB_w            =   1'b1;
                AB_w            =   1'b0; 
                Alu_control           =   3'b001; 
                M_writeReg          =   1'b0;
               mux_ulaA          =   1'b1;
                M_ULAB          =   2'b10; 
                rst_out         =   1'b0; 

                // define o contador para a próxima operação
                COUNTER = 3'b000;


            end
            
            
            ST_RESET: begin
             if (COUNTER == 3'b000) begin
                STATE = ST_RESET;
                //Define os sinais
                PC_write        =   1'b0; //
               MEM_write       =   1'b0; 
                riteIR_write        =   1'b0; //
                RB_w        =   1'b0;
                AB_w        =   1'b0; // 
                Alu_control       =   3'b000; 
                M_writeReg      =   1'b0;
               mux_ulaA      =   1'b0;
                M_ULAB      =   2'b00; 
                rst_out     =   1'b1; 

                // define o contador para a próxima operação
                COUNTER = 3'b000;
            
                end


            end

        endcase     
    
    
    end
    
end





endmodule