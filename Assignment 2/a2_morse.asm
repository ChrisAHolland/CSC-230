; a2_morse.asm
; CSC 230: Spring 2018
;
; Student name: Chris Holland
; Student ID: V00876844
; Date of completed work: Monday. March 3, 2018
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2018-Feb-10)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are 
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

.include "m2560def.inc"

.cseg
.equ S_DDRB=0x24
.equ S_PORTB=0x25
.equ S_DDRL=0x10A
.equ S_PORTL=0x10B

	
.org 0
	; Copy test encoding (of SOS) into SRAM
	;
	ldi ZH, high(TESTBUFFER)
	ldi ZL, low(TESTBUFFER)
	ldi r16, 0x30
	st Z+, r16
	ldi r16, 0x37
	st Z+, r16
	ldi r16, 0x30
	st Z+, r16
	clr r16
	st Z, r16

	; initialize run-time stack
	ldi r17, high(0x21ff)
	ldi r16, low(0x21ff)
	out SPH, r17
	out SPL, r16

	; initialize LED ports to output
	ldi r17, 0xff
	sts S_DDRB, r17
	sts S_DDRL, r17

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION **** 
; ***************************************************

	; If you're not yet ready to execute the
	; encoding and flashing, then leave the
	; rjmp in below. Otherwise delete it or
	; comment it out.

	;jmp stop

    ; The following seven lines are only for testing of your
    ; code in part B. When you are confident that your part B
    ; is working, you can then delete these seven lines. 
	; ldi r17, high(TESTBUFFER)
	; ldi r16, low(TESTBUFFER)
	; push r17
	; push r16
	; rcall flash_message
    ; pop r16
    ; pop r17
   
; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The only things you can change in this section is
; the message (i.e., MESSAGE01 or MESSAGE02 or MESSAGE03,
; etc., up to MESSAGE09).
;

	; encode a message
	;
	ldi r17, high(MESSAGE05 << 1)
	ldi r16, low(MESSAGE05 << 1)
	push r17
	push r16
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall encode_message
	pop r16
	pop r16
	pop r16
	pop r16

; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
	; display the message three times
	;
	ldi r18, 3
main_loop:
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall flash_message
	dec r18
	tst r18
	brne main_loop


stop:
	rjmp stop
; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION **** 
; ****************************************************


flash_message:
				push r16
				push r28 ; YL
				push r29 ; YH
				push r30 ; ZL
				push r31 ; ZH			

				in ZH, SPH	; Store SPH in ZH
				in ZL, SPL	; Store SPL in ZL
				
				ldd YL, Z+9		; Load the lower pointer into ZL
				ldd YH, Z+10	; Load the higher pointer into ZH
				
				the_loop: 
							ld r16, Y+			; Load the byte into r16
							call morse_flash	; Morse flash the byte
							tst r16				; Test to see if it's zero
							brne the_loop		; Repeat if not zero
				
				pop r31	; Pop registers and return
				pop r30
				pop r29
				pop r28
				pop r16	
				
				ret	   



morse_flash:
			cpi r16, 0xff			; Special case, test for it at the start
			breq special_case
			
			push r16				; Push r16/r17/r18/r22 to save 
			push r17
			push r18
			push r22
			
			mov r22, r16			; Move value of r16 to r22, r22 is a proxy for r16
			swap r16				; Swap the nibbles in r16
			ldi r17, 0				; Use r17 as a size counter, initiate at 0
			call count				; Find the size ofthe message
			ldi r16, 6				; Load 6 into r16 since r16 is the parameter for leds_on
			

			my_loop:				; Main loop of function
				sbrs r22, 0			; If the bit is set, skip the call dash function
				call dot		
				sbrc r22, 0			; If the bit is cleared, skip the call dot function
				call dash
				lsr r22				; Shift r22 right
				call delay_long		; Place a long delay between characters
				dec r17				; Decrement size counter
				cpi r22, 0
				brne my_loop		; Re-loop if size != 0

			stop_tag:
				pop r22				; Pop registers and return
				pop r18
				pop r17
				pop r16				
				ret

