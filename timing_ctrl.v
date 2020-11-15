/*
 * @Author: FDC
 * @Date: 2020-10-26 10:10:09
 * @LastEditTime: 2020-10-26 11:38:16
 * @LastEditors: Please set LastEditors
 * @Description: Timer
 * @FilePath: \rtl\timing_ctrl.v
 */
 module timing(
    input clk,
    input rst,

    input valid,
    input [3:0] strb,
    input [2:0] addr,
    input [31:0] data_i,
    output reg ready,
    output reg irq
 );

 reg timer_en;
 reg [31:0] TIMER_CNT_MAX;
 reg [31:0] timer_cnt;

 always @(posedge clk)
    if(rst)
        ready <= 1'b0;
    else if(valid & !ready & (addr<=3'h4))
        ready <= 1'b1;
    else 
        ready <= 1'b0;
    
 always @(posedge clk)
    if(rst)
        timer_en <= 1'b0;
    else if(valid & strb[0] & (addr==3'h0))
        timer_en <= data_i[0];

 always @(posedge clk)
    if(rst)
        TIMER_CNT_MAX <= 32'd50;
    else if(valid & (strb==4'hF) & (addr==3'h4))
        TIMER_CNT_MAX <= data_i;

 always @(posedge clk)
    if(rst)
        timer_cnt <= 32'd0;
    else if(timer_en & (timer_cnt<TIMER_CNT_MAX))
        timer_cnt <= timer_cnt+1'b1;
    else 
        timer_cnt <= 32'h0;
    
 always @(posedge clk)
    if(rst)
        irq <= 1'b0;
    else if(timer_cnt==TIMER_CNT_MAX)
        irq <= 1'b1;
    else
        irq <= 1'b0;
        
 endmodule
