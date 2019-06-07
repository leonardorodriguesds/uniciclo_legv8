module CLOCK_Interface(
    input 		iCLK_50,						    // Clock 50MHz externo
    input       iRST,
    output 		oCLK_50,oCLK_25,oCLK_100, oCLK_150,oCLK_200,oCLK_27,oCLK_18,		// Clocks gerados aqui
    output  	CLK,							    // Clock controlado que comandará o processador
    output 		Reset,						        // Sinal de reset 
    output reg 	CLKSelectFast, CLKSelectAuto,		// flip-flops dos comandos
    input [3:0] iKEY,							    // Comando dos botões
    input [7:0] fdiv,							    // Divisor de frequencia
    input 		Timer,						        // Comando do Timer
    input 		iBreak,						        // Comando do break
    output reg	CLKAutoFast, wClk
);


reg CLKManual, CLKAutoSlow;     // CLKAutoFast;

reg [7:0] CLKCount2;            // contador do CLK fast
reg [25:0] CLKCount;            // contador do CLK slow
wire wLock;
reg oCLK_50a;

reg [1:0] rreset;
assign	Reset = ~iRST || (rreset < 2'b11) ;  // Reset assincrono

	
// inicia resetado 3 ciclos
initial
    rreset = 2'b00;
always @(posedge iCLK_50)
    if(rreset == 2'b11)
        rreset = 2'b11;
    else
        rreset = rreset + 1'b1;


initial
begin
    CLKManual		<= 1'b0;
    CLKAutoSlow		<= 1'b0;
    CLKAutoFast		<= 1'b0;
    CLKSelectAuto	<= 1'b0;
    CLKSelectFast	<= 1'b0;
    CLKCount2		<= 8'b0;
    CLKCount		<= 26'b0;
    oCLK_50a		<= 1'b0;
end


/*---------------[PLL <= GERAÇÃO DE OUTROS CLOCKS]---------------*/
PLL_Main PLL1 (
    .rst(Reset),
    .refclk(iCLK_50),
    .outclk_0(oCLK_25),
    .outclk_1(oCLK_100),
    .outclk_2(oCLK_150),
    .outclk_3(oCLK_200),
    .outclk_4(oCLK_18),
    .outclk_5(oCLK_27),
    .locked(wLock)
);

assign wClk = oCLK_100;   // Escolher manualmente  iCLK_50  wClk1=100MHz:(fdiv)  wClk2=150MHz  wClk3=200MHz

// P/ Verificar se é problema de fase
always @(posedge oCLK_100)
    oCLK_50a = ~oCLK_50a;

// Define se o CLK_50 será externo iCLK_50 ou interno oCLK_50
assign oCLK_50 = (wLock? oCLK_50a: iCLK_50);
/*---------------[TIMER DE 10 SEGUNDOS]---------------*/
wire Parar;
mono Timer10 (
    .clock50(oCLK_50),
    .enable(Timer),
    .stop(Parar),
    .rst(Reset)
);
/*---------------[SELEÇÃO DO CLOCK]---------------*/
assign CLK = CLKSelectAuto? (CLKSelectFast? CLKAutoFast : CLKAutoSlow) : CLKManual;
/*---------------[CLOCK MANUAL]---------------*/
always @(posedge iKEY[3] or posedge Reset)
    if(Reset)
        CLKManual <= 1'b0;
    else
        CLKManual <= ~CLKManual;
/*---------------[ALTERNA ENTRE CLOCK AUTOMATICO OU MANUAL]---------------*/	
always @(posedge iKEY[2] or posedge iBreak or posedge Parar)
    begin
        if (iBreak || Parar)
            CLKSelectAuto <= 1'b0;
        else
            CLKSelectAuto <= ~CLKSelectAuto;
    end
/*---------------[CLOCK SLOW OR FAST]---------------*/
// Alterna entre clock rápido ou lento
always @(posedge iKEY[1])
    begin
        CLKSelectFast <= ~CLKSelectFast;
    end
/*---------------[DIVISÃO DO CLOCK]---------------*/
wire [7:0] divisor;
assign divisor=fdiv-8'd1;
always @(posedge wClk)
    begin
        if (CLKCount == {divisor, 18'h20000}) //Clock Slow (nunca é zero)
            begin
                CLKAutoSlow <= ~CLKAutoSlow;
                CLKCount <= 26'b0;
            end
        else CLKCount <= CLKCount + 1'b1;
    end

always @(posedge wClk)
    begin
        if (CLKCount2 == divisor) //Clock Fast  (pode ser zero)
            begin
                CLKAutoFast <= ~CLKAutoFast;
                CLKCount2 <= 8'b0;
            end
        else
            CLKCount2 <= CLKCount2 + 1'b1;
    end
endmodule
