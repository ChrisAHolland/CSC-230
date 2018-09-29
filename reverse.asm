; reverse.asm
; CSC 230: Spring 2018
;
; Code provided for Assignment #1
;
; Mike Zastre (2018-Jan-21)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: To reverse the bits in the word IN1:IN2 and to store the
; result in OUT1:OUT2. For example, if the word stored in IN1:IN2 is
; 0xA174, then reversing the bits will yield the value 0x2E85 to be
; stored in OUT1:OUT2.

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
    ; These first lines store a word into IN1:IN2. You may
    ; change the value of the word as part of your coding and
    ; testing.
    ;
    ldi R16, 0xA1		; first byte of the word
    sts IN1, R16		; store its value into IN1
    ldi R16, 0x74		; second byte of the word
    sts IN2, R16		; store its value into IN2
    
	ldi R17, 8			; counter for loop 
	ldi R20, 8			; counter for loop2
	lds R21, IN1		; load the value of IN1 to register 21 so we can modify it
	lds R23, IN2		; load the value of IN2 to register 23 so we can modify it

	
	loop: 				; loop to reverse the first byte
		ror R21			; rotate right r21
		rol R22			; rotate left r22
		dec R17			; decrease r17 by 1
		brne loop		; branch back to loop

	loop2: 				; loop to reverse the second byte
		ror R23			; rotate right r23
		rol R24			; rotaate left r24
		dec R20			; decrease r20
		brne loop2		; branch back to loop


	sts IN1, R11
	sts IN2, R12
    ; This code only swaps the order of the bytes from the
    ; input word to the output word. This clearly isn't enough
    ; so you may modify or delete these lines as you wish.
    
    lds R16, IN1
	sts OUT2, R22

    lds R16, IN2
	sts OUT1, R24

; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x200
IN1:	.byte 1
IN2:	.byte 1
OUT1:	.byte 1
OUT2:	.byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
