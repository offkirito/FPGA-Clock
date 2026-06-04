module clockss
(
    input clk, reset, pause,        
    output [3:0] dig_sel, [6:0] seg // dig_sel seleccion el display que se va a prender y seg son los segemntos como (a, b, c, d, e, f, g)
);


reg [3:0] bcd [0:3];     // bcd[0]=min_u, bcd[1]=min_t, bcd[2]=hr_u, bcd[3]=hr_t
reg [31:0] clk_divider;  // Cuenta para un segundo
reg [5:0] sec;           // Cuenta hasta los 60 segundos para mandar el tick al minutos

reg [16:0] refresh_counter; // Contador rápido para alternar pantallas
reg [3:0] display_activo;   // Variable temporal para el dig_sel
reg [3:0] numero_actual;    // Variable que le pasamos al traductor de LEDs
reg [6:0] leds;             // Variable temporal para los segmentos

// Assignacion de las variables temporales a las salidas finales
assign dig_sel = display_activo;
assign seg = leds;


wire tick_1hz   = (clk_divider == 32'd99999);     // Hace el tick de 1 segundo
wire tick_1min  = (tick_1hz   && sec == 6'b111011);  // Condicional para hacer un minuto
wire tick_10min = (tick_1min  && bcd[0] == 4'b1001); // Condicional hecho para separar los digitos decimales para luego mostralos
    wire tick_1hr   = (tick_10min && bcd[1] == 4'b0101); // Cuenta 50 minutos porque esta seperado cada digito decimal


// Contador de segundos
always @(posedge clk or negedge reset) begin
    if (!reset) begin // Si el botón manda 0 se reinicia (haciendolo por el push button del fpga)
        clk_divider <= 32'd0; // cada que se manda un tick de 1hz el contador cl clk_divider
        sec         <= 6'b000000;
    end else if (!pause) begin // si el switch de pausa no es 0 sigue el reloj
        if (tick_1hz) begin
            clk_divider <= 32'd0;
            if (sec == 6'b111011) begin
                sec <= 6'b000000;
            end else begin // contador de los segundos
                sec <= sec + 6'b000001;
            end
        end else begin // contador para un tick de un segundo
            clk_divider <= clk_divider + 32'd1;
        end
    end
end

// Contador de minutos y horas
always @(posedge clk or negedge reset) begin
    if (!reset) begin // Si el botón manda 0 se reinicia
        bcd[0] <= 4'b0000;
        bcd[1] <= 4'b0000;
        bcd[2] <= 4'b0000;
        bcd[3] <= 4'b0000;
    end else if (!pause) begin
        // Cada tick de un minuto hecho por el assign declarados se guarda en el espacio 1 del arreglo,
        if (tick_1min) begin
            if (bcd[0] == 4'b1001) bcd[0] <= 4'b0000;
            else                   bcd[0] <= bcd[0] + 4'b0001;
        end
        // Tick de 10 minutos para guardar el segundo digito en el display
        if (tick_10min) begin
            if (bcd[1] == 4'b0101) bcd[1] <= 4'b0000;
            else                   bcd[1] <= bcd[1] + 4'b0001;
        end
        // Horas
        if (tick_1hr) begin
            if (bcd[3] == 4'b0001 && bcd[2] == 4'b0001) begin // si son las 11 y 59 minutos y segundos se reinicia
                bcd[2] <= 4'b0000;
                bcd[3] <= 4'b0000;
            end else if (bcd[2] == 4'b1001) begin
                bcd[2] <= 4'b0000;
                bcd[3] <= bcd[3] + 4'b0001;
            end else begin
                bcd[2] <= bcd[2] + 4'b0001;
            end
        end
    end
end

// Hicimos otro delimitador de tiempo ahora de 762 Hz que cuenta 17 bits y no ponemos que se haga 0 y confiamos que simplemente el carry out se pierda en el hardware, ahorrandos lineas
always @(posedge clk or negedge reset) begin
    if (!reset) begin // Si el botón manda 0, reinicia el barrido
        refresh_counter <= 17'd0;
    end else begin
        refresh_counter <= refresh_counter + 17'd1;
    end
end

// olo buscamos los 2 bits mas alto para de limitar el contador del display
wire [1:0] selector = refresh_counter[16:15];

// Creamos esto dos wire para hacer que el front end cambie dependiendo las variables de bcd
wire [3:0] uni_h;
wire [3:0] dec_h;

// Si uni_h y dec_h son 0 se les asigna 1 y 2 respectivamente, else se les asigna el valor que se tienen guaradado en bcd
    assign uni_h = (bcd[2] == 4'b0 && bcd[3] == 4'b0) ? 4'b0010 : bcd[2];
    assign dec_h = (bcd[2] == 4'b0 && bcd[3] == 4'b0) ? 4'b0001 : bcd[3];
    
// Multiplexor de los digitos
// Logica activa en BAJO, teniendo 4 ditios entonces siendo
always @(*) begin
    if (selector == 2'b00) begin
        display_activo = 4'b1110; // Dsiplay 1 manda el primer digito de minutos
        numero_actual  = bcd[0];  
    end 
    else if (selector == 2'b01) begin
        display_activo = 4'b1101; // Dsiplay 2 manda el primer digito de minutos
        numero_actual  = bcd[1];  
    end 
    else if (selector == 2'b10) begin
        display_activo = 4'b1011; // Dsiplay 1 manda el primer digito de horas
        numero_actual  = uni_h;  
    end 
    else begin // 2'b11
        display_activo = 4'b0111; // Dsiplay 4 manda el 2 digito de horas
        numero_actual  = dec_h;  
    end
end


// Orden de los bits: 7'b(g)(f)(e)(d)(c)(b)(a)
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
