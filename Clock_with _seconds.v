module clockss
(
	input clk,
	input reset,
	input pause,
	output reg [5:0] S,
	output reg [5:0] M,
	output reg [3:0] H
);

reg [31:0] clk_divider;

wire tick_1hz;
wire tick_1min;

assign tick_1hz = (clk_divider == 32'd49999999); // tick para cada segundo
  assign tick_1min = (tick_1hz && S == 59); // Tick para cada minuto, cuando hay una tick de 1 segundo y segundos es igual a 59 es un tick de minutos






// DIVISOR
always @(posedge clk or posedge reset) begin

	if (reset) begin
		clk_divider <= 0;
	end

	else if (!pause) begin

		if (tick_1hz)
			clk_divider <= 0;
		else
			clk_divider <= clk_divider + 1;

	end
end



// CONTADOR
always @(posedge clk or posedge reset) begin
	if (reset) begin
		S <= 0;
	end

	else if (tick_1hz && !pause) begin
		if (S == 59)
			S <= 0;
		
		else
			S <= S + 1;
	end
end

endmodule
