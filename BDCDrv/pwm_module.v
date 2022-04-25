module pwm_module(clk,reset,Start_En_Sig,pwm1,pwm2,Done_Sig);
input clk;
input reset;
input Start_En_Sig;
output reg pwm1;
output reg pwm2;
output reg Done_Sig;

//generate 100khz.
//49.152MHz/100kHz=491.52
//because counter starts from zero, so threshold value should subtract 1,it's 490.
//490 needs 12bits to store.
//but the frequency now is 100khz/2=50khz.
//so if we want 100khz in real, it should be 490/2=245.
reg [11:0] counter;
wire clk_100khz/*synthesis keep*/;
always@(posedge clk or posedge reset)
begin
	if(reset)
		counter<=12'd0;
	else if(counter==12'd245)
				counter<=12'd0;
	else
			counter<=counter+1'b1;
end
//only valid in one-pulse.
assign clk_100khz=(counter==12'd245)?1'b1:1'b0;


//duty cycle control.
reg [10:0] duty_cycle/*synthesis keep*/;
wire duty_cycle_pulse/*synthesis keep*/;
always@(posedge clk or posedge reset)
begin
	if(reset)
		duty_cycle<=11'd0;
	else if(clk_100khz)
		duty_cycle<=11'd0;
	else
		duty_cycle<=duty_cycle+1'b1;
end
assign duty_cycle_pulse=(duty_cycle==11'd180)?1'b1:1'b0;

//we only output 100 pulse of 100khz.
//100khz, i+1.
//1s=1Hz,0.5S=2Hz,0.1S=10Hz.
//100KHz/1Hz=100,000
//100KHz/10Hz=10,000
//100kHz/50Hz=2000,1/50Hz=0.02S=20mS
//100kHz/100Hz=1000,1/100Hz=0.01S=10mS
parameter i_THRESHOLD=28'd1000;
reg [27:0] i;
always@(posedge clk or posedge reset)
begin
	if(reset) begin
					pwm1<=1'b0;
					pwm2<=1'b0;
					Done_Sig<=1'b0;
					i<=12'd0;
			  end
	else if(Start_En_Sig) begin
							if(i==i_THRESHOLD) begin
												i<=12'd0;
												pwm2<=1'b0;
												Done_Sig<=1'b1;
										    end
							else begin
									
									if(clk_100khz)
											begin pwm2<=1'b1; i<=i+1'b1; end
									else if(duty_cycle_pulse)
											begin pwm2<=1'b0; end
								 end	
			              end
	else begin
			pwm1<=1'b0;
			pwm2<=1'b0;
			Done_Sig<=1'b0;
	     end
end
endmodule
