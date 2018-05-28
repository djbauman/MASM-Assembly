TITLE Program 6     (prog06.asm)
;**************************************************************************************
; Author: Daniel Bauman
; Date: 12-1-2017
; Description: This program implements low-level I/O functions for unsigned integers, as well
; as macros for string I/O.
;**************************************************************************************
INCLUDE Irvine32.inc

MAX = 10					; This constant sets the number of
								; values to request from the user

;**************************************************************************************	
; Macro name: getString
; Description: gets a string from the user, and places it into a given memory location
;**************************************************************************************
mGetString MACRO string, strSize
	push 	ecx 
	push 	edx
	mov 		edx, OFFSET input
	mov 		ecx, 10
	call		ReadString
	pop 		edx
	pop 		ecx
ENDM

;**************************************************************************************	
; Macro name: displayString
; Description: displays a given string
;**************************************************************************************
mDisplayString MACRO str
	push 	edx
	mov		edx, str
	call 		WriteString
	pop 		edx
ENDM


.data
; (insert variable definitions here)
input					QWORD	?
inputLength		DWORD	?
reverseLength		DWORD	?
buffer				DWORD	(SIZEOF input)
array					DWORD	MAX DUP(?)
count					DWORD	0
printCount			DWORD	0
numeric				DWORD	?
stringOut1			BYTE		100 DUP (?)
stringOut2			BYTE		100 DUP (?)
sum					DWORD	?
average				DWORD	?
intro1				BYTE		"Welcome to Program 6 by Daniel B.",0
prompt1				BYTE		"Please enter 10 numbers.",0
printMsg			BYTE		"You entered the following numbers: ",0
printSpace			BYTE		", ",0
printSumMsg		BYTE		"The sum of these numbers is ",0
printAvgMsg		BYTE		"Their average is ",0
error1				BYTE		"That is not a valid number. Try again.",0
goodbye				BYTE		"Thanks for using Program 6. Bye!",0


.code
main PROC
; (insert executable instructions here)
mDisplayString OFFSET intro1			; display intro
call	CrLf
call	CrLf
mDisplayString OFFSET prompt1		; display instructions
call	CrLf

mov ecx, MAX									; Set loop counter to take 10 numbers
mainLoop:
push OFFSET input							; Push parameters and call readVal
push OFFSET inputLength					
push OFFSET error1						
push OFFSET numeric					
call readVal							


push count										; Push parameters and call arrayAdd
push OFFSET array						
push numeric
call arrayAdd

mov eax, 4
add count, eax								; when this loop ends, the array will have
loop mainLoop								; been filled with 10 numeric values
										
call CrLf										
mDisplayString OFFSET printMsg		; "You entered the following numbers: "

mov ecx, MAX
mov edx, OFFSET array
mainLoop2:
call CrLf
mov eax, printCount
mov ebx, [edx+eax]
mov numeric, ebx

push numeric									; Push parameters and call writeVal
push OFFSET stringOut1					
push OFFSET stringOut2	
push OFFSET reverseLength
call writeVal

mov eax, 4
add printCount, eax
loop mainLoop2
call CrLf
call CrLf

push	OFFSET sum
push	OFFSET printSumMsg
push	OFFSET array
call	arraySum

push	OFFSET sum
push	OFFSET average
push	OFFSET printAvgMsg
call	arrayAvg

mDisplayString OFFSET goodbye
call CrLf
call CrLf

	exit	; exit to operating system
main ENDP




;*** PROCEDURES ***

