`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 01:14:52
// Design Name: 
// Module Name: speed
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module speed(

               input  wire         clk,
               input  wire  [4:0]  turn,
               input  wire         pwm_r,
               input  wire  [1:0]       park,
               output reg          pwm1, pwm2

    );
    
    reg i;
    integer j;
    integer s ;
    integer r;
    
    initial
    begin
     r = 0;
     s = 50;
     i = 0;
     j = 0;
     end

always@(posedge clk)
begin
if (j >=8000000) j <= 0;
else if(j == 1)
begin
j = j+1;
i = 1;
end
else if(j == 100)
begin
j = j+1;
i = 0;
end
else j = j+1 ;
end

always @( posedge i)
begin
   
   if(park == 2'b10 || park == 2'b11 || park == 2'b01) s <= 50;
   else if(s < 30)        s <= 30;
   else if(s > 100)   s <= 100;
   else
   begin
  case(turn)
     5'b01100:    s <= s - 1 ;
     5'b00110:    s <= s - 1 ;
     5'b00111:    s <= s - 10;
     5'b11100:    s <= s - 10;
     5'b11000:    s <= 40    ;
     5'b00011:    s <= 40    ;
     5'b00100:    s <= s + 15 ;
     5'b01110:    s <= s + 10 ;
     5'b00001:    s <= 50    ;
     5'b10000:    s <= 50    ;
     5'b11111:    s <= 50    ;
     5'b00000:    s <= s + 10  ;
     default :             ;
   endcase
  end
  
end

    
always @(posedge clk )
begin
       if(pwm_r == 1)
         begin
           r = r+1;
           
           case(r)
             100:  r <= 0;
               1:  begin
                      pwm1 <= 1;
                      pwm2 <= 1;                          
                   end
               s:  begin
                      pwm1 <= 0;
                      pwm2 <= 0;                          
                   end
         default:             ;
         endcase
       end
         
          

else 
begin

            pwm1 <= 0;
            pwm2 <= 0;
end

end
    
    
    
endmodule
