/*   ******************  Historico ***********************

2018/2
Antônio Henrique de Moura Rodrigues 	    - 15/0118236
Igor Figueira Pinheiro da Silva 			- 15/0129921
Gabriel Patrick Alcântara Mourão 		    - 15/0126701
Gabriel dos Santos Martins 				    - 15/0126298
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

parameter
    ON          = 1'b1,
    OFF         = 1'b0,
    ZERO        = 64'h0000000000000000,	 
	 
/*-------------------[ULA]-------------------*/
	OPAND		= 5'd0,
	OPOR		= 5'd1,
	OPXOR		= 5'd2,
	OPADD		= 5'd3,
	OPSUB		= 5'd4,
	OPSLT		= 5'd5,
	OPSLTU	    = 5'd6,
	OPSLL		= 5'd7,
	OPSRL		= 5'd8,
	OPSRA		= 5'd9,
	OPLUI		= 5'd10,
	OPMUL		= 5'd11,
	OPMULH	    = 5'd12,
	OPMULHU	    = 5'd13,
	OPMULHSU	= 5'd14,
	OPDIV		= 5'd15,
	OPDIVU	    = 5'd16,
	OPREM		= 5'd17,
	OPREMU	    = 5'd18,
	OPNULL	    = 5'd31, // saída ZERO
		
/*-------------------[FPULA]-------------------*/
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
	
/*-------------------[OPCODES]-------------------*/
    OPC_R_ADD       = 11'b10001011000,
    OPC_R_SUB       = 11'b11001011000,
    OPC_R_AND       = 11'b10001010000,
    OPC_R_ORR       = 11'b10101010000,
    OPC_R_MUL       = 11'b10011011000,
    OPC_R_SMULH     = 11'b10011011010,
    OPC_R_UMULH     = 11'b10011011110,
    OPC_R_MULHSU    = 11'b10011011111,
    OPC_R_DIV       = 11'b10011010110,
    OPC_R_REM       = 11'b10011010100,
    OPC_R_REMU      = 11'b10011010111,
    OPC_R_EOR       = 11'b11001010000,
    OPC_R_BR        = 11'b11010110000,

    OPC_D_LDUR      = 11'b11111000010,
    OPC_D_STUR      = 11'b11111000000,
    OPC_D_STURB     = 11'b00111000000,
    OPC_D_LDURB     = 11'b00111000010,
    OPC_D_LDURSB    = 11'b00111000011,
    OPC_D_STURH     = 11'b01111000000,
    OPC_D_LDURH     = 11'b01111000010,
    OPC_D_LDURSH    = 11'b01111000011,
    OPC_D_STURW     = 11'b10111000000,
    OPC_D_LDURSW    = 11'b10111000100,
    OPC_D_STXR      = 11'b11001000000,
    OPC_D_LDXR      = 11'b11001000010,
    OPC_D_LDURD     = 11'b11111100000,
    OPC_D_STURD     = 11'b11111100010,

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
    OPC_B_BL        = 11'b100101?????,

    SHAMT_ADD       = 6'b000000,
    SHAMT_SUB       = 6'b000000,
    SHAMT_AND       = 6'b000000,
    SHAMT_ORR       = 6'b000000,
    SHAMT_MUL       = 6'b011111,
    SHAMT_SDIV      = 6'b000010,
    SHAMT_UDIV      = 6'b000011,

/*-------------------[MEMÓRIA]-------------------*/
    BEGINNING_TEXT      = 64'h0000_0000_0040_0000,
	TEXT_WIDTH			= 14 + 2,       // 16384 words = 16384x4 = 65Ki bytes	 
    END_TEXT            = (BEGINNING_TEXT + 2**TEXT_WIDTH) - 1,	 

	 
    BEGINNING_DATA      = 64'h0000_0000_0041_0000,
	DATA_WIDTH			= 14 + 3,      // 32768 words = 32768x4 = 131ki bytes
    END_DATA            = (BEGINNING_DATA + 2**DATA_WIDTH) - 1,	 
	STACK_ADDRESS       = END_DATA - 7,

/*-------------------[REGISTRADORES]-------------------*/
    STACK_REG           = 5'd28,
    ZERO_REG            = 5'd31;	
`endif