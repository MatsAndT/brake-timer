/*
 * RTC_read_timer_intervall.c
 *
 * Created: 31.05.2024 14:37:41

 */ 

#define F_CPU 1000000UL
#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <string.h>
#include "LCD.h"
#include "USART.h"



int main(void)
{
	USART_Init(9600);
	USART_Transmit_String("Heisann sveisann");
	LCD_Init();
	LCD_String_xy(0,0, "hei");
    while (1) 
    {
		
    }
}
