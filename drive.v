module drive( 
                     input   wire             clk,
                     input   wire             drive_en,
                     input   wire   [4:0]  turn, 
                     input   wire   [1:0]  park,
                     output  reg    [1:0]  run_d,
                     output  reg              pwm_r,   //control driving
                     output  reg              pwm_t,                    //control  ing
                     output  reg              park_f                     //park finish
);

  integer   i = 0;
  integer   j = 0;

  integer  s = 15;         //control pwm_t's duty cycle
  parameter t = 2400;//clk_cycle*t = 0.1ms (f = 24MHz)
  
  initial 
    begin
      run_d     = 2'b00;
      pwm_r = 1'b0;
      pwm_t   = 1'b0;
      park_f    = 1'b1;
    end
  
  always @ (posedge clk)  //reset
    begin  
      if (!drive_en)
          begin
          
                   if (park == 2'b10)           //back into the treasury      
                   begin
                                      run_d    <= 2'b10;
                                  if (j >= 50000*t)   
                                            begin
                                              j  <=  50000*t;
                                              park_f <= 0;
                                            end   
                                 else 
                                           begin                       
                                              j  <= j+1;   
                                        
                                              case(j)
                                                11000*t:  s <=  5;              //start to turn
                                                10000*t: pwm_r <= 1;    //start to back off
                                                              
                                                43000*t: 

                                                               pwm_r <= 0;       // stop
                                                               
                                                36500*t:  s <= 15;             //turn back
                                                default:   ; 
                                             endcase
                                          end 
                   end 
                   
                   
                   
                     else if (park == 2'b01)           //back into the treasury qingxie     
                     begin
                                      run_d    <= 2'b10;
                                  if (j >= 50000*t)   
                                            begin
                                              j  <=  50000*t;
                                              park_f <= 0;
                                            end   
                                 else 
                                           begin                       
                                              j  <= j+1;   
                                        
                                              case(j)
                                                11000*t:  s <=  5;              //start to turn
                                                10000*t: pwm_r <= 1;    //start to back off
                                                28000*t:  s <= 15;             //turn back               
                                                42000*t:   pwm_r <= 0;       // stop
                                                             
                                               
                                                default:   ; 
                                             endcase
                                          end 
                   end 
                   
                   
                    else if (park == 2'b11)           //back into the treasury     pingxing 
                   begin
                                      run_d    <= 2'b10;
                                  if (j >= 50000*t)   
                                            begin
                                              j  <=  50000*t;
                                              park_f <= 0;
                                            end   
                                 else 
                                           begin                       
                                              j  <= j+1;   
                                        
                                              case(j)
                                                11000*t:  s <=  25;              //start to turn
                                                10000*t:  pwm_r <= 1;    //start to back off         
                                                22000*t:  s <= 15;             //turn back
                                                27000*t:  s <= 5;
                                                43000*t:  pwm_r <= 0;       // stop
                                                42000*t:  s <= 15;
                                                default:   ; 
                                             endcase
                                          end 
                   end 
                   
                   
  
                   else                               // stop
                   begin
                                  run_d     <= 2'b11;
                                  pwm_r <= 1'b0;

                                  park_f    <= 1'b1;
                                       j    <=   0;
                                     
                   end
          
          end 


      else 
      begin
          run_d   <= 2'b01;
          pwm_r <= 1'b1;
          
          case (turn)
            5'b01100:   s <= 14;  // turn left
            5'b00110:   s <= 16;  //turn right
            5'b11100:   s <= 13;   //bigturn left
            5'b11000:   s <= 10;     // undo
            5'b10000:   s <= 5;
            5'b01111:   s <= 25;
            5'b00111:   s <= 17; //bigturn left
            5'b00011:   s <= 21;
            5'b00001:   s <= 25;   
            
            
            default:   s <= 15;    // don't turn
          endcase
        end         
      end


  
  
  always@( posedge clk)      // control turning
     begin
               if (i >= 200*t)  i <= 0;  // generate the pwm
        
               else if (i == 0)
                 begin
                   pwm_t <= 1;
                   i <= i+1;
                 end
        
               else if (i == s*t)
                 begin 
                   pwm_t <=0;
                   i <= i+1;
                 end
        
               else  i <= i+1;    
               
     end 
     
     
     

endmodule
