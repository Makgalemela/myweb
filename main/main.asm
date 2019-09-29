; author : 
; student number: 
; date : 30 - September - 2019
; course : Elen2006


;-----------------------------interupt vectors---------------------------------
.org 0x0000
	rjmp setup

.org  0x0002
	rjmp testMode
.org  0x0004
	rjmp play

.org 0x0014
	rjmp capture_input

.org 0x0012
	rjmp RandNumbers

.org 0x001A
	rjmp FoursecondsCount

;--------------------------------------timer modes setup---------------------------

setup:

	ldi R20, HIGH(RAMEND)
	out SPH, R20
	ldi R20, LOW(RAMEND)
	out SPL, R20

	ldi R20 , 0
	sts TCCR1A , R20

	ldi R20 , 0b00000101
	sts TCCR1B , R20

	/*ldi R16 , 0b00100000
	sts TIMSK1 , R16*/

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

	ldi R16, 0b00001111
	sts EICRA, R16							
	ldi R16 , 0b00000011
	out  EIMSK, R16							

;--------------------------------------------Reset all -------------------------------
	
Start: 
	cbi DDRB , 0
	cbi DDRD , 2
	cbi DDRD , 3
	sbi DDRD, 7
	sbi DDRD, 6
	sbi DDRD, 5
	clr R19
	clr R22
	clr R29
	clr R28
	clr R30
	clr R24
	clr R23
	clr R28
	clr R24
	clr R21
	sei
	Ldi R16 , 0

	rjmp start
	
;----------------------------------------play mode------------------------------------------
Play_Mode:
		ldi R26 , 1
		ldi R16 , 0b00100001
		sts TIMSK1 , R16
		mov R30, R21
	L4:
		cpi R24 , 6
		brne L7
		rjmp GameOver

	L7: 
		out portc , R30
		rjmp L4

;-----------------------------------------Test mode ------------------------------------------
TEST:	ldi R30 ,-30
		ldi R16 , 0b00100000
		sts TIMSK1 , R16
	L12 :
		ldi R26 , 2
		out portc , R16
		Rjmp L12

;----------------------------------------input capture logic ---------------------------------------------

capture_input :	
		LDS R16, ICR1L
		subi r16 , 16
checkMode:
		cpi R26 , 2
		BREQ Lu
		sub r16 , R30
		cpi r16 , 0
		brne lt
		sbi portd , 5
		cbi portd , 6
		ldi R16 , 0b00000001
		sts TIMSK1 , R16
		Inc R23
		rcall POINTS
		rjmp Lu
		lt:	
			sbi portd , 6
			cbi portd , 5
	   Lu:
			reti

;---------------------------using timer2 overflow interrupt rand numbers-----------------
RandNumbers:
		Inc R27
		cpi R27 , 122
		BRNE L0
		rcall Trigger
		Clr R27
		Inc R27
	L0: Inc R21
		cpi R21 ,10
		BRNE L2
		clr R21
		Inc R21
	L2:
		reti

;-------------------------timer fourseonds overflow timer----------------------------
FoursecondsCount:
	
cbi portd ,6
cbi  portd , 5

score: cpi R23 , 0
	BRNE L56
	rcall PENALTIES	
		
L56:
	clr R23
	ldi R16 , 0b00100001
	sts TIMSK1 , R16
	mov R30 , R21
	inc R24
	reti

;-----------------------------penalties----------------------------------------------

PENALTIES:
		DEC R28
		INC R29
		ret
;--------------------------points score--------------------------------------------
POINTS:
		INC R28
		INC R28
		cpi R28 , 10
		BREQ L5
		ret
		L5:
		clr R28
		ldi R28 , 0b00010000
	ret
;---------------------------------triger loop------------------------------------
Trigger:
		sbi portd , 7
		rcall Delay_10us
		cbi portd , 7
		ret

;-------------------------------10 us delay---------------------------------------
Delay_10us:
		ldi  r18, 3
		ldi  r19, 179
	L21: dec  r19
		brne L21
		dec  r18
		brne L21
		ret
;---------------------------------2 sec delay --------------------------------
Delay_2s:

		ldi  r18, 163
		ldi  r19, 87
		ldi  r20, 3
	L1: dec  r20
		brne L1
		dec  r19
		brne L1
		dec  r18
		brne L1
		nop
		ret

;----------------------test mode interupted pin----------------------------------
testmode:
		sei
		rjmp TEST
play:
	sei
	rjmp Play_Mode
;---------------------------Game over loop -------------------------------------

GameOver:
	sei
	ldi R16 , 0b00000000
	sts TIMSK1 , R16
	cpi R29 ,6
	Breq NO
	cpi R29 , 5
	breq NO1
L29 :
Pos: out portc , R28
	rcall Delay_2s
	rjmp start
NO:
	ldi R28 ,6
	sbi portd , 6
	rjmp Display
NO1:
	sbi portd , 6
	ldi R28 ,3
Display :
	out portc , R28
	rcall Delay_2s
	cbi portd , 6
	rjmp start
;---------------------------End----------------------------------------