;------------------------------ methods for morse_flash -----------------------------------------------

	dash: 					; Dash delays as stated in outline
		call leds_on
		call delay_long
		call leds_off
		call delay_long
		ret

	dot:					; Dot delays as stated in outline
		call leds_on
		call delay_short
		call leds_off
		call delay_long
		ret

	count:					
		ldi r18, 2			; Use r18 as a place holder for 2
		sbrc r16, 0			; If bit 0 is cleared, don't add 1 to size
		ldi r17, 1			
		sbrc r16, 1			; If bit 1 is cleared, don't add 2 to size
		add r17, r18
		sbrc r16, 2			; If bit 2 is cleared, don't set size to 4 (max size)
		ldi r17, 4
		ret
		
	special_case:			; Special case if r16 = 0xff as defined in outline
		call leds_off
		call delay_long
		call delay_long
		call delay_long
		rjmp stop_tag


leds_on:
		cpi r16, 0		; Compare r16 with 0, go to a routine that calls leds_off if so
		breq if_zero		
				
		cpi r16, 1		; Compare r16 with 1, go to the if_one routine if so
		breq if_one

		cpi r16, 2		; Compare r16 with 2, go to the if_two routine if so
		breq if_two

		cpi r16, 3		; Compare r16 with 3, go to the if_three routine if so
		breq if_three

		cpi r16, 4		; Compare r16 with 4, go to the if_four routine if so
		breq if_four

		cpi r16, 5		; Compare r16 with 5, go to the if_five routine if so
		breq if_five

		cpi r16, 6		; Compare r16 with 6, go to the if_six routine if so
		breq if_six
	
	complete:
			ret

		if_zero:					; Simply calls leds_off if r16 = 0
			call leds_off
			rjmp complete

		if_one:						; Turns on one LED then returns
			ldi r17, 0b00000010
			sts S_PORTB, r17
			rjmp complete

		if_two:						; Turns on two LED's then returns
			ldi r17, 0b00001010
			sts S_PORTB, r17
			rjmp complete

		if_three:					; Turns on three LED's then returns
			ldi r17, 0b00001010
			sts S_PORTB, r17
			ldi r17, 0b00000010
			sts S_PORTL, r17
			rjmp complete

		if_four:					; Turns on four LED's then returns
			ldi r17, 0b00001010
			sts S_PORTB, r17
			ldi r17, 0b00001010
			sts S_PORTL, r17
			rjmp complete

		if_five: 					; Turns on five LED's then returns
			ldi r17, 0b00001010
			sts S_PORTB, r17
			ldi r17, 0b00101010
			sts S_PORTL, r17
			rjmp complete

		if_six: 					; Turns on six LED's then returns
			ldi r17, 0b00001010
			sts S_PORTB, r17
			ldi r17, 0b10101010
			sts S_PORTL, r17
			rjmp complete


leds_off:
			ldi r17, 0b00000000		; Simply load 0 into both registers
			sts S_PORTB, r17
			sts S_PORTL, r17
			ret



encode_message:
				push XH	; X is the buffer
				push XL
				push YH	; Y is the stack pointer
				push YL
				push ZH ; Z is the where the message is stored
				push ZL				

				in YH, SPH
				in YL, SPL
				
				ldd XH, Y + 11	;9
				ldd XL, Y + 10 ;8	
			
				ldd ZH, Y + 13	;11
				ldd ZL, Y + 12 ;10

				encoder:
						ld r20, Z+				; Load in the next letter, make sure it aint 0
						cpi r20, 0
						breq complete_code		
						push r20 				; Push next letter to be encoded
						call letter_to_code
						st X, r0				; Store the buffer into r0
						rjmp encoder

				

				complete_code:					; pop and return
						pop ZL
						pop ZH
						pop YL
						pop YH
						pop XL
						pop XH
						ret	



