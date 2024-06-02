/*
 * segment_display.h
 *
 * Created: 16.05.2024 08:31:55
 *  Author: M
 */ 

#pragma once
#ifndef segment_display_H_
#define segment_display_H_

#define SegOne   0x01
#define SegTwo   0x02
#define SegThree 0x04
#define SegFour  0x08

static char seg_code[]= {0x03,0x9F,0x25,0x0d,0x99,0x49,0x41,0x1f,0x01,0x19};
	
int num = 0000;
int temp;

#define DDR_PINS          DDRC
#define PORT_DIGIT_PINS   PORTC

#define DDR_SELECT        DDRA
#define PORT_DIGIT_SELECT PORTA

void seg_init()
{
	/* Configure the ports as output */
	DDR_PINS = 0xff; // Data lines
	DDR_SELECT = 0xff; // Control signal PORTD0-PORTD3
	
	// Turn off the display
	PORT_DIGIT_SELECT = 0x00;
	PORT_DIGIT_PINS = 0xff;
	
	TCCR0 |= (1 << WGM01); // Configure timer 0 for CTC mode

	TIMSK |= (1 << OCIE0); // Enable CTC interrupt

	sei(); //  Enable global interrupts

	OCR0 = 39; // Set CTC compare value to 39 for 50Hz at 1MHz AVR clock, with a prescaler of 256, 313 ved 64

	TCCR0 |= (1 << CS02); // Start timer 0 ved Fcpu/256
}

#define display_delay 1
void diplay_one_cycle()
{
	temp = num % 10;
	PORT_DIGIT_SELECT = SegOne;
	PORT_DIGIT_PINS = seg_code[temp];
	_delay_ms(display_delay);
	
	temp = (num / 10) % 10;
	PORT_DIGIT_SELECT = SegTwo;
	PORT_DIGIT_PINS = seg_code[temp];
	_delay_ms(display_delay);
	
	temp = (num / 100) % 10;
	PORT_DIGIT_SELECT = SegThree;
	PORT_DIGIT_PINS = seg_code[temp];
	_delay_ms(display_delay);

	temp = (num / 1000) % 10;
	PORT_DIGIT_SELECT = SegFour;
	PORT_DIGIT_PINS = seg_code[temp];
	_delay_ms(display_delay);
}

ISR(TIMER0_COMP_vect)
{
	diplay_one_cycle();
}

#endif /* segment_display_H_ */