/*   ******************  Historico ***********************

2018/2
Antônio Henrique de Moura Rodrigues 	- 15/0118236
Igor Figueira Pinheiro da Silva 			- 15/0129921
Gabriel Patrick Alcântara Mourão 		- 15/0126701
Gabriel dos Santos Martins 				- 15/0126298
João Gabriel Lima Neves 					- 15/0131992
Tiago Rodrigues da Cunha Cabral 			- 15/0150296

2019/01
Leonardo Rodrigues de Souza 				- 17/0060543
	

 Adaptado para a placa de desenvolvimento DE1-SoC.
 Prof. Marcus Vinicius Lamar   2019/1
 UnB - Universidade de Brasilia
 Dep. Ciencia da Computacao
 
*/

// **************************************************** 
// * Escolha o tipo de processador a ser implementado *
`define UNICICLO
//`define MULTICICLO 
//`define PIPELINE


// ****************************************************
// * Escolha a ISA a ser implementada                 *
//`define RV32I
//`define RV32IM
`define RV32IMF
`ifndef PARAM
`define PARAM


/* Parametros Gerais*/
parameter
    ON          = 1'b1,
    OFF         = 1'b0,
    ZERO        = 32'h00000000,	 
	 
/* Operacoes da ULA */
	OPAND		= 5'd0,
	OPOR		= 5'd1,
	OPXOR		= 5'd2,
	OPADD		= 5'd3,
	OPSUB		= 5'd4,
	OPSLT		= 5'd5,
	OPSLTU	= 5'd6,
	OPSLL		= 5'd7,
	OPSRL		= 5'd8,
	OPSRA		= 5'd9,
	OPLUI		= 5'd10,
	OPMUL		= 5'd11,
	OPMULH	= 5'd12,
	OPMULHU	= 5'd13,
	OPMULHSU	= 5'd14,
	OPDIV		= 5'd15,
	OPDIVU	= 5'd16,
	OPREM		= 5'd17,
	OPREMU	= 5'd18,
	OPNULL	= 5'd31, // saída ZERO
		
/* Operacoes da ULA FP */
	FOPADD      = 5'd0,
	FOPSUB      = 5'd1,
	FOPMUL      = 5'd2,
	FOPDIV      = 5'd3,
	FOPSQRT     = 5'd4,
	FOPABS      = 5'd5,
	FOPCEQ      = 5'd6,
	FOPCLT      = 5'd7,
	FOPCLE      = 5'd8,
	FOPCVTSW    = 5'd9,
	FOPCVTWS    = 5'd10,		
	FOPMV       = 5'd11,
	FOPSGNJ     = 5'd12,
	FOPSGNJN    = 5'd13,
	FOPSGNJX    = 5'd14,
	FOPMAX      = 5'd15,
	FOPMIN      = 5'd16,
	FOPCVTSWU   = 5'd17,
	FOPCVTWUS   = 5'd18,
	FOPNULL		= 5'd31, // saída EEEEEEEE
	
/*====================================[OPCODES]====================================*/
    OPC_R_ADD       = 11'b10001011000,
    OPC_R_SUB       = 11'b11001011000,
    OPC_R_AND       = 11'b10001010000,
    OPC_R_ORR       = 11'b10101010000,
    OPC_R_MUL       = 11'b10011011000,
    OPC_R_SDIV      = 11'b10011010110,

    OPC_D_LDUR      = 11'b11111000010,
    OPC_D_STUR      = 11'b11111000000,
    OPC_D_STURB     = 11'b00111000000,
    OPC_D_LDURB     = 11'b00111000010,
    OPC_D_STURH     = 11'b01111000000,
    OPC_D_LDURH     = 11'b01111000010,
    OPC_D_STURW     = 11'b10111000000,
    OPC_D_LDURSW    = 11'b10111000100,
    OPC_D_STXR      = 11'b11001000000,
    OPC_D_LDXR      = 11'b11001000010,

    OPC_I_ADDI      = 11'b1001000100?,
    OPC_I_ANDI      = 11'b1001001000?,
    OPC_I_ORRI      = 11'b1011001000?,
    OPC_I_SUBI      = 11'b1101000100?,
    OPC_I_ADDIS     = 11'b1011000100?,
    OPC_I_EORI      = 11'b1101001000?,
    OPC_I_SUBIS     = 11'b1111000100?,
    OPC_I_ANDIS     = 11'b1111001000?,

    OPC_CB_CBZ      = 11'b10110100???,
    OPC_CB_CBNZ     = 11'b10110101???,
    OPC_CB_BCOND    = 11'b01010100???,

    OPC_B_B         = 11'b000101?????,

    SHAMT_ADD       = 6'b000000,
    SHAMT_SUB       = 6'b000000,
    SHAMT_AND       = 6'b000000,
    SHAMT_ORR       = 6'b000000,
    SHAMT_MUL       = 6'b011111,
    SHAMT_SDIV      = 6'b000010,

/* ADDRESS  *****************************************************************************************************/

    BEGINNING_TEXT      = 32'h0040_0000,
	 TEXT_WIDTH				= 14+2,					// 16384 words = 16384x4 = 64ki bytes	 
    END_TEXT            = (BEGINNING_TEXT + 2**TEXT_WIDTH) - 1,	 

	 
    BEGINNING_DATA      = 32'h1001_0000,
	 DATA_WIDTH				= 15+2,					// 32768 words = 32768x4 = 128ki bytes
    END_DATA            = (BEGINNING_DATA + 2**DATA_WIDTH) - 1,	 


	 STACK_ADDRESS       = END_DATA-3,


//    BEGINNING_KTEXT     = 32'h8000_0000,
//	 KTEXT_WIDTH			= 13,					// 2048 words = 2048x4 = 8192 bytes
//    END_KTEXT           = (BEGINNING_KTEXT + 2**KTEXT_WIDTH) - 1,	 	 
//	 
//    BEGINNING_KDATA     = 32'h9000_0000,
//	 KDATA_WIDTH			= 12,					// 1024 words = 1024x4 = 4096 bytes
//    END_KDATA           = (BEGINNING_KDATA + 2**KDATA_WIDTH) - 1,	 	 

	 
    BEGINNING_IODEVICES         = 32'hFF00_0000,
	 
    BEGINNING_VGA0              = 32'hFF00_0000,
    END_VGA0                    = 32'hFF01_2C00,  // 320 x 240 = 76800 bytes

    BEGINNING_VGA1              = 32'hFF10_0000,
    END_VGA1                    = 32'hFF11_2C00,  // 320 x 240 = 76800 bytes	 
	 
	 FRAMESELECT					  = 32'hFF20_0604,  // Frame Select register 0 ou 1
	 
	 KDMMIO_CTRL_ADDRESS		     = 32'hFF20_0000,	// Para compatibilizar com o KDMMIO
	 KDMMIO_DATA_ADDRESS		  	  = 32'hFF20_0004,
	 
	 BUFFER0_TECLADO_ADDRESS     = 32'hFF20_0100,
    BUFFER1_TECLADO_ADDRESS     = 32'hFF20_0104,
	 
    TECLADOxMOUSE_ADDRESS       = 32'hFF20_0110,
    BUFFERMOUSE_ADDRESS         = 32'hFF20_0114,
	 
	 RS232_READ_ADDRESS          = 32'hFF20_0120,
    RS232_WRITE_ADDRESS         = 32'hFF20_0121,
    RS232_CONTROL_ADDRESS       = 32'hFF20_0122,
	  
	 AUDIO_INL_ADDRESS           = 32'hFF20_0160,
    AUDIO_INR_ADDRESS           = 32'hFF20_0164,
    AUDIO_OUTL_ADDRESS          = 32'hFF20_0168,
    AUDIO_OUTR_ADDRESS          = 32'hFF20_016C,
    AUDIO_CTRL1_ADDRESS         = 32'hFF20_0170,
    AUDIO_CRTL2_ADDRESS         = 32'hFF20_0174,

    NOTE_SYSCALL_ADDRESS        = 32'hFF20_0178,
    NOTE_CLOCK                  = 32'hFF20_017C,
    NOTE_MELODY                 = 32'hFF20_0180,
    MUSIC_TEMPO_ADDRESS         = 32'hFF20_0184,
    MUSIC_ADDRESS               = 32'hFF20_0188,      // Endereco para uso do Controlador do sintetizador
    PAUSE_ADDRESS               = 32'hFF20_018C,
		
	 IRDA_DECODER_ADDRESS		 = 32'hFF20_0500,
	 IRDA_CONTROL_ADDRESS       = 32'hFF20_0504, 	 	// Relatorio questao B.10) - Grupo 2 - (2/2016)
	 IRDA_READ_ADDRESS          = 32'hFF20_0508,		 	// Relatorio questao B.10) - Grupo 2 - (2/2016)
    IRDA_WRITE_ADDRESS         = 32'hFF20_050C,		 	// Relatorio questao B.10) - Grupo 2 - (2/2016)
    
	 STOPWATCH_ADDRESS			 = 32'hFF20_0510,	 		//Feito em 2/2016 para servir de cronometro
	 
	 LFSR_ADDRESS					 = 32'hFF20_0514,			// Gerador de numeros aleatorios
	 
	 KEYMAP0_ADDRESS				 = 32'hFF20_0520,			// Mapa do teclado 2017/2
	 KEYMAP1_ADDRESS				 = 32'hFF20_0524,
	 KEYMAP2_ADDRESS				 = 32'hFF20_0528,
	 KEYMAP3_ADDRESS				 = 32'hFF20_052C,
	 
	 BREAK_ADDRESS					 = 32'hFF20_0600,  	  // Buffer do endereço do Break Point
	 
	 
/* STATES ************************************************************************************************************/
   ST_FETCH       	= 6'd00,
   ST_FETCH1      	= 6'd01,
   ST_DECODE      	= 6'd02,
	ST_LWSW				= 6'd03,
	ST_SW					= 6'd04,
	ST_SW1				= 6'd05,
	ST_LW					= 6'd06,
	ST_LW1				= 6'd07,
	ST_LW2				= 6'd08,
	ST_RTYPE				= 6'd09,
	ST_ULAREGWRITE		= 6'd10,
	ST_BRANCH			= 6'd11,
	ST_JAL				= 6'd12,
	ST_IMMTYPE			= 6'd13,
	ST_JALR				= 6'd14,
	ST_AUIPC				= 6'd15,
	ST_LUI				= 6'd16,
	ST_SYS				= 6'd17, // nao implementado
	ST_URET				= 6'd18,	// nao implementado
	ST_DIVREM			= 6'd19,

	// Estados FPULA
	ST_FRTYPE        	= 6'd20, // Estado para instrucoes do tipo R float
	ST_FLW           	= 6'd21, // Estado para computar o flw
	ST_FLW1          	= 6'd22,
	ST_FLW2          	= 6'd23,
	ST_FSW           	= 6'd24,
	ST_FSW1          	= 6'd25,
	ST_FPALUREGWRITE 	= 6'd26,
	ST_FPSTART       	= 6'd27, // Estado que inicializa a operacao na FPULA
	ST_FPWAIT		  	= 6'd28, 

	ST_ERRO        	= 6'd63, // Estado de Erro
	
	
/* Tamanho dos Registradores do Pipeline **************************************************************************************/	

`ifndef RV32IMF
	NIFID  = 96,
	NIDEX  = 198,
	NEXMEM = 149,
	NMEMWB = 144,
`else
	NIFID  = 96,
	NIDEX  = 274, // + 5 Adicionais InstrType + 1 CFRegWrite + 32 FRead1 + 32 FRead2 +5 CFPALUControl + 1 CFPALUStart
	NEXMEM = 187, // + 5 Adicionais InstrType + 1 CFRegWrite + 32 FPALUResult
	NMEMWB = 182, // + 1 CFRegWrite + 32 FPALUResult
`endif
	
/* Tamanho em bits do Instruction Type */
`ifndef RV32IMF
	NTYPE = 7;
`else
	NTYPE = 13;
`endif

	
`endif