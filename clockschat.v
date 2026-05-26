module clockss
(
    input clk,
    input reset,
    input pause,
    output reg [5:0] S
);

reg [31:0] clk_divider;

wire tick_1hz;

assign tick_1hz = (clk_divider == 32'd49999999);



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
        S <= S + 1;
    end

end

endmodule
