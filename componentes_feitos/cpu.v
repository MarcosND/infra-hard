module cpu(
    input wire clock,
    input wire reset
);



    // fios de controle

    wire PC_write;
    wire MEM_write;
    wire IR_write;
    wire Mult_Div;
    wire HIWrite;
    wire LOWrite;
    wire [1:0] M_writeReg;
    wire Regwrite;
    wire AB_write;
    wire EPC_Write;
    wire AluSrcA;
    wire [1:0] AluSrcB;
    wire ALUOutCtrl;
    wire MDR_Write;
    wire [2:0] Alu_control;
    wire [3:0] MEMtoReg;
    wire [1:0] PCsource;
    wire [1:0] IorD;
    wire [1:0] controleSS;
    wire [1:0] controleLS;
    wire [2:0] ShiftControl;
    wire [1:0] ShiftAmt;
    wire ShiftSrc;
    

    //Flags
    
    wire Overflow;
    wire Ng;
    wire Zr;
    wire Eq; 
    wire Gt; 
    wire Lt; 

    // fios de dados

    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;
    wire [4:0] WriteReg_in;
    wire [4:0] ShiftAmt_out;


    wire [31:0] ULA_out;
    wire [31:0] ALUOut_out;
    wire [31:0] PC_out;
    wire [31:0] MEM_out;
    wire [31:0] regA_out;
    wire [31:0] regB_out;
    wire [31:0] B_out;
    wire [31:0] A_out;
    wire [31:0] SE16_out;
    wire [31:0] AluA_out;
    wire [31:0] AluB_out;
    wire [31:0] Exception_out;
    wire [31:0] IorD_out;
    wire [31:0] Shiftleft_26to28_out;
    wire [31:0] EPC_out;
    wire [31:0] PCsource_out;
    wire [31:0] SL2_out;
    wire [31:0] SS_out;
    wire [31:0] LS_out;
    wire [31:0] HI_out;
    wire [31:0] LO_out;
    wire [31:0] SE1_32_out;
    wire [31:0] SL16_out;

    wire [31:0] MDR_out;
    wire [31:0] MEMtoReg_out;
    wire [31:0] ShiftSrc_out;
    wire [31:0] ShiftReg_out;
    wire [31:0] mult_output_HI;
    
    wire [31:0] mult_Hi_out;
    wire [31:0] div_Hi_out;
    wire [31:0] mult_Lo_out;
    wire [31:0] div_Lo_out;
    wire [31:0] HI_out_mux;
    wire [31:0] Lo_out_mux;
    wire [25:0] concatena_out;
    
    

