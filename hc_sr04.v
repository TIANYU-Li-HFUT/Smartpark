module hc_sr04(
				clk ,
				rst_n ,
				echo ,
				park,
				trig ,
				hc_pwm,
				s_g ,
				s_s ,
				s_b ,
				s_q
);

parameter DATA_W = 14 ;

parameter TIME = 12_000_000;

input clk ;

input rst_n ;

input echo ;
input park;

output trig ;
output hc_pwm;

output[ 3:0] s_g;
output[ 3:0] s_s;
output[ 3:0] s_b;
output[ 3:0] s_q;

wire trig ;
reg hc_pwm;
reg [ 3:0]s_g ;
reg [ 3:0]s_s ;
reg [ 3:0]s_b ;
reg [ 3:0]s_q ;
wire [ 1:0]park ;

reg [DATA_W-1:0]distance;

reg [25:0]cnt0 ;
reg [20:0]h_cnt ;

reg echo_2 ;
reg echo_1 ;

wire add_cnt0;
wire end_cnt0;

wire flag_h ;
wire flag_l ;
 parameter t = 2400;//clk_cycle*t = 0.1ms (f = 24MHz)
 integer s = 15;
 integer   i = 0;

 
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
	    cnt0 <= 0;

	end
	else if(add_cnt0)begin
	    if(end_cnt0)
	        cnt0 <= 0;
	    else
	        cnt0 <= cnt0 +1'b1;
	end
end

assign add_cnt0 = 1;
assign end_cnt0 = add_cnt0&& cnt0 == TIME - 1;
assign trig =(cnt0>=240&&cnt0<480)?1:0;    //在一个1s中第二个10us产生10us的高电平

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)begin
	    echo_1 <= 0;
	    echo_2 <= 0;
	end
	else begin
	    echo_1 <= echo  ;
	    echo_2 <= echo_1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
	    h_cnt <= 0;
	end
	else if(add_h_cnt)begin
	    if(end_h_cnt)
	        h_cnt <= 0;
	    else
	        h_cnt <= h_cnt +1;
	end
	else if(end_cnt0)begin
	    h_cnt <= 0;
	end
end

assign add_h_cnt = echo_2;  //echo为高开始计数
assign end_h_cnt = 0 ;

always @(posedge clk or negedge rst_n)begin
if(rst_n==1'b0)begin
        distance <= 0;
    end
    else if(add_cnt0 && cnt0 ==11_000_000-1)begin    //1s结束前返回值
        distance <= h_cnt*71/10000;
    end
end

 always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        s_g <= 0;
    end
    else begin
        s_g <= distance%10;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        s_s <= 0;
    end
    else begin
        s_s <= (distance/10)%10;
    end
end  

always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        s_b <= 0;
    end
    else begin
        s_b <= (distance/100)%10;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        s_q <= 0;
    end
    else begin
        s_q <= (distance/1000)%10;
    end
end



always@( posedge clk)
begin
  if (park == 2'b00) s <= 15;
  else if (park == 2'b11) s <= 5;
  else  s <= 25;

  
  
end  
 
always@( posedge clk)      // control turning
     begin
               if (i >= 200*t)  i <= 0;  // generate the pwm
        
               else if (i == 0)
                 begin
                   hc_pwm <= 1;
                   i <= i+1;
                 end
        
               else if (i == s*t)
                 begin 
                   hc_pwm <=0;
                   i <= i+1;
                 end
        
               else  i <= i+1;    
               
     end 

endmodule