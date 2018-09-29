; parity.asm
; CSC 230: Spring 2018
;
; Code provided for Assignment #1
;
; Mike Zastre (2018-Jan-21)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (a). In this and other
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
; Your task: To compute the value of the parity bit (or "check" bit)
; that for R16 needed for even parity. For example, if R16 is equal to
; 0b10100010, then it has three set bits, and the parity is 1 (i.e., the
; parity bit would be set). As another example, if R16 is equal to
; 0b01010110, then it has four set bits, and the parity is 0 (i.e., the
; parity bit would be cleared). In our code, simply store the correct
; value of 0 or 1 in PARITY.
;
; Your solution must count bits by using masks, bit shifts, arithmetic
; operations, logical operations, and loops.  You are *not* to construct
; lookup tables (i.e., you are not to precompute an array such value
; 0xA2 has 1 stored with it, value 0x56 has 0 stored with it, etc).
;
; In your solution you are free to modify the original value stored
; in R16.

    .cseg
    .org 0
; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

    ; You may change the number stored in R16
	ldi R16, 0x10

	ldi R17, 0 ; Use this to keep track of # of 1's in R16	
	ldi R18, 8 ; Used as the loop counter

	loop1:
		sbrc R16, 0	; Check if the 0th bit of R16 is cleared, skip the increment instruction if it is
		inc R17		; Increment if it is set
		lsr R16		; Shift our bit right
		dec R18		; Decrement R18
		brne loop1	; Repeat loop if R18 != 0

	ldi R20, 0			; Load 0 into R20 for storing purposes
	ldi R21, 1			; Load 1 into R21 for storing purposes
	sts PARITY, R20		; Store 0 as the PARITY value (defualt)
	sbrc R17, 0			; check if the count is even, if it is not, perform the lower command
	sts PARITY, R21		; Load 1 as the parity value if the 0th position is not cleared (meaning it's odd)

	


; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x202
PARITY: .byte 1  ; result of computing parity-bit value for even parity
; ==== END OF "DO NOT TOUCH" SECTION ==========
