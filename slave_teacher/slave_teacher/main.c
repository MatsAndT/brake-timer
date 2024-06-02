#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "segment_display.h"
#include "servo.h"

#define MAX_LENGTH 20 // Maximum length of received string
volatile unsigned char dataReceived[MAX_LENGTH]; // Array to store received string
volatile uint8_t receivedIndex = 0;
#include "USART.h"

long USART_BAUDRATE = 9600;


volatile uint16_t seconds_left = 0;
volatile bool is_brake = false;
volatile bool day_over = false;

void seconds_timer()
{
	// Clock https://stackoverflow.com/a/34210840/7419883
	TCCR2 |= (1 << WGM21); // Configure timer 1 for CTC mode

	TIMSK |= (1 << OCIE2); // Enable CTC interrupt

	sei(); //  Enable global interrupts

	OCR2 = 244; // Set CTC compare value to 1Hz at 1MHz AVR clock, with a prescaler of 64

	TCCR2 |= ((1 << CS20) | (1 << CS21) | (1 << CS22)); // Start timer at Fcpu/1024
}

int main() {
	// Turn of JTAG - https://www.avrfreaks.net/s/topic/a5C3l000000UK2iEAG/t090838?comment=P-571371
	MCUCSR = (1 << JTD); //-U hfuse:w:0xD9:m
	//                 0    1     2   3    4     5   6    7    8    9   
	//char seg_code[]= {0x03,0x9F,0x25,0x0d,0x99,0x49,0x41,0x1f,0x01,0x19};
	
	DDRB |= (1 << 0); // Set LED as output DEBUG
	
	seg_init();
	seconds_left = 350;
	
	seconds_timer();
	
	servo_init();
	moveServo(ServoDown);
	
	USART_Init(USART_BAUDRATE);		// Intitialize USART with spesified baud rate
	
	while (1);
}

// Used to get a 8 bit timer to last for 1 sec
int spacer = 4;

ISR(TIMER2_COMP_vect)
{
	spacer -= 1;
	if (spacer == 0)
	{
		seconds_left -= 1;
		
		num = (seconds_left/60)*100;
		num += seconds_left % 60;
		spacer = 4;
		
		// Flag up when 5min left to brake
		if (seconds_left == 300 && !is_brake)
		{
			moveServo(ServoMid);
		}
	}
	
}



void handleMessage(unsigned char str[])
{
	// Change servo state for brake and lecture
	if (str[0] == 'b')
	{
		is_brake = true;
		moveServo(ServoUp);
	}
	else if (str[0] == 'l')
	{
		is_brake = false;
		moveServo(ServoDown);
	}
	else if (str[0] == 's')
	{
		is_brake = false;
		day_over = true;
		return 0;
	}
	
	char time_left_char[MAX_LENGTH];
	// Removing the 1st index (which is either b or l)
	for (int _i = 1; str[_i] != '\0'; _i++) {
		time_left_char[_i - 1] = str[_i];
	}
	// Add the null terminator
	time_left_char[strlen(str) - 1] = '\0';

	// Convert the remaining string to integer
	seconds_left = atoi(time_left_char) * 60;
}

ISR(USART_RXC_vect) {
	unsigned char receivedChar;
	receivedChar = UDR; // Use UDR to read the received data

	if (receivedChar == '\n' || receivedIndex >= MAX_LENGTH - 1) {
		dataReceived[receivedIndex] = '\0'; // Assign the null character
		receivedIndex = 0;
		
		handleMessage(dataReceived);
		
		// Reset the buffer before each read
		memset(dataReceived, 0, MAX_LENGTH);
		} else if (receivedChar != '\r') {
		dataReceived[receivedIndex++] = receivedChar;
	}
}
