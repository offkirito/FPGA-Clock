module clock_bcd_7seg
(
    input clk,
    input reset,
    input pause,
    output [6:0] seg,      // Segmentos a,b,c,d,e,f,g (1 = encendido)
    output [3:0] dig_sel   // Selector de dígito (0 = encendido para cátodo común)
);

// Arreglo para los 4 displays BCD
reg [3:0] bcd [0:3]; 

// Variables internas para el reloj
reg [31:0] clk_divider;
reg [5:0] sec; 

// --- BANDERAS DEL RELOJ (Dataflow) ---
wire tick_1hz   = (clk_divider == 32'd49999999);
wire tick_1min  = (tick_1hz   && sec == 6'b111011);      // 59
wire tick_10min = (tick_1min  && bcd[0] == 4'b1001);     // 9
wire tick_1hr   = (tick_10min && bcd[1] == 4'b0101);     // 5

// --- RELOJ Y CONTROL BCD ---
always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_divider <= 32'd0;       
        sec         <= 6'b000000;   
        bcd[0]      <= 4'b0000;
        bcd[1]      <= 4'b0000;
        bcd[2]      <= 4'b0000;
        bcd[3]      <= 4'b0000;
    end else if (!pause) begin
        
        // Segundos
        if (tick_1hz) begin
            clk_divider <= 32'd0;
            if (sec == 6'b111011) sec <= 6'b000000;
            else sec <= sec + 6'b000001;
        end else begin
            clk_divider <= clk_divider + 32'd1; 
        end
        
        // Minutos y Horas
        if (tick_1min) begin
            if (bcd[0] == 4'b1001) bcd[0] <= 4'b0000;
            else bcd[0] <= bcd[0] + 4'b0001;
        end
        
        if (tick_10min) begin
            if (bcd[1] == 4'b0101) bcd[1] <= 4'b0000;
            else bcd[1] <= bcd[1] + 4'b0001;
        end
        
        if (tick_1hr) begin
            if (bcd[3] == 4'b0001 && bcd[2] == 4'b0001) begin
                bcd[2] <= 4'b0000;
                bcd[3] <= 4'b0000;
            end 
            else if (bcd[2] == 4'b1001) begin
                bcd[2] <= 4'b0000;
                bcd[3] <= bcd[3] + 4'b0001;
            end 
            else begin
                bcd[2] <= bcd[2] + 4'b0001;
            end
        end
    end
end

// --- MULTIPLEXIÓN DEL DISPLAY ---
// Utilizamos un contador de 16 bits para el refresco (aprox 762 Hz con reloj de 50MHz)
reg [15:0] refresh_counter;
always @(posedge clk or posedge reset) begin
    if (reset) refresh_counter <= 16'd0;
    else refresh_counter <= refresh_counter + 16'd1;
end

// Tomamos los 2 bits más significativos para seleccionar el dígito actual
wire [1:0] mux_sel = refresh_counter[15:14];
wire [3:0] current_bcd;
wire [3:0] uni_h
wire [3:0] dec_h

// Si uni_h y dec_h son 0 se les asigna 1 y 2 respectivamente, else se les asigna el valor que se tienen guaradado en bcd
assign uni_h = (bcd[2] == 4'b0 && bcd[3] == 4'b0) ? 4'b1 : bcd[2];
assign dec_h = (bcd[2] == 4'b0 && bcd[3] == 4'b0) ? 4'b2 : bcd[3];

// Multiplexor de BCD (Dataflow)
assign current_bcd = (mux_sel == 2'b00) ? bcd[0] : // Unidades minuto
                     (mux_sel == 2'b01) ? bcd[1] : // Decenas minuto
                     (mux_sel == 2'b10) ? uni_h[2] : // Unidades hora
                                          dec_h[3];  // Decenas hora

  
// Selector de dígito (Cátodo común = 0 enciende el dígito correspondiente) (Dataflow)
assign dig_sel = (mux_sel == 2'b00) ? 4'b1110 : // Activa display 0
                 (mux_sel == 2'b01) ? 4'b1101 : // Activa display 1
                 (mux_sel == 2'b10) ? 4'b1011 : // Activa display 2
                                      4'b0111;  // Activa display 3

// --- DECODIFICADOR BCD A 7 SEGMENTOS (Dataflow) ---
// Formato de salida: 7'b a_b_c_d_e_f_g (Cátodo común = 1 enciende el segmento)
assign seg = (current_bcd == 4'h0) ? 7'b1111110 : // 0
             (current_bcd == 4'h1) ? 7'b0110000 : // 1
             (current_bcd == 4'h2) ? 7'b1101101 : // 2
             (current_bcd == 4'h3) ? 7'b1111001 : // 3
             (current_bcd == 4'h4) ? 7'b0110011 : // 4
             (current_bcd == 4'h5) ? 7'b1011011 : // 5
             (current_bcd == 4'h6) ? 7'b1011111 : // 6
             (current_bcd == 4'h7) ? 7'b1110000 : // 7
             (current_bcd == 4'h8) ? 7'b1111111 : // 8
             (current_bcd == 4'h9) ? 7'b1111011 : // 9
                                     7'b0000000 ; // Apagado por defecto

endmodule
