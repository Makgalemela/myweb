

.org 0x0000
	rjmp setup

.org  0x0002
	rjmp ChangeModes

.org 0x0014
	rjmp capture_input

.org 0x0012
	rjmp RandNumbers

.org 0x001A
	rjmp FoursecondsCount

setup:

	ldi R20, HIGH(RAMEND)
	out SPH, R20
	ldi R20, LOW(RAMEND)
	out SPL, R20

	ldi R20 , 0
	sts TCCR1A , R20

	ldi R20 , 0b10000101
	sts TCCR1B , R20

	ldi R16 , 0b00100000
	sts TIMSK1 , R16

	ldi R16  , 0
	sts TCNT1L , R16

	ldi R16  , 0
	sts TCNT1H , R16

	ldi R20 , 0b00000101
	sts TCCR2B , R20

	ldi R16 , 0b00000011
	sts TIMSK2 , R16

	ldi R16  , 0
	sts TCNT2 , R16

	ldi R16  , 0b11111111
	out DDRC , R16

	cbi DDRB , 0
	sbi DDRD, 7
	sbi DDRD, 6
	sbi DDRD, 5
	clr R19
	clr R22
	clr R28
	clr R30
	sei
	Ldi R16 , 0

/*Start: sleep
	rjmp start*/

Play_Mode:
		ldi R16 , 0b00100001
		sts TIMSK1 , R16
		mov R30, R21
	L4:
		out portc , R30
		rjmp L4
	
TEST:
		out portc , R16
		Rjmp TEST


capture_input :	
		LDS R16, ICR1L
		subi r16 , 16
		sub r16 , R30
		cpi r16 , 0
		brne lt
			sbi portd , 5
		lt:	
		reti

RandNumbers:
		Inc R27
		cpi R27 , 122
		BRNE L0
		rcall Trigger
		Clr R27
		Inc R27
		cbi portd , 5
		cbi portd , 6
	L0: Inc R21
		cpi R21 ,11
		BRNE L2
		clr R21
		Inc R21
	L2:
		reti


FoursecondsCount:
	mov R30 , R21
	reti



PENALTIES:
		DEC R28
		ret

POINTS:
		cpi R28 , 10
		BREQ L5
		INC R28
		INC R28
		ret
		L5:
		clr R28
		ldi R28 , 0b00010000
		ret

Trigger:
		sbi portd , 7
		rcall Delay_10us
		cbi portd , 7
		ret


Delay_10us:
		ldi  r18, 3
		ldi  r19, 179
	L1: dec  r19
		brne L1
		dec  r18
		brne L1
		ret

ChangeModes:
			sei
			/*rjmp Play_Mode*/
			reti