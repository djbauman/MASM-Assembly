TITLE Program 4     (prog04.asm)

; Author: Daniel Bauman
; Date: 11-01-2017
; Description: This program lists from 1 to 400 composite numbers
; in order, as specified by the user.

INCLUDE Irvine32.inc

UPPER_LIMIT = 400

.data
intro1			BYTE 	"Welcome to Composite Number Generator by Daniel Bauman.",0

prompt1			BYTE 	"Enter a number of composites to display in the range [1, 400]: ",0
error1			BYTE 	"That number is not in the range [1, 400]. Try again.",0

input1			DWORD ?
validation		DWORD ?
test_val			DWORD 1
test_divisor	DWORD 2
print_val		DWORD ?
result			DWORD ?
spaces			BYTE 	"   ",0

print_count		DWORD 0
line_count		DWORD 10

goodbye1		BYTE 	"Thanks for using Composite Number Generator. Have a nice day!",0


.code
main PROC
; (insert executable instructions here)
call	intro
call	getUserData
call	showComposites
call	farewell


	exit	; exit to operating system
main ENDP


; PROCEDURES

; Procedure name: intro
; Description: Displays the intro prompt
; Receives: N/A
; Returns: N/A
; Preconditions: String variable "intro1"
; Registers changed: edx

intro	PROC
pushad

mov		edx, OFFSET intro1
call		WriteString
call		CrLf
call		CrLf

popad
	ret
intro ENDP

; Procedure name: getUserData
; Description: Prompts user and collects their input (into "input1") and calls validation procedure 
; Receives: n/a
; Returns: n/a
; Preconditions: String variables "prompt1", "error1"
; Registers changed: edx, eax
getUserData	PROC
pushad

getUserData_start:
mov		edx, OFFSET prompt1
call		WriteString
call		ReadInt
mov		input1, eax

call		validate

cmp		validation, 1
JE			getUserData_end

getUserData_error:
jmp		getUserData_start

getUserData_end:
popad
	ret
getUserData ENDP


; Procedure name: validate
; Description: validates that input is in the range [1, UPPER_LIMIT]
; Receives: n/a
; Returns: n/a
; Preconditions: Variables "input1", "error1"
; Registers changed: edx
validate PROC
pushad

validate_start:
cmp		input1, 1
JL			validate_error
cmp		input1, UPPER_LIMIT
JG		validate_error
jmp		validate_success

validate_error:
mov		validation, 0
mov		edx, OFFSET error1
call		WriteString
call		CrLf
call		CrLf
jmp		validate_end

validate_success:
mov		validation, 1

validate_end:

popad
	ret
validate ENDP


; Procedure name: showComposites
; Description: Calls isComposite procedure repeatedly until it has printed as many
; composites as specified by the user's input.
; Receives: n/a
; Returns: n/a
; Preconditions: Variables "input1", "spaces", "result", "test_val", "print_count"
; Registers changed: ecx, eax, edx
showComposites	PROC
pushad

mov	ecx, input1
mainLoop:

call		isComposite
cmp		result, 0
JE			mainLoop ; if a prime was found, repeat the loop without decrementing the counter

; otherwise (if a composite was found), call newLineCheck, 
; increment "print_count" then loop back to mainLoop
mov		eax, test_val
sub		eax, 1

call		newLineCheck
call		WriteDec
mov		edx, OFFSET spaces
call		WriteString

add		print_count, 1

loop		mainLoop

popad
	ret
showComposites	ENDP

; Procedure name: isComposite
; Description: Performs a prime/composite test on the variable "test_val",
; stores a 0 or 1 in "result", and increments "test_val"
; Receives: n/a
; Returns: n/a
; Preconditions: Variables "test_val", "test_divisor", "result"
; Registers changed: eax, edx
isComposite	PROC
pushad

cmp 		test_val, 3
JLE 		isComposite_prime

isComposite_test: 
; If test_divisor has become equal to test_val, then no even
; divisions were found and the number is prime
mov 		eax, test_divisor 
cmp 		, test_val
JE			isComposite_prime

mov		eax, test_val
mov		edx, 0
div		test_divisor

cmp		edx, 0
JE 		isComposite_composite

; otherwise, increment test_divisor and run again from isComposite_test
add		test_divisor, 1
jmp		isComposite_test

isComposite_prime:
mov		result, 0
jmp 		isComposite_end

isComposite_composite:
mov		result, 1
jmp 		isComposite_end

isComposite_end:
mov		test_divisor, 2
add		test_val, 1

popad
	ret
isComposite	ENDP

; Procedure name: newLineCheck
; Description: Prints a new line if a multiple of 10 composites have been printed
; Receives: n/a
; Returns: n/a
; Preconditions: Variables "print_count" and "line_count"
; Registers changed: eax, edx
newLineCheck	PROC
	pushad

	mov eax, print_count
	mov edx, 0
	div line_count

	cmp edx, 0
	JE	newLineCheck_CrLf
	JNE newLineCheck_end


	newLineCheck_CrLf:
	call	CrLf

	newLineCheck_end:
	popad
	ret
newLineCheck	ENDP

; Procedure name: farewell
; Description: Says goodbye to the user
; Receives: n/a
; Returns: n/a
; Preconditions: String variable "goodbye1"
; Registers changed: edx
farewell	PROC
pushad

call		CrLf
call		CrLf
mov		edx, OFFSET goodbye1
call		WriteString
call		CrLf
call		CrLf

popad
	ret
farewell	ENDP

END main
