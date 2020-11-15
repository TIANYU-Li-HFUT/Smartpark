/*
 * @Author: FangDecheng
 * @Date: 2020-11-01 20:36:56
 * @LastEditTime: 2020-11-01 20:41:26
 * @LastEditors: Please set LastEditors
 * @Description: main
 * @FilePath: \src\main.c
 */
#include "firmware.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "string.h"
#include "global.h"

//############################# function declare #######################################################################
//#####################################################################################################################
//reference sample:
//write_reg(DriveBaseAddr,0x1);          drive_en = 1
//write_reg(DriveBaseAddr+0x4,0x5);      turn = 0x5
//write_reg(DriveBaseAddr+0x8,0x0);      park = 0x0
//i = read_reg(TraceBaseAddr);           i = drive_en
//delay(DELAYUS * 1000000);              delay 2s
//write_reg(AudioBaseAddr ,0x );

int main() {

	int i;
	int count = 0;  //counter value
	int sel = 0;    // stall selection
    int j;          //distance




 /*   while(1)
    {
    	i = read_reg(TraceBaseAddr);
    	if(i == 0x1f)   write_reg(DriveBaseAddr,0x0);
    	else write_reg(DriveBaseAddr+0x4,i);
    }
*/
//###########################################  select the route  ##########################################################################
    while(1)
    {
    	i = read_reg(BlueTeechBaseAddr);



        switch(i)                       //select the route
          {
             case 0x41: sel = 1;write_reg(AudioBaseAddr ,0x1 ); break;
             case 0x42: sel = 2;write_reg(AudioBaseAddr ,0x2 ); break;
             case 0x43: sel = 3;write_reg(AudioBaseAddr ,0x3 ); break;
             case 0x44: sel = 4;write_reg(AudioBaseAddr ,0x4 ); break;
             case 0x45: sel = 5;write_reg(AudioBaseAddr ,0x5 ); break;
             case 0x46: sel = 6;write_reg(AudioBaseAddr ,0x6 ); break;
             case 0x47: sel = 7;write_reg(AudioBaseAddr ,0x7 ); break;
             case 0x48: sel = 8;write_reg(AudioBaseAddr ,0x8 ); break;

             default:                 ;

         }
        if ((sel>0)&&(sel<9)) break;

    }


//############################################## drive in #######################################################################//




    write_reg(DriveBaseAddr+0x4,0x1f);
    delay(DELAYUS * 500000);
    write_reg(DriveBaseAddr,0x1);          //drive_en = 1



	while(sel < 4 && count < sel + 4)                 //drive to the stall
	{
		i = read_reg(TraceBaseAddr);
		j = read_reg(HcBaseAddr);         // read the data of ultrasonic



		if(j < 0x0600)
					{
					    write_reg(DriveBaseAddr,0x0);
					    write_reg(AudioBaseAddr ,0xb );
					    continue;


				    }
				else
				{


			  write_reg(DriveBaseAddr,0x1);



		      if(i == 0x0)   //00000
			     {
			        count = count + 1;
			        //write_reg(DriveBaseAddr+0x4,0x0);      //turn = 0
			        //delay(DELAYUS * 100000);               //0.15s
			        while(1)
			        {
			        	i = read_reg(TraceBaseAddr);
			        	if(i == 0) continue;
			        	else break;
			        }

			     }


		     else  write_reg(DriveBaseAddr+0x4,i);

	        }
	}




	while(sel > 3 && sel <7 && count < sel + 3)                 //drive to the stall
	{
		i = read_reg(TraceBaseAddr);
		j = read_reg(HcBaseAddr);         // read the data of ultrasonic
		if(j < 0x0600)
			{
			    write_reg(DriveBaseAddr,0x0);
			    write_reg(AudioBaseAddr ,0xb );
			    continue;
			}
		else
							{
							    write_reg(DriveBaseAddr,0x1);




	if(i == 0x0)   //00000
			{
			    count = count + 1;
			    //write_reg(DriveBaseAddr+0x4,0x0);      //turn = 0
			    //delay(DELAYUS * 100000);               //0.2s
		        while(1)
		        {
		        	i = read_reg(TraceBaseAddr);
		        	if(i == 0) continue;
		        	else break;
		        }
			}

	else if(count == 1)
			{
				 write_reg(DriveBaseAddr+0x4,0x10);        //turn left
				 delay(DELAYUS * 900000); //1.8s
				// write_reg(DriveBaseAddr+0x4,0x0);
				 count = count + 1;

			}
			else if(count == 3)
			{
				 write_reg(DriveBaseAddr+0x4,0x01);        //turn right
				 delay(DELAYUS * 1100000); //2.2s
				 write_reg(DriveBaseAddr+0x4,0x0);
				 count = count + 1;

			}

		else  write_reg(DriveBaseAddr+0x4,i);


	}

	}


	while(sel > 6 && count < sel + 3)                 //drive to the stall
		{
			i = read_reg(TraceBaseAddr);
			j = read_reg(HcBaseAddr);         // read the data of ultrasonic
			if(j < 0x0600)
				{
				    write_reg(DriveBaseAddr,0x0);
				    write_reg(AudioBaseAddr ,0xb );
				    continue;
				}
			else
								{
								    write_reg(DriveBaseAddr,0x1);




		if(i == 0x0)   //00000
				{
				    count = count + 1;
				    //write_reg(DriveBaseAddr+0x4,0x0);      //turn = 0
				    //delay(DELAYUS * 100000);               //0.2s
			        while(1)
			        {
			        	i = read_reg(TraceBaseAddr);
			        	if(i == 0) continue;
			        	else break;
			        }
				}

		else if(count == 1)
				{
					 write_reg(DriveBaseAddr+0x4,0x10);        //turn left
					 delay(DELAYUS * 900000); //1.8s
					// write_reg(DriveBaseAddr+0x4,0x0);
					 count = count + 1;

				}
				else if(count == 3)
				{
					 write_reg(DriveBaseAddr+0x4,0x01);        //turn right
					 delay(DELAYUS * 1100000); //2.2s
					 write_reg(DriveBaseAddr+0x4,0x0);
					 count = count + 1;

				}

			else  write_reg(DriveBaseAddr+0x4,i);


		}

		}

//############################################ stop,prepare to park into the stall #########################################################################
if(sel <7)
{
	write_reg(DriveBaseAddr,0x0); //stop,prepare to park into the stall
	write_reg(DriveBaseAddr+0x4,0x1f);
	delay(DELAYUS * 300000); //0.6s
	write_reg(DriveBaseAddr+0x8,0x2);      //park = 2'b10  start parking

	delay(DELAYUS * 3000000); //6s
	write_reg(DriveBaseAddr+0x8,0x0);
}

else if(sel == 8)
{
	write_reg(DriveBaseAddr,0x0); //stop,prepare to park into the stall
	write_reg(DriveBaseAddr+0x4,0x1f);
	delay(DELAYUS * 300000); //0.6s
	write_reg(DriveBaseAddr+0x8,0x1);      //park = 2'b01  start parking

	delay(DELAYUS * 3000000); //6s
	write_reg(DriveBaseAddr+0x8,0x0);
}

else if(sel == 7)
{
	write_reg(DriveBaseAddr,0x0); //stop,prepare to park into the stall
	write_reg(DriveBaseAddr+0x4,0x1f);
	delay(DELAYUS * 300000); //0.6s
	write_reg(DriveBaseAddr+0x8,0x3);      //park = 2'b11  start parking

	delay(DELAYUS * 3000000); //6s
	write_reg(DriveBaseAddr+0x8,0x0);
}



	while (1)                                 //wait for the park-out-signal
	{
	   i = read_reg(BlueTeechBaseAddr);

	   if(i == 0x5a) break;
	}


//############################################### park out ######################################################################
if(sel < 7)
{
	write_reg(DriveBaseAddr+0x4,0x1f);
	delay(DELAYUS * 1000000); //2s
	write_reg(DriveBaseAddr,0x1);
	delay(DELAYUS * 100000); //0.2s
	write_reg(DriveBaseAddr+0x4,0x10);
	delay(DELAYUS * 1300000); //2.6s
	write_reg(DriveBaseAddr+0x4,0x0);
	write_reg(AudioBaseAddr ,0x9 );
}

if(sel == 8)
{
	write_reg(DriveBaseAddr+0x4,0x1f);
	delay(DELAYUS * 1000000); //2s
	write_reg(DriveBaseAddr,0x1);
	delay(DELAYUS * 100000); //0.2s
	write_reg(DriveBaseAddr+0x4,0x10);
	delay(DELAYUS * 1300000); //2.6s
	write_reg(DriveBaseAddr+0x4,0x0);
	write_reg(AudioBaseAddr ,0x9 );
}

if(sel == 9)
{
	write_reg(DriveBaseAddr+0x4,0x1f);
	delay(DELAYUS * 1000000); //2s
	write_reg(DriveBaseAddr,0x1);
	delay(DELAYUS * 100000); //0.2s
	write_reg(DriveBaseAddr+0x4,0x10);
	delay(DELAYUS * 1300000); //2.6s
	write_reg(DriveBaseAddr+0x4,0x0);
	write_reg(AudioBaseAddr ,0x9 );
}
//########################################## drive out ###########################################################################
	while(1)
	{
		i = read_reg(TraceBaseAddr);
		j = read_reg(HcBaseAddr);
		if(j < 0x0600)
			{
			    write_reg(DriveBaseAddr,0x0);
			    write_reg(AudioBaseAddr ,0xb );
			    continue;
		    }
		else
		   {
			   write_reg(DriveBaseAddr,0x1);



		      if(i == 0x1f)                         //stop
			    {
		    	  write_reg(DriveBaseAddr+0x4,i);
			      write_reg(DriveBaseAddr,0x0);
			      write_reg(AudioBaseAddr ,0xa );


			      break;
		     	}

/*	     else if(i == 0x00)  //count
		        {
			       count = count + 1;
		           while(1)
		            {
		        	    i = read_reg(TraceBaseAddr);
		            	if(i == 0) continue;
		        	    else break;
		            }
		          continue;
			 //delay(DELAYUS * 100000);               //0.2s
		        }
		     else if(count == 9)
	         	{
		           write_reg(DriveBaseAddr+0x4,0x10);        //turn left
			       delay(DELAYUS * 1000000); //2s
			       write_reg(DriveBaseAddr+0x4,0x0);
			       continue;
		        }

		    else if(count == 10)
		       {
			       write_reg(DriveBaseAddr+0x4,0x01);        //turn right
			       delay(DELAYUS * 1000000); //2s
			       write_reg(DriveBaseAddr+0x4,0x0);
			       continue;
		       }
*/
		   else  write_reg(DriveBaseAddr+0x4,i);
		   }

    }


	return 0;



}