;**************************************************************************************************************
; Procedure name: readVal
; Description: uses getString macro to get user's string, then converts the string into numeric digits while validating
; Receives: @input (ebp+20), @inputLength (ebp+16, @error1 (ebp+12), @numeric (ebp+8)
; Returns: Stores the output numeric value in variable 'numeric'
; Preconditions:
; Registers used: eax, ebx, ecx, edx, esi
;
;The stack after pushing the old ebp:
;
; [EBP]		old EBP
; [EBP+4]	return @
; [ebp+8]	@numeric (**all addresses are 4 bytes**)
; [ebp+12]	@error1
; [ebp+16]	@inputLength
; [ebp+20]  @input
;
;**************************************************************************************************************
readVal PROC
push	ebp						;Set up stack frame
mov		ebp, esp

push eax
push ebx
push ecx
push edx
push esi

start:
mov edx, 0					; set EDX to 0, to store our eventual digit
mGetString [ebp+20]

push ebx						; this extra dereferencing step seems necessary here
mov ebx, [ebp+16]
mov [ebx], eax
pop ebx							

mov ecx, eax					; set the loop counter to the string's length (is automatically placed in eax by readString)
mov	esi, [ebp+20]			; point esi at the address of the input string

cld

validate:						; Check that each character is between 48 and 57 before moving on.
lodsb
cmp al, 48
jl error
cmp al, 57
jg error							; end of validation steps

push eax
mov eax, edx
mov ebx, 10
mul ebx							; multiply 'x' by 10, store in EBX
mov edx, eax
pop eax
movzx ebx, al				; add to 'x' the value in AL, then subtract 48
mov	eax, edx
add eax, ebx
sub eax, 48
mov edx, eax					; move our new "total" back into edx

;mov ebx, 5000
;cmp edx, ebx
;jg error
loop validate
jmp validate_quit

error:
mDisplayString [ebp+12]	; If a character fails validation, display error
call	CrLf
jmp start						; ...and return to start

validate_quit:					; The user's input string is now validated to be numbers, and stored in EDX	
push ebx						; Store the output value in 'numeric' variable (need to pass by reference)
mov ebx, [ebp+8]
mov [ebx], edx
pop ebx

pop esi
pop edx
pop ecx
pop ebx
pop eax

pop ebp
ret 16
readVal ENDP


;**************************************************************************************************************
; Procedure name: writeVal
; Description: converts a numeric value to a string of digits, then use displayString macro to print it as a string 
; Receives: Need to pass numeric, @stringOut1, @stringOut2, and @reverseLength
; Returns: 
; Preconditions:
; Registers used: eax, ebx, ecx, edx, edi, 
;
;The stack after pushing the old ebp:
;
; [EBP]		old EBP
; [EBP+4]	return @
; [ebp+8]	@reverseLength
; [ebp+12]	@stringOut2
; [ebp+16]	@stringOut1
; [ebp+20]	numeric (value)
;
;**************************************************************************************************************
writeVal PROC
push	ebp						;Set up stack frame
mov		ebp, esp

push eax
push ebx
push ecx
push edx
push edi

mov ebx, [ebp+8]
mov eax, 0
mov [ebx], eax				; (Set reverseLength to zero)

mov eax, [ebp+20]
mov edi, [ebp+16]			; load @stringOut1 into edi

start:
mov ebx, 10
mov edx, 0
div ebx							; divide our numeric value in EAX by 10; EAX holds quotient, EDX holds remainder
push eax
mov eax, edx
add eax, 48					; EAX now holds the ASCII value for the digit
stosb
pop eax

push eax						;inc reverseLength
mov eax, 1
mov ebx, [ebp+8]
add [ebx], eax
pop eax

cmp eax, 0
jg start

push [ebp+8]					;push parameters and call reverseString
push [ebp+16]
push [ebp+12]
call reverseString

mDisplayString [ebp+12]

pop edi
pop edx
pop ecx
pop ebx
pop eax

pop ebp
ret 16
writeVal ENDP

;**************************************************************************************************************
; Procedure name: reverseString
; Description: Reverses a given string and places the result into a passed variable
; Receives: Need to pass inputLength, @stringOut1, @stringOut2
; Returns: 
; Preconditions:
; Registers used: ecx, esi, edi
;
;The stack after pushing the old ebp:
;
; [EBP]		old EBP
; [EBP+4]	return @
; [ebp+8]	@stringOut2
; [ebp+12]  @stringOut1
; [ebp+16]	@reverseLength
;
;***************************************************************************************************************
reverseString PROC
push	ebp						;Set up stack frame
mov		ebp, esp

push eax
push ecx
push edi
push esi

mov eax, [ebp+16]			; ECX needs to equal the number of character in stringOut1
mov ecx, [eax]

mov esi, [ebp+12]
add esi, ecx
dec esi
mov edi, [ebp+8]

reverse:
std
lodsb
cld
stosb
loop reverse

pop esi
pop edi
pop ecx
pop eax

pop ebp
ret 12
reverseString ENDP


;**************************************************************************************************************
; Procedure name: arrayAdd
; Description: Adds an integer into an array
; Receives: Need to pass @array, and value to store, (and multiple of 4 for each item entered, to add to edi?)
; Returns: 
; Preconditions:
; Registers used: 
;
;The stack after pushing the old ebp:
;
; [EBP]		old EBP
; [EBP+4]	return @
; [ebp+8]	numeric (value)
; [ebp+12]  @array
; [ebp+16]	count (value)
;
;***************************************************************************************************************
arrayAdd PROC
push	ebp						;Set up stack frame
mov		ebp, esp

push eax
push ebx
push edx

mov	edx, [ebp+12]		; mov to EDI the @array
mov	eax, [ebp+8]			; mov to EAX the number
mov	ebx, [ebp+16]		; mov to EBX the # of elements already added
mov	[edx+ebx], eax

pop edx
pop ebx
pop eax

pop ebp
ret 12
arrayAdd ENDP


;**************************************************************************************************************
; Procedure name: arraySum
; Description: Displays the sum of the array's values
; Receives: @array, @printSumMsg, @sum
; Returns: Sum is returned to 'sum' variable
; Preconditions:
; Registers used: eax, ebx, ecx, edx
;
;The stack after pushing the old ebp:
;
; [EBP]		old EBP
; [EBP+4]	return @
; [EBP+8]	@array
; [EBP+12]	@printSumMsg
; [EBP+16]	@sum
;
;***************************************************************************************************************
arraySum PROC
push ebp
mov ebp, esp

push eax
push ebx
push ecx
push edx

mov eax, 0				; eax will store the running sum
mov ebx, 0
mov ecx, MAX

sumLoop:
mov edx, [ebp+8]		; set EDX to the @array
add eax, [edx+ebx]		; mov to EAX the value at EDX plus EBX (# of times looped)

add ebx, 4					; increment ebx to access next array element
loop sumLoop

mov ebx, [ebp+16]
mov [ebx], eax

mDisplayString [ebp+12]
call	WriteDec
call	CrLf

pop edx
pop ecx
pop ebx
pop eax

pop ebp
ret 12
arraySum ENDP


;**************************************************************************************************************
; Procedure name: arrayAvg
; Description: Displays the average of the array's values
; Receives: @printAvgMsg, @average, @sum
; Returns: N/A
; Preconditions: 'sum' variable must be initialized
; Registers used: eax, ebx, edx
;
;The stack after pushing the old ebp:
;
; [EBP]		old EBP
; [EBP+4]	return @
; [EBP+8]	@printAvgMsg
; [EBP+12]	@average
; [EBP+16]	@sum
;
;***************************************************************************************************************
arrayAvg PROC
push ebp
mov ebp, esp

push eax
push ebx
push edx

mov ebx, [ebp+16]
mov eax, [ebx]
mov ebx, MAX
mov edx, 0
div ebx

mDisplayString [ebp+8]
call WriteDec
call CrLf
call CrLf

pop edx
pop ebx
pop eax

pop ebp
ret 12
arrayAvg ENDP


END main
