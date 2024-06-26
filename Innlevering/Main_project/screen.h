#define LCD_Data_Dir DDRB		/* Define LCD data port direction */
#define LCD_Command_Dir DDRA	/* Define LCD command port direction register */
#define LCD_Data_Port PORTB		/* Define LCD data port */
#define LCD_Command_Port PORTA	/* Define LCD data port */

#define RS PA2					/* Define Register Select (data/command reg.)pin */
#define RW PA1					/* Define Read/Write signal pin */
#define EN PA0					/* Define Enable signal pin */

#include <stdio.h>

void LCD_enable_pulse(){
	LCD_Command_Port |= (1<<EN);
	_delay_us(1);
	LCD_Command_Port &= ~(1<<EN);
	_delay_us(1530); // was 3 ms
}

void LCD_Command(unsigned char cmnd)
{
	LCD_Data_Port= cmnd;
	LCD_Command_Port &= ~(1<<RS);	// RS=0 command reg.
	LCD_Command_Port &= ~(1<<RW);	// RW=0 Write operation
	LCD_enable_pulse();
}

void LCD_Char (unsigned char char_data)	// LCD data write function
{
	LCD_Data_Port= char_data;
	LCD_Command_Port |= (1<<RS);	// RS=1 Data reg.
	LCD_Command_Port &= ~(1<<RW);	// RW=0 write operation
	LCD_enable_pulse();
}

void LCD_String (char *str)		// Send string to LCD function
{
	int i;
	for(i=0;str[i]!=0;i++)		// Send each char of string till the NULL
	{
		LCD_Char (str[i]);
	}
}

void LCD_String_xy (uint8_t row, uint8_t pos, char *str)  // Send string to LCD with xy position
{
	if (row == 0 && pos<16)
	LCD_Command(pos|0b10000000);					// Command of first row and required position<16
	else if (row == 1 && pos<16)
	LCD_Command(pos|0b11000000);					// Command of first row and required position<16
	LCD_String(str);								// Call LCD string function
}

void LCD_Num(int num)			// Send a number to LCD
{
	char str[16];		     	// Max screen length 16
	sprintf(str, "%d", num);    // Makes num into str
	LCD_String(str);
}

void LCD_Num_xy(uint8_t row, uint8_t pos, int num)	// Send a number to LCD with xy position
{
	if (row == 0 && pos<16)
	LCD_Command(pos|0b10000000);					// Command of first row and required position<16
	else if (row == 1 && pos<16)
	LCD_Command(pos|0b11000000);					// Command of first row and required position<16
	LCD_Num(num);
}

void LCD_Clear()
{
	LCD_Command (0b1);			// clear display
	LCD_Command (0b10000000);	// cursor at home position
}

void LCD_Newline() {
	LCD_Command(0b11000000);	// Go to 2nd line
}

void LCD_Init (void)			// LCD Initialize function
{
	LCD_Command_Dir = 0xFF;		// Make LCD command port direction as o/p
	LCD_Data_Dir = 0xFF;		// Make LCD data port direction as o/p
	_delay_ms(20);				// LCD Power ON delay always >15ms
	
	LCD_Command (0b00111000);	// Initialization of 16X2 LCD in 8bit mode
	LCD_Command (0b1100);		// Display ON Cursor OFF
	LCD_Command (0b0110);		// Auto Increment cursor
	LCD_Clear();
}