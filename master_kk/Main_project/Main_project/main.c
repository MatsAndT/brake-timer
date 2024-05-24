/*
THIS IS THE MASTER
	CONNECTION
	Wire up master to arduino
	type AT+INQ until 0x884AEA4C7E09 shows
	type AT+CONN[index of that adress]
	no connected!

 * Functionallity:
 KK_module:
 - alarm set at 08.00 in the weekdays, when this triggers, then it reads always from it in while
 - print the time on the lcd when reading
 - raise the flag when break
 - is bluetooth master so sends the data to the slave when close to break
 - lowers the flag when break over
 
 teacher_module:
 - shows the time on the 7 segmet display
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

#include "USART.h"

long USART_BAUDRATE = 9600;



int main(void)
{
	sei();
	GICR |= 1 << INT1; // Enable INT1 (Alarm interrupt)
	MCUCR |= (1 << ISC11);
	MCUCR &= ~(1 << ISC10); //Detect falling edge
	
    I2C_Init();
    RTC_Clock_Write(7,59,50);	// Set the time
    RTC_Date_Write(1,5,6,24); // Year is the 2 last digits in the year
	
	RTC_Alarm_Init();
	RTC_Alarm1_Time(8,0,0);
    
    LCD_Init();			/* Initialize LCD */
	
	USART_Init(USART_BAUDRATE);		// Intitialize USART with spesified baud rate
    
    
    char buffer[20];
    char* days[7] = {"Man", "Tir", "Ons", "Tor", "Fre", "Lor", "Son"};

    while (1) {
    }
    
}

#define NUMBER_OF_BREAKS 5
int break_times[NUMBER_OF_BREAKS][3] = {
	{8, 0, 0},				// Start of day, (have breaklength of 0)
	{8, 1, 1},				// Break {starthour, startminute, length}
	{9, 0, 10},
	{11, 0, 45},
	{15, 30, -1}				// End of day, (have breaklength of -1)
}; 

int read_continious_clock(){
	RTC_Read_Date(3);		// Read the date
	if (weekday >= 6){		// Weekday >= 6 is saturday and sunday. go back to sleep ;=)
		return 0;
	}
	int message_sent = 0;
	int hours_elapsed;
	int start_of_day_acknowledged = 0; // Flag to acknowledge the start of the day
	int break_now = 0;
	int break_i = 0;
	int lecture_minutes;
	char message[5];
	while (1){				// Read clock continiousely on weekdays between alarm to end of day
		RTC_Read_Clock(0);
		char buffer[20];
		sprintf(buffer, "%02x:%02x:%02x  ", (hour & 0b00111111), minute, second);
		LCD_String_xy(0,0,buffer);
		 for (int i = 0; i < NUMBER_OF_BREAKS; i++){
			 if (break_times[i][1] + break_times[i][2] >= 60){		// If the break start + the break length is 60 or over an hour will elape. Example: break {8, 55, 10}, there break end will be 09.05 so it has to check for one hour greather in the end of break check
				 hours_elapsed = (break_times[i][1] + break_times[i][2]) / 60;		// Get the number of hours is elapses
			 } else hours_elapsed = 0;
			 
			if (hour == break_times[i][0] && minute == break_times[i][1]){	 // If it is breaktime, send the length of the break. 
				 if (break_times[i][2] == -1){
					 // End of day, go back to sleep
					  return 0;
				 }
				 
				 if (break_times[i][2] == 0 && !start_of_day_acknowledged){
					 // Start of day
					 lecture_minutes = (break_times[i+1][0] * 60 + break_times[i+1][1]) - (break_times[i][0] * 60 + break_times[i][1]);
					 sprintf(message, "l%d", lecture_minutes);		// Send the message of current lecture length, identified by a "l" at index 0 in the string.
					 USART_Transmit_String(message);
					 LCD_Clear();
					 LCD_String_xy(1,6,"til pause");
					 start_of_day_acknowledged = 1; // Acknowledge that the start of the day message has been sent
					 break_now = 0;
				 }
				 
				 if (message_sent == 0 && break_times[i][2] != 0){			// Only send the message once. 
					 sprintf(message, "b%d", break_times[i][2]);		// Send the message of current breaklength, identified by a "b" at index 0 in the string.
					 USART_Transmit_String(message);
					 LCD_Clear();
					 LCD_String_xy(1,6,"pause");
					 message_sent = 1;
					 break_now = 1;
					 break_i = i;
				 }
			 } else if (hour == (break_times[i][0]+hours_elapsed) && minute == (break_times[i][1]+break_times[i][2])){		// If the current time is the start of the break + the break length (meaning the break is over)
				 if (message_sent == 1){										// Only send the message once
					 int lecture_hours = break_times[i+1][0] - hour;
					 lecture_minutes = break_times[i+1][1] - minute + lecture_hours*60;
					 sprintf(message, "l%d", lecture_minutes);		// Send the message of current lecture length, identified by a "l" at index 0 in the string.
					 USART_Transmit_String(message);
					 LCD_Clear();
					 LCD_String_xy(1,6,"til pause");
					 message_sent = 0;
					 break_now = 0;
				 }
			 }
			 
			 //TODO: NOT DISPLAYING TIME LEFT CORRECT seconds goes from 9 to 16
			 char buffer2[20];
			 if (break_now) {
				 // Calculate the minutes and seconds left for the break
				 int break_minutes_left = (break_times[break_i][0] * 60 + break_times[break_i][1] + break_times[break_i][2]) - (hour * 60 + minute) - 1;
				 int break_seconds_left = 59 - second;
				 sprintf(buffer2, "%02x:%02x", break_minutes_left, break_seconds_left);
				 LCD_String_xy(1,0,buffer2);
			} else {
				 // Calculate the minutes and seconds left for the lecture
				 int lecture_minutes_left = lecture_minutes - (hour * 60 + minute - (break_times[break_i][0] * 60 + break_times[break_i][1])) - 1;
				 int lecture_seconds_left = (uint8_t)second;
				 sprintf(buffer2, "%02d:%02d", lecture_minutes_left, lecture_seconds_left);
				 LCD_String_xy(1,0,buffer2);
			 }
				 
		 }
	}
}

// When alarm the SQW pin on the board gets high, detect this using interrulpt
// When the alarm has been triggered, and interrupted the program we need to set the flag to 0 again
// The signal from DS3231 gets low when alarm
ISR(INT1_vect){
	read_continious_clock();
	RTC_Alarm_Clear();
}