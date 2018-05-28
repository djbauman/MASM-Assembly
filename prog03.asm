TITLE Program 3     (prog3.asm)

; Author: Daniel Bauman
; Date: 10-27-2017
; Description: This program accumulates negative values entered
; by the user, then displays the number of values entered, and 
; their sum and average.

INCLUDE Irvine32.inc
LOWER_LIMIT = -100

.data
greeting1		BYTE "Welcome to Program 3 by Daniel Bauman.",0
namePrompt	BYTE "What is your name? ",0
userName		BYTE 33 DUP(0)
greeting2		BYTE "Nice to meet you, ",0
greeting3		BYTE ".",0
instructions1	BYTE "Please enter a negative number in the range [-100, -1], then press (Enter).",0
instructions2	BYTE "Enter as many negative numbers as you wish, then enter a positive number to stop.",0
error1			BYTE "That number is not in the range [-100, -1]. Try again.",0

input				DWORD ?
input_count	DWORD 0
sum				DWORD 0
average			DWORD 0

display1			BYTE "Numbers entered: ",0
display2			BYTE "Sum: ",0
display3			BYTE "Average: ",0

display_none	BYTE "No values were entered.",0

goodbye1		BYTE "Thanks for using Program 3, ",0
goodbye2		BYTE ". Have a nice day!",0

; EC prompts and variables
; Line numbers
line_number1	DWORD 1
line_number2	BYTE ") ",0

; Floating point average
thousandth		REAL8 1000.0
floatquotient	REAL8 ?
floatdisplay	BYTE "EC average: ",0

ecprompt1		BYTE"**EC: Number lines shown during user input.",0
ecprompt2		BYTE"**EC: Average displayed as a floating point to nearest .001.",0
ecprompt3		BYTE"**EC: Extra credit content color changed",0

.code
main PROC
; Introduce program and programmer (and display EC prompts)
; Change text and background color
call	color

mov		edx, OFFSET ecprompt1
call		WriteString
call		CrLf
mov		edx, OFFSET ecprompt2
call		WriteString
call		CrLf
mov		edx, OFFSET ecprompt3
call		WriteString
call		CrLf
call		CrLf

call		uncolor


mov		edx, OFFSET greeting1
call		WriteString
call		CrLf
call		CrLf

; Ask for the user's name 
mov		edx, OFFSET namePrompt
call		WriteString
call		CrLf
call		CrLf
mov		edx, OFFSET userName
mov		ecx, 32
call		ReadString
call		CrLf

; Greet the user
mov		edx, OFFSET greeting2
call		WriteString
mov		edx, OFFSET userName
call		WriteString
mov		edx, OFFSET greeting3
call		WriteString
call		CrLf
call		CrLf

; Display instructions
mov		edx, OFFSET instructions1
call		WriteString
call		CrLf
mov		edx, OFFSET instructions2
call		WriteString
call		CrLf
call		CrLf

; Get user input (and show current line number)
GetInput:
;call	color
;
;mov		eax, line_number1
;call	WriteInt
;mov		edx, OFFSET line_number2
;call	WriteString
;add		line_number1, 1
;
;call	uncolor
call		line_number

call		ReadInt
mov		input, eax

; If input is greater than -1, jump to ResultsCheck
cmp		input, 0
JNS		ResultsCheck

; Otherwise, check that it is greater or equal to -100
cmp		input, LOWER_LIMIT

; If it is, jump to SaveInput
JGE		SaveInput

; Otherwise, display error and jump back to GetInput
mov		edx, OFFSET error1
call		WriteString
call		CrLf
call		CrLf
jmp		GetInput

; Input is valid. Increment the input count, calculate the sum, then calculate the average.
; Then loop back to GetInput
SaveInput:
add		input_count, 1

mov		eax, input
add		sum, eax

; Normal average calculation:
mov		eax, sum
cdq
mov		ebx, input_count
idiv		ebx

mov		average, eax

; Extra credit average calculation (via function)
call		EC_calc

loop		GetInput

ResultsCheck:
; If no negative numbers were entered, display a message and jump to Goodbye
cmp		input_count, 0
JNE		ShowResults

; Display message stating that no numbers were entered
NoResults:
mov		edx, OFFSET display_none
call		WriteString
call		CrLf
call		CrLf
jmp		Goodbye

; Display the sum, average, and count
ShowResults:
call		CrLf
mov		edx, OFFSET display1
call		WriteString
mov		eax, input_count
call		WriteInt
call		CrLf

mov		edx, OFFSET display2
call		WriteString
mov		eax, sum
call		WriteInt
Call		CrLf

mov		edx, OFFSET display3
call		WriteString
mov		eax, average
call		WriteInt
call		CrLf
call		CrLf

call		EC_display

; Display goodbye
Goodbye:
mov		edx, OFFSET goodbye1
call		WriteString
mov		edx, OFFSET userName
call		WriteString
mov		edx, OFFSET goodbye2
call		WriteString
call		CrLf
call		CrLf


	exit	; exit to operating system
main ENDP
; (insert additional procedures here)

EC_calc	PROC
; Description: EC average calculation
; Receives: "sum" and "input_count" variables
; Returns: "floatquotient" variable
; Preconditions: none
; Registers changed: none

fild	sum
fidiv	input_count
fmul	thousandth
frndint
fdiv	thousandth
fstp	floatquotient
	ret
EC_calc	ENDP

EC_display	PROC
; Description: Displaying EC average
; Receives: N/A
; Returns: N/A
; Preconditions: floatdisplay and floatquotient variables
; Registers changed: N/A
call	color

mov		edx, OFFSET floatdisplay
call		WriteString
fld		floatquotient
call		WriteFloat
call		CrLf
call		CrLf

call	uncolor
	ret
EC_display ENDP

line_number PROC
; Description: Displays current line number
; Receives: N/A
; Returns: N/A
; Preconditions: line_number1 and line_number2 variables set
; Registers changed: N/A
call	color

mov		eax, line_number1
call		WriteInt
mov		edx, OFFSET line_number2
call		WriteString
add		line_number1, 1

call		uncolor
	ret
line_number ENDP

color	PROC
; Description: Changes text color and background from default 
; Receives: N/A
; Returns: N/A
; Preconditions: N/A
; Registers changed: N/A
mov		eax, black + (yellow * 16)
call		SetTextColor
	ret
color   ENDP

uncolor PROC 
; Description: Returns text color and background to default
; Receives: N/A
; Returns: N/A
; Preconditions: N/A
; Registers changed: N/A 
mov		eax, white + (black * 16)
call		SetTextColor
	ret
uncolor ENDP


END main
