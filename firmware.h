
#ifndef FIRMWARE_H
#define FIRMWARE_H

#include <stdint.h>
#include <stdbool.h>


#define SYSCLK 41.67//ns 24M
#define US 2000//ns
#define DELAYUS (US / SYSCLK)


void delay(uint32_t delay_us);

#endif








