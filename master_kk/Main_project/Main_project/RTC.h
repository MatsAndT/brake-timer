int second, minute, hour, weekday, date, month, year;

void RTC_Read_Clock(char read_clock_address) {
	I2C_Start(RTC_Write_address); // Start I2C communication with RTC
	I2C_Write(read_clock_address); // Write address to read
	I2C_Repeated_Start(RTC_Read_address);
	
	second = I2C_Read_Ack();
	minute = I2C_Read_Ack();
	hour = I2C_Read_Nack(); //Last communication so nack
	I2C_Stop();
}

void RTC_Read_Date(char read_date_address) {
	I2C_Start(RTC_Write_address);
	I2C_Write(read_date_address);
	I2C_Repeated_Start(RTC_Read_address);
	
	weekday = I2C_Read_Ack();
	date = I2C_Read_Ack();
	month = I2C_Read_Ack();
	year = I2C_Read_Nack();
	I2C_Stop();
}

char hour2BDC(uint8_t _hour){
	// See datasheet for DS3231 how hour is decoded in register
	char BDC = 0;
	
	if (_hour >= 10){
		if (_hour >= 20){
			BDC |= 1 << 5; //bit 5 represents 20 hour
			_hour -= 20; //We need the to get just the rest
			} else {
			BDC |= 1 << 4; //bit 4 represents 10 hour
			_hour -= 10;
		}
	}
	//Add in the rest
	BDC |= (_hour & 0b00001111); // The 4 last bits are as normal
	return BDC;
}

char value2BDC(uint8_t value){ // For minutes and seconds
	char BDC = 0;
	uint8_t tens = value/10;	// Get the number of tens in the value
	value -= tens*10;				// value is now the rest
	BDC |= tens << 4;		// The tens is put in from the bit 4
	BDC |= (value & 0b00001111);
	return BDC;
}

void RTC_Clock_Write(char _hour, char _minute, char _second){
	I2C_Start(RTC_Write_address);	//Address defined in main
	I2C_Write(0); // Be at the 0 location (second)
	I2C_Write(value2BDC(_second));
	I2C_Write(value2BDC(_minute));
	I2C_Write(value2BDC(_hour));
	I2C_Stop();
}

void RTC_Date_Write(char _weekday, char _date, char _month, char _year){
	I2C_Start(RTC_Write_address);
	I2C_Write(3);		// (First bit sent tells the location to be at) Bet at the 3. location (weekday)
	I2C_Write(_weekday);
	I2C_Write(value2BDC(_date));
	I2C_Write(value2BDC(_month));
	I2C_Write(value2BDC(_year));
	I2C_Stop();
}

void RTC_Alarm_Init(){
	I2C_Start(RTC_Write_address);
	I2C_Write(0xE);		// Bet at the control register position (See datasheet)
	I2C_Write(0b00000101);	// Enabling interrupt Control and Alarm 1 Interrupt Enable
	I2C_Stop();
}

void RTC_Alarm1_Time(char _hour, char _minute, char _second){ // The alarm triggers at the spesified time every day.
	I2C_Start(RTC_Write_address);
	I2C_Write(7);
	I2C_Write(value2BDC(_second));
	I2C_Write(value2BDC(_minute));
	I2C_Write(value2BDC(_hour));
	/*I2C_Write(0b10000000);
	I2C_Write(0b10000000);
	I2C_Write(0b10000000);*/
	I2C_Write(0b10000000); // Set A1M4 to trigger at that time set
	I2C_Stop();
}

void RTC_Alarm_Clear(){
	I2C_Start(RTC_Write_address);
	I2C_Write(0xF);
	I2C_Write(0b10001000);	// Write 0 at the BSY, A2F and A1F flag. (We need to set values to every, but only want to change A1F. TODO: read what the register is and only change the A1F flag)
	I2C_Stop();
}