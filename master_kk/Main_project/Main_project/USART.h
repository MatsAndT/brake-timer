
void USART_Init(long USART_BAUDRATE)
{
	UCSRB |= (1 << RXEN) | (1 << TXEN);						// Turn on transmission and reception
	UCSRC |= (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1);	// Use 8-bit char size
	UCSRA |= 1 << U2X;										// Double the baudspeed
	UCSRB |= 1 << RXCIE;									// Interrupts for RX
	long BAUD_PRESCALE = (((F_CPU / (USART_BAUDRATE * 8UL))) - 1);   // Specifies a Baud Rate Prescale. Multiply by 2 since we use double baud speed
	UBRRL = BAUD_PRESCALE;									// Load lower 8-bits of the baud rate
	UBRRH = (BAUD_PRESCALE >> 8);							// Load upper 8-bits
}

unsigned char USART_Receive()
{
	while ((UCSRA & (1 << RXC)) == 0);	// Wait till data is received
	return(UDR);						// Return the byte
}

unsigned char USART_Receive_buffer()
{
	return(UDR);
}

void USART_Transmit(unsigned char data){
	while ((UCSRA & (1 << UDRE)) == 0);		// Wait until the transmitter is ready
	UDR = data;								// Put the data in the register
}

void USART_Transmit_String(char str[]){
	int i = 0;
	do {
		char character = str[i];
		USART_Transmit(character);
		i++;
	} while (str[i] != '\0');
}

