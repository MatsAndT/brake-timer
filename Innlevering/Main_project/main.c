/*
THIS IS THE MASTER
	CONNECTION
	Wire up master to arduino
	type AT+INQ until 0x884AEA4C7E09 shows
	type AT+CONN[index of that adress]
	now connected!
	
	! THE COMMUNICATION BETWEEN BLUETOOTH-MODULES NEEDS TO BE SET UP BEFORE THE ATMEGA32 IS POWERED UP!

 * Functionallity:
 KK_module:
 - alarm set at a little before 08.00 in the weekdays, when this triggers, then it reads from the clock in intervalls of 1 second
 - print the time on the lcd when reading
 - is bluetooth master so sends the data to the slave when close to break
 
 teacher_module:
 - shows the time on the 7 segmet display
 - raise the flag when break
 - lowers the flag when break over
 */ 

#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <string.h>
#include "screen.h"
#include "I2C.h"

#define RTC_Write_address 0b11010000
#define RTC_Read_address 0b11010001
#include "RTC.h"


long USART_BAUDRATE = 9600;

#include "USART.h"

void timer_init();

int read_continious_clock = 0; // Boolean if clock should be read


int main(void)
{
	
	GICR |= 1 << INT1; // Enable INT1 (Alarm interrupt)
	MCUCR |= (1 << ISC11);
	MCUCR &= ~(1 << ISC10); //Detect falling edge
	
    I2C_Init();
    RTC_Clock_Write(7,59,50);	// Set the time now
    RTC_Date_Write(1,5,6,24); // Set data now. Year is the 2 last digits in the year
	
	RTC_Alarm_Init();
	RTC_Alarm1_Time(7,59,58);		// Wake up 2 second before start of day, to be ready
    
    LCD_Init();
	timer_init();
	USART_Init(USART_BAUDRATE);		// Intitialize USART with spesified baud rate
	LCD_String_xy(0,0,"Init");
	sei();

    while (1) {
    }
    
}

#define NUMBER_OF_BREAKS 9
int break_times[NUMBER_OF_BREAKS][3] = {
	{8, 0, 0},				// Start of day, (have break length of 0)
	{9, 25, 5},				// Break {starthour, startminute, length}
	{10, 15, 10},
	{11, 0, 45},
	{12, 25, 5},
	{13, 10, 5},
	{13, 55, 5},
	{14, 45, 5},
	{15, 30, -1}				// End of day, (have break length of -1)
};


// When alarm the SQW pin on the DS3231 gets LOW, detect this using interrupt
// When the alarm has been triggered, and interrupted the program we need to set the flag for alarm on the DS3231 to 0 again
ISR(INT1_vect){
	LCD_String_xy(0,0,"Alarm");
	RTC_Read_Date(3);		// Read the date
	if (weekday >= 6){		// Weekday >= 6 is saturday and sunday: go back to sleep ;=)
		read_continious_clock = 0;
	} else {
		read_continious_clock = 1; // Start to read form the clock
		TIMSK |= 1 << OCIE1A; // Enable Output Compare A Match Interrupt
	}
	RTC_Alarm_Clear();		// Need to reset the flag after alarm has been read
}


volatile int message_sent = 0; // Boolean to keep track of if we have transmitted the message with either break- or lecture length.
volatile int period_length = 0;
volatile int period_end_minutes;
// Trigger at set interval
ISR(TIMER1_COMPA_vect){
	if (read_continious_clock){
		RTC_Read_Clock(0);
		int minutes_since_midnight = hour*60 + minute;
		char buffer[20];
		sprintf(buffer, "%02d:%02d:%02d", hour, minute, second);
		LCD_String_xy(0,0,buffer);
		
		char message[5];
		
		for (int i = 0; i < NUMBER_OF_BREAKS; i++){
			if ((minutes_since_midnight == break_times[i][0]*60 + break_times[i][1]) && break_times[i][2] != 0){ // If the time now is equal to the time the break starts. And it is not the start of the day (break length = 0)
				if (break_times[i][2] == -1){		// End of day has duration = -1
					/* End of day, go back to sleep */
					USART_Transmit_String("s"); // Send stop command to Teacher module
					TIMSK &= ~(1 << OCIE1A); // Disable Output Compare A Match Interrupt
					read_continious_clock = 0;
					break;
				} 
				
				if (message_sent == 1){					// This is reversed, as opposed to when the break is over, this is since after we send break length it should send lecture length
					period_length = break_times[i][2];
					period_end_minutes = minutes_since_midnight + period_length;
					sprintf(message, "b%d", period_length);		// Send the message of current break length, identified by a "b" at index 0 in the string
					USART_Transmit_String(message);
					
					LCD_Clear();
					LCD_String_xy(0,0,buffer);		// To print the current time immediately after the clear
					LCD_String_xy(1,7, "PAUSE");
					message_sent = 0;
				}
			} else if (minutes_since_midnight == break_times[i][0]*60 + break_times[i][1] + break_times[i][2]){	// The time now is the start of the break time + the break length, so the break is just over
				if (message_sent == 0){
					int next_period_start_minute = break_times[i+1][0]*60 + break_times[i+1][1];
					period_length = next_period_start_minute - minutes_since_midnight;
					period_end_minutes = minutes_since_midnight + period_length;
					sprintf(message, "l%d", period_length);		// Send the message of current lecture length, identified by a "l" at index 0 in the string
					USART_Transmit_String(message);
					
					LCD_Clear();
					LCD_String_xy(0,0,buffer);
					LCD_String_xy(1,7, "TIL PAUSE");
					message_sent = 1;
				}
			}
		}
		
		char message_left[20];
		int total_seconds_left = (period_end_minutes * 60 + 59) - ((minutes_since_midnight+1) * 60 + second);
		int minutes_left = total_seconds_left / 60;
		int seconds_left = total_seconds_left % 60;
		
		sprintf(message_left, "%03d:%02d", minutes_left, seconds_left);
		
		LCD_String_xy(1,0, message_left);
	}
}

void timer_init(){
	TCCR1B |= (1<<CS11) | (1<<CS10); // 64 prescaler (Use a low prescaler to make the Count more accurate)
	TCCR1B |= 1<<WGM12;				// CTC (compare output mode)
	
	// Count which is equivalent to 1 sec:
	// 1 * F_CPU/prescaler
	uint16_t Count = 15625;
	OCR1A = Count;		// Put value in Output Compare Register
	TIMSK &= ~(1 << OCIE1A); // Disable Output Compare A Match Interrupt
}