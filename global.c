/*
 * global.c
 *
 *  Created on: 2020Äê11ÔÂ01ÈÕ
 *      Author: FDC
 */
#include "global.h"
#include "firmware.h"



/*Timer Register
 * ADDR 0:Timer Enable
 * ADDR 4:Timer Counter
 * */
void TimerEnable(unsigned char temp) {
	write_reg(TimerBaseAddr,temp);
}

void TimerUs(unsigned int temp) {
	write_reg(TimerBaseAddr+0x4,temp*DELAYUS);
}