letter_to_code:
			pop r22
			push ZH
			push ZL

			

			ldi ZH, high(ITU_MORSE<<1)	; Load ITU_MORSE into the Z pseudoregisters
			ldi ZL, low(ITU_MORSE<<1)
			ldi r17, 0					; Use r17 to hold dots or dashes
			lpm r16, Z				

			letter_loop:				
					cp r22, r16			; Compare it to the letter from the stack
					breq letter_loop_2	; If equal leave loop
					lpm r16, Z+8		; Else z = Z+8 and re-loop
					rjmp letter_loop


			letter_loop_2:				; Traverse through the dot dash sequences
					lpm r16, Z+			; Load program memory to r16
					cpi r16, 0			; Make sure r16 isn't 0, exit if it is
					breq the_exit
					inc r0				; Let r0 hold our size for now
					lsl r17				; Shift r17 left
					subi r22, 45		; Subract ascii value of a dash from r16		
					sbrs r22, 0			; If it's 0, its a dash, if not, a dot
					call its_dash
					sbrc r22, 0
					call its_dot

			its_dash:
					inc r17
					rjmp letter_loop_2
				
			its_dot:					; Dot is 0 so just start loop again and r17 will lsl
					rjmp letter_loop_2
						


				
	the_exit:	
		lsl r0		; shift r0 to the left 4 times
		lsl r0	
		lsl r0
		lsl r0

		or r0, r17  ; OR r0 with r17 (size) to create the byte
	
		pop ZL		; Pop/push registers and return
		pop ZH
		push r22
		ret	 


; **********************************************
; **** END OF SECOND "STUDENT CODE" SECTION **** 
; **********************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

delay_long:
	rcall delay
	rcall delay
	rcall delay
	ret

delay_short:
	rcall delay
	ret

; When wanting about a 1/5th of second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit
	
	ldi r17, 0xff
delay_busywait_loop2:
	dec	r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret



;.org 0x1000

ITU_MORSE: .db "A", ".-", 0, 0, 0, 0, 0
	.db "B", "-...", 0, 0, 0
	.db "C", "-.-.", 0, 0, 0
	.db "D", "-..", 0, 0, 0, 0
	.db "E", ".", 0, 0, 0, 0, 0, 0
	.db "F", "..-.", 0, 0, 0
	.db "G", "--.", 0, 0, 0, 0
	.db "H", "....", 0, 0, 0
	.db "I", "..", 0, 0, 0, 0, 0
	.db "J", ".---", 0, 0, 0
	.db "K", "-.-.", 0, 0, 0
	.db "L", ".-..", 0, 0, 0
	.db "M", "--", 0, 0, 0, 0, 0
	.db "N", "-.", 0, 0, 0, 0, 0
	.db "O", "---", 0, 0, 0, 0
	.db "P", ".--.", 0, 0, 0
	.db "Q", "--.-", 0, 0, 0
	.db "R", ".-.", 0, 0, 0, 0
	.db "S", "...", 0, 0, 0, 0
	.db "T", "-", 0, 0, 0, 0, 0, 0
	.db "U", "..-", 0, 0, 0, 0
	.db "V", "...-", 0, 0, 0
	.db "W", ".--", 0, 0, 0, 0
	.db "X", "-..-", 0, 0, 0
	.db "Y", "-.--", 0, 0, 0
	.db "Z", "--..", 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0

MESSAGE01: .db "A A A", 0
MESSAGE02: .db "SOS", 0
MESSAGE03: .db "A BOX", 0
MESSAGE04: .db "DAIRY QUEEN", 0
MESSAGE05: .db "THE SHAPE OF WATER", 0, 0
MESSAGE06: .db "DARKEST HOUR", 0, 0
MESSAGE07: .db "THREE BILLBOARDS OUTSIDE EBBING MISSOURI", 0, 0
MESSAGE08: .db "OH CANADA OUR OWN AND NATIVE LAND", 0
MESSAGE09: .db "I CAN HAZ CHEEZBURGER", 0

; First message ever sent by Morse code (in 1844)
MESSAGE10: .db "WHAT GOD HATH WROUGHT", 0


.dseg
.org 0x200
BUFFER01: .byte 128
BUFFER02: .byte 128
TESTBUFFER: .byte 4

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================
