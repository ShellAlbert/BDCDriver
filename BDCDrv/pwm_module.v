(*preserve*) module pwm_module(clk,reset,Start_En_Sig,work_mode,pwm1,pwm2,Done_Sig);
input clk;
input reset;
input Start_En_Sig;
input [3:0] work_mode;
output reg pwm1;
output reg pwm2;
output reg Done_Sig;

//generate 1Hz tick.
//49.152MHz/1Hz=49152000
reg [27:0] counter_1hz;
wire clk_1hz;
reg [3:0] timers_5s;
reg [19:0] updated_threshold/*synthesis preserve*/;
always@(posedge clk or posedge reset)
begin
	if(reset)	begin
					counter_1hz<=28'd0;
					timers_5s<=4'd0;
					updated_threshold<=20'd491520;
				end
	else if(counter_1hz==28'd49152000)	begin
											counter_1hz<=28'd0;
											//last 5s then update threshold to change frequency.
											if(timers_5s==4'd1)	begin
																	timers_5s<=4'd0;
																	if((updated_threshold-20'd200000)>=20'd492) 
																		updated_threshold<=updated_threshold-20'd200000;
																	else
																		updated_threshold<=20'd491520;
																end
											else
												timers_5s<=timers_5s+1'b1;
										end
	else
		counter_1hz<=counter_1hz+1'b1;
end
assign clk_1hz=(counter_1hz==28'd49152000)?1'b1:1'b0;

//generate 100khz.
//49.152MHz/100kHz=491.52
//because counter starts from zero, so threshold value should subtract 1,it's 490.
//490 needs 12bits to store.
//but the frequency now is 100khz/2=50khz.
//so if we want 100khz in real, it should be 490/2=245.
//if we want 50khz, it should be 122.5
//from 100Hz~100KHz.
//49.152Mhz/100Hz=491520
//49.152Mhz/1KHz=49152
//49.152Mhz/100KHz=491.52
reg [19:0] counter;
wire clk_100khz/*synthesis keep*/;
//duty cycle control.
wire duty_cycle_pulse/*synthesis keep*/;

always@(posedge clk or posedge reset)
begin
	if(reset) 
		counter<=12'd0;
	else if(counter==updated_threshold)	
		counter<=12'd0;
	else
		counter<=counter+1'b1;
end
//only valid in one-pulse.
assign clk_100khz=(counter==updated_threshold)?1'b1:1'b0;
//duty cycle,50%.
assign duty_cycle_pulse=(counter==updated_threshold/2)?1'b1:1'b0;

//we only output 100 pulse of 100khz.
//f=100KHz,t=1/f=1/100khz=0.000,01S=0.01mS=10uS
//100khz, i+1.
//1s=1Hz,0.5S=2Hz,0.1S=10Hz.
//100KHz/1Hz=100,000
//100KHz/10Hz=10,000
//100kHz/50Hz=2000,1/50Hz=0.02S=20mS
//100kHz/100Hz=1000,1/100Hz=0.01S=10mS
parameter i_THRESHOLD_Tiny=28'd1000;//10uS*1000=10mS
parameter i_THRESHOLD_Small=28'd2000;//10uS*2000=20mS
parameter i_THRESHOLD_Normay=28'd5000;//10uS*5000=50mS
parameter i_THRESHOLD_Large=28'd10000;//10uS*10000=100mS
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
							case(work_mode)
								4'd0: begin //tiny step mode.
										if(i==i_THRESHOLD_Tiny) begin
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
								4'd1: begin //Small step mode.
										if(i==i_THRESHOLD_Small) 	begin
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
								4'd2: begin //Normal step mode.
										if(i==i_THRESHOLD_Normay) 	begin
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
								4'd3: begin //Large step mode.
											if(i==i_THRESHOLD_Normay) 	begin
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
								4'd15: 	begin //continous run mode.
												if(clk_100khz)
													pwm2<=1'b1;
												else if(duty_cycle_pulse)
													pwm2<=1'b0;
										end
								default: begin 
											pwm2<=1'b0;
								  		 end
							endcase
						end
	else begin
			pwm1<=1'b0;
			pwm2<=1'b0;
			Done_Sig<=1'b0;
	     end
end
endmodule
