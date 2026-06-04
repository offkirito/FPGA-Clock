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
