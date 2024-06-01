/*
THIS IS THE SLAVE
*/

#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <string.h>

#define MAX_LENGTH 20 // Maximum length of received string
volatile char dataReceived[MAX_LENGTH]; // Array to store received string
#include "USART.h"

long USART_BAUDRATE = 9600;

volatile uint8_t receivedIndex = 0;

int main(){
	USART_Init(USART_BAUDRATE);		// Intitialize USART with spesified baud rate
	sei();
}

ISR(USART_RXC_vect) {
	unsigned char receivedChar;
	receivedChar = USART_Receive_buffer();
	if (receivedChar == '\n' || receivedIndex > MAX_LENGTH){
		receivedIndex = 0;
		
		//TODO: Store the numeric value of the string
		
		// Reset the buffer before each read
		memset(dataReceived, 0, MAX_LENGTH);
	} else if (receivedChar != '\r') {
		dataReceived[receivedIndex++] = receivedChar;
	}
	// Show on the display
	 
}