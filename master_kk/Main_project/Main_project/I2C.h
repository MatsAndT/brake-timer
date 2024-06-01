/* This code is inspired from https://www.electronicwings.com/avr-atmega/atmega1632-i2c */


void I2C_Init()
{
	TWBR = 2;						// Bit rate (See datasheet)
	PORTC |= (1<<PC0)|(1<<PC1);		// Set pull up resistor on SCL and SDA
}

void I2C_Start(char write_address)
{
	TWCR=(1<<TWSTA)|(1<<TWEN)|(1<<TWINT);	// Enable TWI, generate START
	while(!(TWCR&(1<<TWINT)));				// Wait until TWI finish

	TWDR=write_address;						// Write SLA+W in TWI data register
	TWCR=(1<<TWEN)|(1<<TWINT);				// Enable TWI & clear interrupt flag
	while(!(TWCR&(1<<TWINT)));				// Wait until TWI finish its current job
	
}

void I2C_Repeated_Start(char read_address)
{
	TWCR=(1<<TWSTA)|(1<<TWEN)|(1<<TWINT);	// Enable TWI, generate start
	while(!(TWCR&(1<<TWINT)));				// Wait until TWI finish its current job
	
	TWDR=read_address;						// Write SLA+R in TWI data register
	TWCR=(1<<TWEN)|(1<<TWINT);				// Enable TWI and clear interrupt flag
	while(!(TWCR&(1<<TWINT)));				// Wait until TWI finish
}

void I2C_Write(char data)
{
	TWDR=data;					// Copy data in TWI data register
	TWCR=(1<<TWEN)|(1<<TWINT);	// Enable TWI and clear interrupt flag
	while(!(TWCR&(1<<TWINT)));	// Wait until TWI finish its current job
}

char I2C_Read_Ack()
{
	TWCR=(1<<TWEN)|(1<<TWINT)|(1<<TWEA);	// Enable TWI, generation of ack
	while(!(TWCR&(1<<TWINT)));				// Wait until TWI finish its current job
	return TWDR;							// Return received data
}

char I2C_Read_Nack()
{
	TWCR=(1<<TWEN)|(1<<TWINT);	// Enable TWI and clear interrupt flag
	while(!(TWCR&(1<<TWINT)));	// Wait until TWI finish its current job
	return TWDR;				// Return received data
}

void I2C_Stop()
{
	TWCR=(1<<TWSTO)|(1<<TWINT)|(1<<TWEN);	// Enable TWI, generate stop
	while(TWCR&(1<<TWSTO));					// Wait until stop condition execution
}