module clockss
(
    input clk,          // Reloj principal (50MHz)
    input reset,        // Botón de reinicio (Activo en bajo / 0)
    input pause,        // Interruptor de pausa
    output [3:0] dig_sel, // Activa qué pantalla encender (Dígitos 1 al 4)
    output [6:0] seg      // Enciende los LEDs físicos (Segmentos a-g)
);

// --- 1. MEMORIA DEL RELOJ ---
reg [3:0] bcd [0:3];     // bcd[0]=min_u, bcd[1]=min_t, bcd[2]=hr_u, bcd[3]=hr_t
reg [31:0] clk_divider;  // Cuenta para 1 segundo
reg [5:0] sec;           // Cuenta hasta 59 segundos

// --- 2. MEMORIA PARA LA PANTALLA (MUX Y DECODIFICADOR) ---
reg [16:0] refresh_counter; // Contador rápido para alternar pantallas
reg [3:0] display_activo;   // Variable temporal para el dig_sel
reg [3:0] numero_actual;    // Variable que le pasamos al traductor de LEDs
reg [6:0] leds;             // Variable temporal para los segmentos

// Conexión de variables temporales a los pines físicos de salida
assign dig_sel = display_activo;
assign seg = leds;

// --- 3. BANDERAS DE TIEMPO ---
wire tick_1hz   = (clk_divider == 32'd49999999);     // 1 segundo
wire tick_1min  = (tick_1hz   && sec == 6'b111011);  // 59 seg
wire tick_10min = (tick_1min  && bcd[0] == 4'b1001); // 9 min
wire tick_1hr   = (tick_10min && bcd[1] == 4'b0101); // 50 min

// --- 4. CONTADOR DE SEGUNDOS ---
// Cambiamos a negedge porque tu botón manda 0 al presionarse
always @(posedge clk or negedge reset) begin
    if (!reset) begin // Si el botón manda 0, reinicia
        clk_divider <= 32'd0;
        sec         <= 6'b000000;
    end else if (!pause) begin
        if (tick_1hz) begin
            clk_divider <= 32'd0;
            if (sec == 6'b111011) begin
                sec <= 6'b000000; // Reinicia a 0
            end else begin
                sec <= sec + 6'b000001; // Suma 1
            end
        end else begin
            clk_divider <= clk_divider + 32'd1;
        end
    end
end

// --- 5. CONTADOR DE MINUTOS Y HORAS ---
always @(posedge clk or negedge reset) begin
    if (!reset) begin // Si el botón manda 0, reinicia
        bcd[0] <= 4'b0000;
        bcd[1] <= 4'b0000;
        bcd[2] <= 4'b0000;
        bcd[3] <= 4'b0000;
    end else if (!pause) begin
        // Unidades de minuto
        if (tick_1min) begin
            if (bcd[0] == 4'b1001) bcd[0] <= 4'b0000;
            else                   bcd[0] <= bcd[0] + 4'b0001;
        end
        // Decenas de minuto
        if (tick_10min) begin
            if (bcd[1] == 4'b0101) bcd[1] <= 4'b0000;
            else                   bcd[1] <= bcd[1] + 4'b0001;
        end
        // Horas
        if (tick_1hr) begin
            if (bcd[3] == 4'b0001 && bcd[2] == 4'b0001) begin // Si son las 11
                bcd[2] <= 4'b0000;
                bcd[3] <= 4'b0000;
            end else if (bcd[2] == 4'b1001) begin             // Si llega a 9
                bcd[2] <= 4'b0000;
                bcd[3] <= bcd[3] + 4'b0001;
            end else begin
                bcd[2] <= bcd[2] + 4'b0001;
            end
        end
    end
end

// --- 6. VELOCIDAD DEL MULTIPLEXOR ---
always @(posedge clk or negedge reset) begin
    if (!reset) begin // Si el botón manda 0, reinicia el barrido
        refresh_counter <= 17'd0;
    end else begin
        refresh_counter <= refresh_counter + 17'd1;
    end
end

// Extraemos los bits más altos para que cuente 00, 01, 10, 11 lentamente
wire [1:0] selector = refresh_counter[16:15];

// --- 7. MULTIPLEXOR (Alterna las pantallas) ---
// Lógica activa en BAJO (0 enciende la pantalla, 1 la apaga)
always @(*) begin
    if (selector == 2'b00) begin
        display_activo = 4'b1110; // Enciende Dígito 1 (Derecha)
        numero_actual  = bcd[0];  // Manda Unidades de Minuto
    end 
    else if (selector == 2'b01) begin
        display_activo = 4'b1101; // Enciende Dígito 2
        numero_actual  = bcd[1];  // Manda Decenas de Minuto
    end 
    else if (selector == 2'b10) begin
        display_activo = 4'b1011; // Enciende Dígito 3
        numero_actual  = bcd[2];  // Manda Unidades de Hora
    end 
    else begin // 2'b11
        display_activo = 4'b0111; // Enciende Dígito 4 (Izquierda)
        numero_actual  = bcd[3];  // Manda Decenas de Hora
    end
end

// --- 8. DECODIFICADOR 7 SEGMENTOS (CORREGIDO) ---
// Orden de los bits: 7'b(g)(f)(e)(d)(c)(b)(a)
// Lógica POSITIVA (1 enciende el LED, 0 lo apaga)
always @(*) begin
    if      (numero_actual == 4'b0000) leds = 7'b0111111; // Dibuja 0
    else if (numero_actual == 4'b0001) leds = 7'b0000110; // Dibuja 1
    else if (numero_actual == 4'b0010) leds = 7'b1011011; // Dibuja 2
    else if (numero_actual == 4'b0011) leds = 7'b1001111; // Dibuja 3
    else if (numero_actual == 4'b0100) leds = 7'b1100110; // Dibuja 4
    else if (numero_actual == 4'b0101) leds = 7'b1101101; // Dibuja 5
    else if (numero_actual == 4'b0110) leds = 7'b1111101; // Dibuja 6
    else if (numero_actual == 4'b0111) leds = 7'b0000111; // Dibuja 7
    else if (numero_actual == 4'b1000) leds = 7'b1111111; // Dibuja 8
    else if (numero_actual == 4'b1001) leds = 7'b1101111; // Dibuja 9
    else                               leds = 7'b0000000; // Apagado
end

endmodule
