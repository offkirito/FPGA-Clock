module BinaryDecimal7Segment(
	bcd,
	Segmento
	);
	
	input [3:0] bcd; //Inicializando bcd como input de 4 bits
	output[6:0] Segmento; //initializing Segmento como salida de 7 bits
	
	wire [6:0] Segmento; //initializing bcd signal as wires
	
   assign Segmento[0]= ((~bcd[3])&(~bcd[2])&(~bcd[1])&bcd[0]) | ((~bcd[3])&bcd[2]&(~bcd[1])&(~bcd[0])); //Segmento A
	
	assign Segmento[1]= ((~bcd[3])&bcd[2]&(~bcd[1])&bcd[0]) | ((~bcd[3])&bcd[2]&bcd[1]&(~bcd[0])); //Segmento B
	
	assign Segmento[2]= ((~bcd[3])&(~bcd[2])&bcd[1]&(~bcd[0])); //Segmento C

	assign Segmento[3] = ((~bcd[3])&(~bcd[2])&(~bcd[1])&bcd[0]) | ((~bcd[3])&bcd[2]&(~bcd[1])&(~bcd[0])) | ((~bcd[3])&bcd[2]&bcd[1]&bcd[0]); //Segmento D
	
	assign Segmento[4] = ((~bcd[3])&bcd[0]) | ((~bcd[3])&bcd[2]&(~bcd[1])) | (~(bcd[2])&(~bcd[1])&bcd[0]); //Segmento E
	
	assign Segmento[5] = ((~bcd[3])&(~bcd[2])&bcd[0]) | ((~bcd[3])&(~bcd[2])&bcd[1]) | ((~bcd[3])&bcd[1]&bcd[0]); //Segmento F
	
	assign Segmento[6] = ((~bcd[3])&(~bcd[2])&(~bcd[1]))|((~bcd[3])&bcd[2]&bcd[1]&bcd[0]); //Segmento G
	
	endmodule