// lembrar de quando rodar o modelsim, antes do ciclo inical setar o reset para 1, e no proximo colocar pra 0.

    // registradores

    Registrador PC_(
        clock,
        reset,
        PC_write,
        PCsource_out,
        PC_out
    );

    Registrador A_(
        clock,
        reset,
        AB_write,
        regA_out,
        A_out
    );

    ula32 ULA_(
        AluA_out,
        AluB_out,
        Alu_control,
        ULA_out,
        Overflow,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt
    );

    Registrador B_(
        clock,
        reset,
        AB_write,
        regB_out,
        B_out
    );

    
    Registrador ALUOut_(
        clock,
        reset,
        ALUOutCtrl,
        ULA_out,
        ALUOut_out
    );

    Registrador EPC(
        clock,
        reset,
        EPC_Write,
        PC_out,
        EPC_out
    );

    Registrador MDR(
        clock,
        reset,
        MDR_Write,
        MEM_out,
        MDR_out
    );

    Memoria MEM_(
        IorD_out,
        clock,
        MEM_write,
        SS_out,
        MEM_out
    );

    ss_component SS_(
        controleSS,
        MDR_out,
        B_out,
        SS_out
    );

    ls_component LS_(
        controleLS,
        MDR_out,
        LS_out
    );

    Instr_Reg IR_(
        clock,
        reset,
        IR_write,
        MEM_out,
        OPCODE,
        RS,
        RT,
        OFFSET
    );

    Banco_reg REG_BASE_(
        clock,
        reset,
        Regwrite,
        RS,
        RT,
        WriteReg_in,
        MEMtoReg_out,
        regA_out,
        regB_out
    );

    RegDesloc Shift_reg_(
        clock,
        reset,
        ShiftControl,
        ShiftAmt_out,
        ShiftSrc_out,
        ShiftReg_out
    );

    Registrador HI_(
        clock,
        reset,
        HIWrite,
        HI_out_mux,
        HI_out
    );
    
    Registrador LO_(
        clock,
        reset,
        LOWrite,
        Lo_out_mux,
        LO_out 
    );

    multiplicador MULT_(
        clock,
        reset,
        Mult_Div,
        A_out,
        B_out,
        mult_Hi_out,
        mult_Lo_out,
    );

    divisor DIV_(
        clock,
        reset,
        Mult_Div,
        A_out,
        B_out,
        div_Hi_out,
        div_Lo_out,
    );

    
    shift_left_26to28 shift_left_26to28(
        concatena_out,
        Shiftleft_26to28_out

    );
    concatena_26to28 concatena_26to28(
        RT,
        RS,
        OFFSET,
        concatena_out 
    );

   concatena_28to32 concatena_28to32(
        PC_out,
        Shiftleft_26to28_out, // bota aqui a saida do shift left pra 32
        conc_out 
    );
            



    // muxes

    mux_regDst M_WR_(
        M_writeReg,
        RT,
        OFFSET,
        WriteReg_in
    );

    mux_ulaA mux_ulaA_(
        AluSrcA,
        PC_out,
        A_out,
        AluA_out
    );

    mux_ulaB mux_ulaB_(
        AluSrcB,
        B_out,
        SL2_out,
        SE16_out,
        AluB_out
    );

    mux_IorD IorD_(
        IorD,
        PC_out,
        Exception_out,
        ALUOut_out,
        ULA_out,
        IorD_out
    );

    mux_PCsource PcSource_(
        PCsource,
        Shiftleft_26to28_out,
        EPC_out,
        ULA_out,
        ALUOut_out,
        PCsource_out
    );

    mux_Shift_Amt ShiftAmt_(
        ShiftAmt,
        B_out,
        OFFSET,
        MDR_out,
        ShiftAmt_out
    );

    mux_Shift_Src ShiftSrc_(
        ShiftSrc,
        A_out,
        B_out,
        ShiftSrc_out
    );

    mux_MEMtoReg MEMtoReg_(
        MEMtoReg,
        ALUOut_out,
        LS_out,
        HI_out,
        LO_out,
        SE1_32_out,
        ULA_out,
        SL16_out,
        ShiftReg_out,
        MEMtoReg_out
    );

    mux_Hi HI_(
        Mult_Div,
        mult_Hi_out,
        div_Hi_out,
        HI_out_mux
    );

    mux_Lo LO_(
        Mult_Div,
        mult_Lo_out, 
        div_Lo_out,
        Lo_out_mux
    );

    // sign extends

    sign_extend_16 SE16_(
        OFFSET,
        SE16_out
    );

    sign_extend_1to32 SE1_(
        Lt,
        SE1_32_out
    );

    shift_left_2 SL2_(
        SE16_out,
        SL2_out
    );

    shift_left_16 SL16_(
       OFFSET,
       SL16_out 
    );

    ctrl_unit CTRL_(
        clock,
        reset,
        PC_write,
        MEM_write,
        IR_write,
        Mult_Div,
        HIWrite,
        LOWrite,
        AB_write,
        EPC_Write,
        Regwrite,
        ALUOutCtrl,
        MDR_Write,
        Alu_control,
        ShiftControl,
        MEMtoReg,
        controleSS,
        controleLS,
        M_writeReg,
        IorD,
        PCsource,
        ShiftAmt,
        ShiftSrc,
        AluSrcA,
        AluSrcB,
        Overflow,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,
        OPCODE,
        OFFSET[5:0]
    );

endmodule