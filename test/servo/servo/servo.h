/*
 * servo.h
 *
 * Created: 16.05.2024 10:49:53
 *  Author: Mats
 */ 


#ifndef SERVO_H_
#define SERVO_H_

void servo_init(char _servo_reg, uint8_t _servo_pin) {
	_servo_reg |= (1 << _servo_pin);	/* Make OC1A pin as output */
	TCNT1 = 0;			/* Set timer1 count zero */
	ICR1 = 24990;		/* Set TOP count for timer1 in ICR1 register */

	/* Set Fast PWM, TOP in ICR1, Clear OC1A on compare match, clk/64 */
	TCCR1A = (1<<WGM11)|(1<<COM1A1);
	TCCR1B = (1<<WGM12)|(1<<WGM13)|(1<<CS10)|(1<<CS11);
}


// Function to convert degrees to OCR1A value
int degreesToOCR1A(int degrees) {
	// Define the range of motion of the servo and corresponding OCR1A values
	int minDegree = -90; // Minimum angle (degrees)
	int maxDegree = 90;  // Maximum angle (degrees)
	int minOCR1A = 65;   // OCR1A value for -90° position
	int maxOCR1A = 300;  // OCR1A value for +90° position
	
	// Perform linear mapping
	int ocrValue = minOCR1A + (degrees - minDegree) * (maxOCR1A - minOCR1A) / (maxDegree - minDegree);
	
	// Ensure the result is within the valid range
	if (ocrValue < minOCR1A) {
		ocrValue = minOCR1A;
		} else if (ocrValue > maxOCR1A) {
		ocrValue = maxOCR1A;
	}
	
	return ocrValue;
}

void servo_move(uint8_t degrees) {
	OCR1A = degreesToOCR1A(degrees);
}


#endif /* SERVO_H_ */