`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/6 10:02:11
// Design Name:LTY 
// Module Name: rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:  rewrite rx\ fix some bug
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rx
(
    input			  clock,
    input             reset,
    
    input             uart_rxd,
    output  reg       uart_done,
    output  reg [7:0] uart_data
);
    
//parameter define
parameter  CLK_FREQ = 24000000;
parameter  UART_BPS = 9600;
localparam BPS_CNT  = CLK_FREQ/UART_BPS;


reg [1:0]  uart_rxd_sync;
reg [15:0] clk_cnt;
reg [ 3:0] rx_cnt;
reg        rx_flag;
reg [ 7:0] rxdata;

wire       start_flag;


always @(posedge clock or negedge reset)
begin 
    if (reset==0)
        uart_rxd_sync <= 2'b00;
    else
        uart_rxd_sync <= {uart_rxd_sync[0],uart_rxd};
end

assign  start_flag = (uart_rxd_sync == 2'b10);


always @(posedge clock or negedge reset)
begin
    if (reset==0)
        rx_flag <= 1'b0;
    else
	begin
        if(start_flag)
            rx_flag <= 1'b1;
        else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))
            rx_flag <= 1'b0;
        else
            rx_flag <= rx_flag;
    end
end


always @(posedge clock or negedge reset)
begin
    if (reset==0)
	begin
        clk_cnt <= 16'd0;
        rx_cnt  <= 4'd0;
    end
    else if ( rx_flag )
	begin
            if (clk_cnt < BPS_CNT - 1)
			begin
                clk_cnt <= clk_cnt + 1'b1;
                rx_cnt  <= rx_cnt;
            end
            else
			begin
                clk_cnt <= 16'd0;
                rx_cnt  <= rx_cnt + 1'b1;
            end
    end
	else
	begin
		clk_cnt <= 16'd0;
		rx_cnt  <= 4'd0;
	end
end


always @(posedge clock or negedge reset)
begin 
    if (reset==0)
        rxdata <= 8'd0;
    else if(rx_flag)
        if (clk_cnt == BPS_CNT/2)
		begin
            case ( rx_cnt )
             4'd1 : rxdata[0] <= uart_rxd_sync[1];
             4'd2 : rxdata[1] <= uart_rxd_sync[1];
             4'd3 : rxdata[2] <= uart_rxd_sync[1];
             4'd4 : rxdata[3] <= uart_rxd_sync[1];
             4'd5 : rxdata[4] <= uart_rxd_sync[1];
             4'd6 : rxdata[5] <= uart_rxd_sync[1];
             4'd7 : rxdata[6] <= uart_rxd_sync[1];
             4'd8 : rxdata[7] <= uart_rxd_sync[1];
             default:;
            endcase
        end
        else
            rxdata <= rxdata;
    else
        rxdata <= 8'd0;
end


always @(posedge clock or negedge reset)
begin
    if (reset==0)
	begin
        uart_data <= 8'd0;
        uart_done <= 1'b0;
    end
    else if(rx_cnt == 4'd9)
	begin
        uart_data <= rxdata;
        uart_done <= 1'b1;
    end
    else
	begin
        uart_data <= 8'd0;
        uart_done <= 1'b0;
    end
end

endmodule