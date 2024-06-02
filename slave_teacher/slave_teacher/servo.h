/*
 * servo.h
 *
 * Created: 21.05.2024 16:29:34
 *  Author: M
 */ 


#ifndef SERVO_H_
#define SERVO_H_

#define ServoDown 1500
#define ServoMid 2000
#define ServoUp 2500 

void servo_init()
{
	TCCR1A |= (1 << WGM11) | (1 << COM1A1); // Fast PWM, non-inverting
	TCCR1B |= (1 << WGM12) | (1 << WGM13) | (1 << CS10); // Fast PWM, prescaler
	
	uint16_t Ctotal = 20000;
	ICR1 = Ctotal - 1;

	DDRD |= (1 << PD5);
	OCR1A = ServoDown;
}

void moveServo(int val)
{
	OCR1A = val;
}



#endif /* SERVO_H_ */