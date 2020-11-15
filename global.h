/*
 * global.h
 *
 *  Created on: 2020Äê10ÔÂ26ÈÕ
 *      Author: FDC
 */

#ifndef GLOBAL_H_
#define GLOBAL_H_

#include <stdint.h>
#include <stdbool.h>

#define DriveBaseAddr 0x40000000
#define TraceBaseAddr 0x40010000
#define TimerBaseAddr 0x40020000
#define HcBaseAddr	  0x40030000
#define BlueTeechBaseAddr 0x40040000
#define AudioBaseAddr 0x40050000

#define	write_reg(addr,data)	*((volatile uint32_t*)(addr)) = data
#define	read_reg(addr)		*((volatile uint32_t*)(addr))

#define Timer_BIT_INT 1
unsigned int Timer_irq_cnt;


void TimerEnable(unsigned char temp);
void TimerUs(unsigned int temp);



#endif /* GLOBAL_H_ */
