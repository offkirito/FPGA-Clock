module clockss
(
	input reset,
	output reg []S
);

reg [31:0] clk_divider; //contador 32-bit para dividir los 50Mhz a 1Hz.

reg slow_clk; // clk 1Hz



always @ (posedge clk or posedge reset) begin

  if (reset) begin

    clk_divider <= 32'd0;

    slow_clk <= 0;

  end else begin

    if (clk_divider == 32'd25000000) begin // Cambiar de estado cada 25M ciclos

      slow_clk <= ~slow_clk;

      clk_divider <= 32'd0;

    end else begin

      clk_divider <= clk_divider + 1;

    end

  end

end


 always @ (posedge slow_clk or posedge reset) begin
	 if (reset) begin
	 
    slow_clk <= 0;
	 S <= 0
	 

  end 
  else begin
	
 
 end
