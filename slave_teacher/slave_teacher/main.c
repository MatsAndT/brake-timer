/*
 * 7seg.c
 *
 * Created: 16.05.2024 08:28:45
 * Author : Mats
 */ 

#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "segment_display.h"

int secounds_to_brake = 0;


int main() {
	// Turn of JTAG - https://www.avrfreaks.net/s/topic/a5C3l000000UK2iEAG/t090838?comment=P-571371
	MCUCSR = (1 << JTD); //-U hfuse:w:0xD9:m
	//                 0    1     2   3    4     5   6    7    8    9   
	//char seg_code[]= {0x03,0x9F,0x25,0x0d,0x99,0x49,0x41,0x1f,0x01,0x19};
	
	seg_init();
	num = 4321;
	secounds_to_brake = num;
	
	// Clock https://stackoverflow.com/a/34210840/7419883
	TCCR1B |= (1 << WGM12); // Configure timer 1 for CTC mode

	TIMSK |= (1 << OCIE1A); // Enable CTC interrupt

	sei(); //  Enable global interrupts

	OCR1A = 15624; // Set CTC compare value to 1Hz at 1MHz AVR clock, with a prescaler of 64

	TCCR1B |= ((1 << CS10) | (1 << CS11)); // Start timer at Fcpu/64
	
	while (1);
}

ISR(TIMER1_COMPA_vect)
{
	secounds_to_brake = secounds_to_brake - 1;
	num = secounds_to_brake;
}