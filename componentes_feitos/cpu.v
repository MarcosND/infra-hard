module cpu(
    input wire clock,
    input wire reset
);



    // fios de controle

    wire PC_write;
    wire MEM_write;
    wire IR_write;
    wire M_writeReg;
    wire Regwrite;
    wire AB_w;
    wire AluSrcA; // falta colocar o tamanho de alguns desses sinais
    wire AluSrcB;
    wire ALUOutCtrl;
    wire [2:0] Alu_control;
    wire [3:0] MEMtoReg;
    wire [2:0] PCsource;
    wire [2:0] IorD;
    

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
    wire [31:0] result_out;
    wire [31:0] IorD_out;
    wire [31:0] Shiftleft_26to28_out;
    wire [31:0] EPC_out;
    wire [31:0] PCsource_out;
    wire [31:0] SL2_out;
    wire [31:0] LS_out;
    wire [31:0] HI_out;
    wire [31:0] LO_out;
    wire [31:0] SE1_32_out;
    wire [31:0] ShiftReg_out;
    wire [31:0] MEMtoReg_out;


    // registradores

    Registrador PC_(
        clock,
        reset,
        PC_write,
        ULA_out,
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

    Memoria MEM_(
        PC_out,
        clock,
        MEM_write,
        SS_out,
        MEM_out
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
        PC_out,
        B_out,
        AluB_out
    );

    mux_IorD IorD_(
        IorD,
        PC_out,
        Excp_out,
        ALUOut_out,
        result_out,
        IorD_out
    );

    mux_PCsource PcSource_(
        PCsource,
        Shiftleft_26to28_out,
        EPC_out,
        result_out,
        ALUOut_out,
        PCsource_out
    );

    mux_MEMtoReg MEMtoReg_(
        MEMtoReg,
        ALUOut_out,
        LS_out,
        HI_out,
        LO_out,
        SE1_32_out,
        result_out,
        SE16_out,
        ShiftReg_out,
        MEMtoReg_out
    );

    // sign extends

    sign_extend_16 SE16_(
        OFFSET,
        SE16_out
    );

    shift_left_2 SL2_(
        SE16_out,
        SL2_out
    );

    ctrl_unit CTRL_(
        clock,
        reset,
        PC_write,
        MEM_write,
        IR_write,
        AB_w,
        Regwrite,
        ALUOutCtrl,
        Alu_control,
        MEMtoReg,
        PCsource,
        IorD,
        M_writeReg,
        AluSrcA,
        AluSrcB,
        Overflow,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,
        OPCODE
    );

endmodule