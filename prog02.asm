TITLE Program 2     (prog02.asm)

; Author: Daniel Bauman
; Date: 10-13-2017
; Description: This program takes the user's name, greets them
; then calculates and prints from 1 to 46 Fibonacci numbers as
; specified by the user.

INCLUDE Irvine32.inc

.data

UPPERLIMIT		DWORD 	46
fibLast				DWORD 	?
intro1				BYTE 		"Welcome to Fibonacci Calculator 3000 by Daniel Bauman!",0
prompt1				BYTE 		"What is your name? ",0
greeting				BYTE 		"Nice to meet you, ",0
prompt2				BYTE 		"Enter a number from 1 to 46: ",0
error1				BYTE 		"Sorry, that number is too large for my program. ",0
space				BYTE 		"     ",0
counter				DWORD 	1
lineCount			DWORD 	5
temp_eax			DWORD 	?
temp_edx			DWORD 	?
goodbye				BYTE 		"Thanks for using Fibonacci Calculator 3000, ",0
goodbye2			BYTE 		". Have a great day! ",0
userName			BYTE 		33 DUP(0)
input					DWORD 	?

ecprompt1			BYTE 		"**EC: (Do something incredible) Program changes text and background color.",0

.code
main PROC
; (insert executable instructions here)

; Display EC prompts
mov		edx, OFFSET ecprompt1
call		WriteString
call		CrLf

; Change text and background color
mov		eax, yellow + (magenta * 16)
call		SetTextColor

; Introduction
mov		edx, OFFSET intro1
call		WriteString
call		CrLf
call		CrLf

; Introduction, continued
mov		edx, OFFSET prompt1			; Ask user's name
call		WriteString
call		CrLf
call		CrLf

mov		edx, OFFSET userName		; Get user's name
mov		ecx, 32
call		ReadString

mov		edx, OFFSET greeting			; Greet the user
call		WriteString
mov		edx, OFFSET userName
call		WriteString
call		CrLf
call		CrLf

; userInstructions
GetInput:
mov		edx, OFFSET prompt2			; Get "n" value from the user
call		WriteString
call		ReadInt
mov		input, eax

mov		eax, UPPERLIMIT
cmp		input, eax
JG		Error
jmp		displayFibs							; If input is valid, jump to next step

Error:
mov		edx, OFFSET error1				; Display error message
call		WriteString
call		CrLf
call		CrLf
jmp		GetInput							; Go back to get input again

; displayFibs
displayFibs:

mov		ecx, input							; Decrement the count by 1 (to account for
sub		ecx, 1								; the first printed value before the loop)

mov		ebx, 0
mov		eax, 1

; display the first value
call		WriteDec
mov		edx, OFFSET space
call		WriteString

fibLoop:
add		counter, 1

mov		fibLast, ebx
add		fibLast, eax
mov		ebx, eax
mov		eax, fibLast

call		WriteDec
mov		edx, OFFSET space
call		WriteString


; Check if 5 values have been printed
; If so, call for a new line.
; Store and retrieve the registers 
; needed for this.
push		eax
push		edx

mov		eax, counter
mov		edx, 0
div		lineCount

cmp		edx, 0
JE			NewLine

pop		edx
pop		eax

loop 		fibLoop
jmp		farewell								; If the loop is done, bypass NewLine

NewLine:
pop		edx
pop		eax

call		CrLf

loop 		fibLoop

; farewell
farewell:
call		CrLf
call		CrLf
mov		edx, OFFSET goodbye
call		WriteString
mov		edx, OFFSET userName
call		WriteString
mov		edx, OFFSET goodbye2
call		WriteString
call		CrLf


	exit	; exit to operating system
main ENDP

END main
