/*
 * firmware.c
 *
 *  Created on: 2020Äê11ÔÂ01ÈÕ
 *      Author: FDC
 */
#include "firmware.h"
/*
void delay(uint32_t delay_us)
{
	uint32_t i=0;
	uint32_t j=0;
	for(j=0;j<delay_us;j++){
		for(i=0;i<8;i++){
			__asm__ volatile ("addi x31, x31, 0");
		}
	}
}
*/
void delay(uint32_t delay_us)
{
    unsigned int cycles_current;
    unsigned int cycles_start;
    unsigned int cycles = 0;
    __asm__ volatile ("rdcycle %0;" : "=r"(cycles_start));


    do
    {
        __asm__ volatile ("rdcycle %0;" : "=r"(cycles_current));
        cycles = cycles_current - cycles_start;
    } while(cycles < delay_us);

}


