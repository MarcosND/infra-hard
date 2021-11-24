module ctrl_unit (
    
    input wire  clk,
    input wire  reset,
    


    //fios de controle 
    output reg          PC_write,
    output reg          MEM_write,    
    output reg          IR_write,
    output reg          AB_w,
    output reg          Regwrite,
    output reg          ALUOutCtrl,
                    
    output reg      [2:0] Alu_control,
    output reg      [3:0] MEMtoReg, 
    //output reg      [1:0] Exception,

    
    
    //controladores dos muxes
    output reg [1:0]    M_writeReg,
    output reg [1:0]    IorD,
    output reg [1:0]    PCsource,
    output reg          AluSrcA,
    output reg [1:0]    AluSrcB, 
    
    
    
    //Flags
    input wire      Overflow,
    input wire      Ng,
    input wire      Zr,
    input wire      Eq,
    input wire      Gt,
    input wire      Lt,
    
    //Fios de Dados
    input wire [5:0] OPCODE,
    input wire [5:0] FUNCTION
);   

//variaveis usadas

reg[5:0] STATE;

// Parametros (Constantes)

    //Estados principais da maquina
    parameter ST_RESET = 6'b000000;    
    parameter ST_FETCH_1 = 6'b000001;
    parameter ST_FETCH_2 = 6'b000010;
    parameter ST_DECODE = 6'b000011;
    parameter ST_DECODE_2 = 6'b000100;
    parameter ST_ADD_1 = 6'b000101;
    parameter ST_SUB = 6'b000110;
    parameter ST_AND = 6'b000111;
    parameter ST_CLOSE_ARITH = 6'b001000;
    parameter ST_CLOSE_WRITE = 6'b111111;

    //Opcode
    parameter   R = 6'b000000;
    parameter   ADD = 6'b000000;
    parameter   ADDI = 6'b001000;

    // Function
    parameter FUNCT_ADD = 6'b100000;
    parameter FUNCT_SUB = 6'b100010;
    parameter FUNCT_AND = 6'b100100;


always @(posedge clk) begin
        if (reset || STATE == ST_RESET)begin
          
       

        //Define os sinais, zerando eles
        M_writeReg          = 2'b10; 
        PC_write            = 1'b0;
        MEM_write           = 1'b0;
        IR_write            = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b1;
        AluSrcA             = 1'b0;
        AluSrcB             = 2'b00;
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b1000;
        PCsource            = 2'b00;
        IorD                = 2'b00;
        
        STATE = ST_FETCH_1;
         
        end
    
    else begin
        case (STATE)
            ST_FETCH_1: begin
             //Define os sinais
        M_writeReg          = 2'b00; 
        PC_write            = 1'b0; 
        MEM_write           = 1'b0;
        IR_write            = 1'b0;
        AB_w                = 1'b0;
        Regwrite            = 1'b0; // 
        AluSrcA             = 1'b0;
        AluSrcB             = 2'b01; // 
        Alu_control         = 3'b001; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; //
        PCsource            = 2'b00;
        IorD                = 2'b00;   
                
        STATE = ST_FETCH_2;   
            
        end
            
        ST_FETCH_2: begin
           
              //Define os sinais
        M_writeReg          = 2'b00;
        PC_write            = 1'b1; // 
        MEM_write           = 1'b0;
        IR_write            = 1'b1; //
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0;
        AluSrcB             = 2'b01; 
        Alu_control         = 3'b001;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b10; //
        IorD                = 2'b00; 
        
        STATE = ST_DECODE;
        
        end
            ST_DECODE: begin
             //Define os sinais
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  //
        MEM_write           = 1'b0;
        IR_write            = 1'b0; //
        AB_w                = 1'b1; //
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; //
        AluSrcB             = 2'b10; //
        Alu_control         = 3'b001; //
        ALUOutCtrl          = 1'b1; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00; //
        IorD                = 2'b00; 

        STATE = ST_DECODE_2;
            end
        ST_DECODE_2: begin
             //Define os sinais
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b1; 
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; //
        AluSrcB             = 2'b10; //
        Alu_control         = 3'b001; 
        ALUOutCtrl          = 1'b0; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00; 
        IorD                = 2'b00; 
            
        case (OPCODE)
            R: begin
              case(FUNCTION)
                FUNCT_ADD: begin
                  STATE = ST_ADD_1;
                end
                FUNCT_SUB: begin
                  STATE = ST_SUB;
                end
                FUNCT_AND: begin
                  STATE = ST_AND;
                end
              endcase
            end
        endcase
            
        end
            ST_ADD_1: begin
             //Define os sinais
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b001;
        ALUOutCtrl          = 1'b1; // 
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
            
                STATE = ST_CLOSE_ARITH;
        end

            ST_SUB: begin
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b010; //
        ALUOutCtrl          = 1'b1; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
            
                STATE = ST_CLOSE_ARITH;
        end
            ST_AND: begin
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b1; //
        AluSrcB             = 2'b00; //
        Alu_control         = 3'b011; //
        ALUOutCtrl          = 1'b1; //
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
            
                STATE = ST_CLOSE_ARITH;
        end
            ST_CLOSE_ARITH: begin
              //Define os sinais
        M_writeReg          = 2'b01; //
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b1; //
        AluSrcA             = 1'b0; //
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000; //
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0101; //
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        

        STATE = ST_CLOSE_WRITE;

            end
        ST_CLOSE_WRITE: begin
               //Define os sinais, vai zerar tudo
        M_writeReg          = 2'b00;
        PC_write            = 1'b0;  
        MEM_write           = 1'b0;
        IR_write            = 1'b0; 
        AB_w                = 1'b0;
        Regwrite            = 1'b0; 
        AluSrcA             = 1'b0; 
        AluSrcB             = 2'b00; 
        Alu_control         = 3'b000;
        ALUOutCtrl          = 1'b0;
        MEMtoReg            = 4'b0000; 
        PCsource            = 2'b00;
        IorD                = 2'b00; 
        
        
        STATE = ST_FETCH_1;

        end


        endcase     
    
    
    end
    
end





endmodule