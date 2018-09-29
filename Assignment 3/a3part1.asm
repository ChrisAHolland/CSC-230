; a3part1.asm
; CSC 230: Spring 2018
;
; Student name: Chris Holland
; Date of completed work: March 23, 2018
;
; *******************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2018-Mar-08)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#3. As with A#2, there are 
; "DO NOT TOUCH" sections. You are *not* to modify the lines
; within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; I have added for this assignment an additional kind of section
; called "TOUCH CAREFULLY". The intention here is that one or two
; constants can be changed in such a section -- this will be needed
; as you try to test your code on different messages.
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
;
; (1) assembler directives setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants we can use later in the
;     program
;
; (4) code for initial setup of the Analog Digital Converter (in the
;     same manner in which it was set up for Lab #4)
;     
; (5) code for setting up our three timers (timer1, timer3, timer4)
;
; After all this initial code, your own solution's code may start.
;

.cseg
.org 0
	jmp reset

; location in vector table for TIMER1 COMPA
;
.org 0x22
	jmp timer1

; location in vector table for TIMER4 COMPA
;
.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd_function_defs.inc"
.include "lcd_function_code.asm"

.cseg

; These two constants can help given what is required by the
; assignment.
;
#define MAX_PATTERN_LENGTH 10
#define BAR_LENGTH 6

; All of these delays are in seconds
;
#define DELAY1 0.5
#define DELAY3 0.1
#define DELAY4 0.01


; The following lines are executed at assembly time -- their
; whole purpose is to compute the counter values that will later
; be stored into the appropriate Output Compare registers during
; timer setup.
;

#define CLOCK 16.0e6 
.equ PRESCALE_DIV=1024  ; implies CS[2:0] is 0b101
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))

.if TOP1>65535
.error "TOP1 is out of range"
.endif

.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif


reset:
	; initialize the ADC converter (which is neeeded
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer4 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16


	; timer1 is for the heartbeat -- i.e., part (1)
	;
    ldi r16, high(TOP1)
    sts OCR1AH, r16
    ldi r16, low(TOP1)
    sts OCR1AL, r16
    ldi r16, 0
    sts TCCR1A, r16
    ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, temp
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; timer3 is for the LCD display updates -- needed for all parts
	;
    ldi r16, high(TOP3)
    sts OCR3AH, r16
    ldi r16, low(TOP3)
    sts OCR3AL, r16
    ldi r16, 0
    sts TCCR3A, r16
    ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
    sts TCCR3B, temp

	; timer4 is for reading buttons at 10ms intervals -- i.e., part (2)
    ; and part (3)
	;
    ldi r16, high(TOP4)
    sts OCR4AH, r16
    ldi r16, low(TOP4)
    sts OCR4AL, r16
    ldi r16, 0
    sts TCCR4A, r16
    ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
    sts TCCR4B, temp
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

    ; flip the switch -- i.e., enable the interrupts
    sei

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; *********************************************
; **** BEGINNING OF "STUDENT CODE" SECTION **** 
; *********************************************

		rcall lcd_init

		ldi r16, '<'
		sts CHAR_ONE, r16
	
		ldi r16, '>'
		sts CHAR_TWO, r16

		ldi r16, 1
		sts PULSE, r16

		
start:
; Timer 3 polling
		in r16, TIFR3
		sbrs r16, OCF3A
		rjmp heart_beat_loop

		ldi r16, (1<<OCF3A)
		out TIFR3, r16
		rjmp start
	
		; Refresh loop
		heart_beat_loop:
			
			ldi r16, 0
			ldi r17, 14
			push r16
			push r17
			rcall lcd_gotoxy
			pop r17
			pop r16

			lds r16, CHAR_ONE
			push r16
			rcall lcd_putchar
			pop r16

			lds r17, CHAR_TWO
			push r17
			rcall lcd_putchar
			pop r17
	
			rjmp start


stop:
    rjmp stop


timer1:
	push r16
	push r17
	lds r16, SREG
	push r16
	
	lds r16, PULSE
	cpi r16, 1
	breq beat_off
	cpi r16, 0
	breq beat_on
	
	; Turns the beat off "  "
	beat_off:
		ldi r16, 0
		sts PULSE, r16
		ldi r16, ' '
		sts CHAR_ONE, r16
		sts CHAR_TWO, r16

		rjmp timer_1_off
	
	; Turns the beat on "<>"
	beat_on:
		ldi r16, 1
		sts PULSE, r16
		
		ldi r16, '<'
		sts CHAR_ONE, r16
		ldi r17, '>'
		sts CHAR_TWO, r17
		rjmp timer_1_off
	
	timer_1_off:
		pop r16
		sts SREG, r16
		pop r17
		pop r16
		reti
	

; Note there is no "timer3" interrupt handler as we must use this
; timer3 in a polling style within our main program.


timer4:
    reti

; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The purpose of these locations in data memory are
; explained in the assignment description.
;

.dseg

CHAR_ONE: .byte 1
CHAR_TWO: .byte 2
PULSE: .byte 1
COUNTER: .byte 2
DISPLAY_TEXT: .byte 16
BUTTON_CURRENT: .byte 1
BUTTON_PREVIOUS: .byte 1
BUTTON_COUNT: .byte 2
BUTTON_LENGTH: .byte 1
DOTDASH_PATTERN: .byte MAX_PATTERN_LENGTH

; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################
