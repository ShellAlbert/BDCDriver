module upload_data(clk,reset,tx_pulse,up_bytes);
input clk;
input reset;

output reg tx_pulse;
output reg [7:0] up_bytes;

//55 AA cmd data1 data2 checksum  //6 bytes in total.
//55 AA 01 02 03 FF 

//we use a counter to drive the operations.
//The counter is count from 0 to N.
//when counter=M1, output one-shot tx_pulse and up_bytes.
//when counter=M2, output another one-shot tx_pulse and another up_bytes.
//attention here, the clk is baudrate clock, 9600bps=9.6khz.
//counter from 0
//when counter=100, output tx_pulse and up_bytes[0].
//this will take 10 cycle period due to the 9600,8N1 configration.(1 start bit,8 data bits,1 stop bit.)
//so here the next minimum trigger is 100+10=110. but here we use 100+10+10=120.
//when counter=120, output tx_pulse and up_bytes[1].
//when counter=140, output tx_pulse and up_bytes[2].
//when counter=160, output tx_pulse and up_bytes[3].
//when counter=180, output tx_pulse and up_bytes[4].
//when counter=200, output tx_pulse and up_bytes[5].
//when counter=220, reset.
reg [7:0] counter; //2^8-1=255.
always@(posedge clk or posedge reset)
begin
	if(reset) begin
				counter<=8'd0;
			  end
	else begin
			if(counter==8'd220)
				counter<=8'd0;
			else
				counter<=counter+1'b1;
		 end
end

always@(posedge clk or posedge reset)
begin
	if(reset) begin
				tx_pulse<=1'b0;
				up_bytes<=8'd0;
			  end
	else begin
			case(counter)
				8'd100: begin tx_pulse<=1'b1; up_bytes<=8'h0x55; end
				8'd120: begin tx_pulse<=1'b1; up_bytes<=8'h0xaa; end
				8'd140: begin tx_pulse<=1'b1; up_bytes<=8'h0x01; end
				8'd160: begin tx_pulse<=1'b1; up_bytes<=8'h0x02; end
				8'd180: begin tx_pulse<=1'b1; up_bytes<=8'h0x03; end
				8'd200: begin tx_pulse<=1'b1; up_bytes<=8'h0xff; end
				default: begin tx_pulse<=1'b0; up_bytes<=8'h0x00; end
			endcase
		 end
end
endmodule