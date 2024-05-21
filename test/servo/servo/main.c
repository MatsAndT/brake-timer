/*
 * servo.c
 *
 * Created: 16.05.2024 10:46:56
 * Author : Mats
 */ 
#define F_CPU 1000000UL		/* Define CPU Frequency e.g. here its 1MHz */
#include <avr/io.h>			/* Include AVR std. library file */
#include <stdio.h>			/* Include std. library file */
#include <util/delay.h>		/* Include Delay header file */

#define servo_reg DDRD
#define servo_pin PD5
#include "servo.h"

int main(void)
{
	servo_init(servo_reg, servo_pin);
	
	
	while(1)
	{
		servo_move(-90);		/* Set servo shaft at -90° position */
		_delay_ms(1500);
		servo_move(0);	/* Set servo shaft at 0° position */
		_delay_ms(1500);
		servo_move(90);	/* Set servo at +90° position */
		_delay_ms(1500);
	}
}
