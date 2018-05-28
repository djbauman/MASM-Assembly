TITLE Program 1     (prog01.asm)

; Author: Daniel Bauman
; Date: 09-27-2017
; Description: This program takes two integer inputs, then
; calculates and displays their sum, difference, product,
; and quotient/remainder.

INCLUDE Irvine32.inc

.data
intro1				BYTE 		"Welcome to Super Calculator by Daniel B.",0
intro2				BYTE 		"This program will calculate the sum, difference, product, and quotient of two integers.",0
prompt1				BYTE 		"Enter the first number: ",0
prompt2				BYTE 		"Enter the second number: ",0
input1				DWORD 	?
input2				DWORD 	?
sum					DWORD 	?
difference			DWORD 	?
product				DWORD 	?
quotient				DWORD 	?
remainder			DWORD 	?
result1				BYTE 		"Sum: ",0
result2				BYTE 		"Difference: ",0
result3				BYTE 		"Product: ",0
result4				BYTE 		"Quotient: ",0
result5				BYTE 		"Remainder: ",0
goodbye				BYTE 		"Thanks for using Super Calculator. Goodbye!",0

prompt3				BYTE 		"Enter 1 to repeat, or 2 to quit: ",0
input3				DWORD 	?

prompt4				BYTE 		"Sorry, the second value must be smaller than the first. Try again.",0

ecprompt1			BYTE 		"**EC: Program repeats until user chooses to quit.",0
ecprompt2			BYTE 		"**EC: Program validates second input to be less than first.",0
ecprompt3			BYTE 		"**EC: Program displays quotient to the nearest .001.",0

floatquotient		REAL8 		?
thousandth			REAL8 		1000.0
floatdisplay		BYTE 		"Division to 3 decimal places: ",0

.code
main PROC

L1:

; Introduce program and programmer, and display EC prompts
	mov		edx, OFFSET ecprompt1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ecprompt2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ecprompt3
	call	WriteString
	call	CrLf	
	mov		edx, OFFSET intro1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro2
	call	WriteString
	call	CrLf
	call	CrLf

L4:

; Prompt user for two integer inputs
	mov		edx, OFFSET prompt1
	call	WriteString
	call	ReadInt
	mov		input1, eax

	mov		edx, OFFSET prompt2
	call	WriteString
	call	ReadInt
	mov		input2, eax

	call	CrLf

; Validate that 2nd input is smaller than 1st input
; If not, display error and go back to last step

	cmp		input1, eax
	JLE		L3
	JG		L5

L3:
	mov		edx, OFFSET prompt4
	call	WriteString
	call	CrLf
	jmp		L4
	

L5:
; Calculate the sum, difference, product, and quotient
; and store the results in the appropriate locations
	; Sum
	mov		eax, input1
	add		eax, input2
	mov		sum, eax

	; Difference
	mov		eax, input1
	sub		eax, input2
	mov		difference, eax

	; Product
	mov		eax, input1
	mov		ebx, input2
	mul		ebx
	mov		product, eax

	; Quotient & Remainder
	mov		eax, input1
	mov		ebx, input2
	div		ebx
	mov		quotient, eax
	mov		remainder, edx

	; EC Quotient & Remainder
	fild	input1
	fidiv	input2
	fmul	thousandth
	frndint	
	fdiv	thousandth
	fstp	floatquotient


	; Display the results
	; Display sum
	mov		edx, OFFSET result1
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf

	; Display difference
	mov		edx, OFFSET result2
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf

	; Display product
	mov		edx, OFFSET result3
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf

	;Display quotient
	mov		edx, OFFSET result4
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	call	CrLf

	;;Display remainder
	mov		edx, OFFSET result5
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

	; Display EC division result
	mov		edx, OFFSET floatdisplay
	call	WriteString
	fld		floatquotient
	call	WriteFloat
	call	CrLf

	;Display goodbye message
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf


; Ask user if they want to continue or quit

	mov		edx, OFFSET prompt3
	call	WriteString
	call	ReadInt
	mov		input3, eax
	call	CrLf

	cmp		input3, 1
	je		L1

	cmp		input3, 2
	je		L2				

L2:

	exit	; exit to operating system
main ENDP

END main
