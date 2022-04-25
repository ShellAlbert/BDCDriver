module BDCDrv(clk,rxd,led1,led2,txd,txclkx4,rxclkx4,fifo_full);
// Keep the Entity of Wire  /*synthesis keep*/;
// Keep the Entity of Register /*synthesis preserve*/;
// sometimes above two options are not valid, try this /*synthesis noprune*/; 
input clk;
input rxd;

output led1;
output led2;
output txd;
output txclkx4;
output rxclkx4;
output fifo_full;

//generate reset signal (Active HIGH).
wire reset;
power_on_reset u1 (.clk(clk),.reset(reset));
//clk1hz(.clk(clk),.reset(reset),.clk_1hz(txclk));

//use 1Hz (in led_drive module to generate tx data dynamically.
//cause we cannot define reg[7:0]=8'd55 outside of always.
//wire [7:0] data_out;
//led_drive u2 (.clk(clk),.reset(reset),.led1(led1),.led2(led2),.data_out(data_out));
assign led1=0;
assign led2=0;
//pwm_driver u3(.clk(clk),.reset(reset),.out1(out1),.out2(out2));


//1.generate txclk & rxclk.
wire txclk;
wire rxclk;
baudrate_generate u4(.clk(clk),.reset(reset),.txclk(txclk),.rxclk(rxclk),.txclkx4(txclkx4),.rxclkx4(rxclkx4));
//2.generate single pluse in txclk.
//wire pulse_1hz;
//single_pulse u5(.clk(txclk),.reset(reset),.pulse_out(pulse_1hz));
//3.tx data.
//wire txd;
//wire busy;
//uart_tx u6(.clk(txclk),.reset(reset),.start(pulse_1hz),.data_in(data_out),.txd(txd),.done(done),.busy(busy));


//upload data via UART.
/*
wire tx_pulse;
wire [7:0] up_bytes;
upload_data upload_data_u1(.clk(txclk),.reset(reset),.tx_pulse(tx_pulse),.up_bytes(up_bytes));
wire done;
wire busy;
uart_tx u6(.clk(txclk),.reset(reset),.start(tx_pulse),.data_in(up_bytes),.txd(txd),.done(done),.busy(busy));
*/

//receive data via UART.
wire [7:0] rx_data;
wire rx_done;
wire rx_busy;
wire rx_err/*synthesis keep*/;
uart_rx u11(.clk(rxclk),.reset(reset),.serial_in(rxd),.parallel_out(rx_data),.done(rx_done),.busy(rx_busy),.err(rx_err));

//save data to fifo.
wire fifo_full;
wire fifo_empty;
rx_fifo u13(.clk(clk),.reset(reset),.put_pulse(rx_done),.put_byte(rx_data),.full(fifo_full),.empty(fifo_empty));

//sync rx_done to txclk.
wire tx_start;
rxclk_sync_to_txclk u12(.clk(clk),.reset(reset),.rx_done(rx_done),.txclk(txclk),.tx_start(tx_start));

wire tx_done;
wire tx_busy;
uart_tx u6(.clk(txclk),.reset(reset),.start(tx_start),.data_in(rx_data),.txd(txd),.done(tx_done),.busy(tx_busy));

assign rx_data_stp=rx_data;
endmodule