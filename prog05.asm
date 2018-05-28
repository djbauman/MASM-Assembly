TITLE Program 5     (prog05.asm)
; Author: Daniel Bauman
; Date: 11-17-2017
; Description: This program generates a list of random numbers of a size
; specified by the user. It prints this list, displays the median value,
; then prints the list again in descending order.

INCLUDE Irvine32.inc
MIN = 10
MAX = 200
LO = 100
HI = 999

.data
intro1			BYTE "Welcome to Random Number Sort by Daniel Bauman.",0
prompt1			BYTE "Enter how many numbers to generate in the range [10, 200]: ",0
error1			BYTE "That number is not in the range [10, 200]. Try again.",0
title1				BYTE "Unsorted List:",0
title2				BYTE "Sorted List:",0
title_median	BYTE "Median: ",0

request			DWORD ?

array				DWORD	MAX DUP(?) ; an array with space for "MAX" 32-bit integers (200 by default)
count				DWORD	0

spaces			BYTE 	"   ",0
print_count		DWORD 0
line_count		DWORD 10


.code
main PROC
call	Randomize			; seed the random number generator

call	introduction		; introduce the program

push	OFFSET request	; pass "request" by reference
call	getData				; get user input (request)

push	OFFSET array		; pass "request" by value
push	request				; pass array by reference
call	fillArray

push	OFFSET array
push	request
push	OFFSET title1
call	displayList			; 1st call to displayList (unsorted)

push	OFFSET array		
push	request				
call	sortList

push	OFFSET array
push	request
call	displayMedian

push	OFFSET array
push	request
push	OFFSET title2
call	displayList			; 2nd call to displayList (sorted)

	exit						; exit to operating system
main ENDP

;------------------------------------------------------------------------------
;  PROCEDURES

; Procedure name: Introduction
; Description: Greets the user
; Receives: N/A
; Returns: N/A
; Preconditions: N/A
; Registers changed: edx
introduction PROC
push	edx

mov	edx, OFFSET intro1
call	WriteString
call 	CrLf
call 	CrLf

pop	edx
	ret
introduction ENDP


; Procedure name: getData
; Description: Prompts the user for input and saves this input
;			   into a variable
; Receives: "Request" variable on system stack [ebp+8]
; Returns: User's validated input in variable "request"
; Preconditions: N/A
; Registers changed: eax, ebx, edx
getData PROC
push		ebp							;Set up stack frame
mov		ebp, esp

getData_start:						;get user's input into the "request" variable	
mov		ebx, [ebp+8]				;Get address of "request" into ebx
mov		edx, OFFSET prompt1	;Prompt user for input
call		WriteString
call		ReadInt
mov		[ebx], eax					;Store user input at address in ebx

validate_start:						;validate the user's input to be in the range [10, 200]
cmp		eax, MIN
JL			validate_error
cmp		eax, MAX
JG		validate_error
jmp		validate_success

validate_error:
mov		edx, OFFSET error1
call		WriteString
call		CrLf
call		CrLf
jmp		getData_start

validate_success:

ret		4								;ret 4 because we had one parameter, a DWORD (4 bytes), pushed on the stack
pop		ebp							;Restore stack
getData ENDP



; Procedure name: fillArray
; Description: Fills the passed array with as many random numbers
; as requested by the user.
; Receives: Request variable in [ebp+8], address of array in [ebp+12]
; Returns: Filled array
; Preconditions: N/A
; Registers changed: eax, ecx, edi
fillArray PROC
push		ebp					;Set up stack frame
mov		ebp, esp
mov		edi, [ebp+12]		; get @array into edi
mov		ecx, [ebp+8]		; mov "request" into ecx

fillArray_loop:
mov		eax, HI				; Generate a random number into eax:
sub		eax, LO
add		eax, 1				; get into eax the range (high - low + 1)
call		RandomRange			; get into eax a value in [0 .. range-1]
add		eax, LO

mov		[edi], eax
add		edi, 4
loop 		fillArray_loop

pop		ebp
ret		8
fillArray ENDP



; Procedure name: sortList
; Citation: Irvine, Kip R., Assembly Language for x86 Processors, 7th Edition, pg. 375
; Description: Sorts the passed array in descending order
; Receives: @array [ebp+12], request [ebp+8]
; Returns: Sorted array
; Preconditions: N/A
; Registers changed: eax, ecx, esi
sortList PROC
push		ebp					;Set up stack frame
mov		ebp, esp

mov		ecx, [ebp+8]
dec		ecx

L1:
push		ecx
mov		esi, [ebp+12]

L2:
mov		eax, [esi]
cmp		[esi+4], eax
jl			L3
xchg		eax, [esi+4]		; (Built in xchg procedure)
mov		[esi], eax

L3:
add		esi, 4
loop		L2

pop		ecx
loop		L1

L4:
pop		ebp
ret		8
sortList ENDP


; Procedure name: displayMedian 
; Description: Calculates and prints the median of the passed array
; Receives: @array [ebp+12], request [ebp+8]
; Returns: None (prints median)
; Preconditions: N/A
; Registers changed: eax, ebx, edx, esi
displayMedian PROC
push		ebp								;Set up stack frame
mov		ebp, esp
push		eax					
push		ebx
push		edx								; push registers that will be used (eax, ebx, edx)

mov		eax, [ebp+8]					; move to eax the number of elements in the array
mov		ebx, 2
mov		edx, 0
div		ebx								; divide eax by 2 (integer division, ignoring remainder)

mov		ebx, 4
push		edx
mul		ebx								; multiply eax by 4
pop		edx
mov		ebx, eax						; mov to ebx eax (should be the number needed to add to the base address of @array to find the median value)

cmp		edx, 0							; if there is no remainder (because of an even number of elements), eax will hold the address of the index that, when averaged with the previous index, will give the median
JE			displayMedian_average

displayMedian_exact:					; if there is a remainder, do the following

mov		esi, [ebp+12]					; move to esi the address of the array
mov		eax, [esi+ebx]				; move to eax the value stored at the median's address
call		CrLf
mov		edx, OFFSET title_median
call		WriteString
call		WriteDec
call		CrLf
call		CrLf
jmp		displayMedian_end

displayMedian_average:				; if there is no remainder, do this
mov		esi, [ebp+12]
mov		eax, [esi+ebx]
add		eax, [esi+ebx-4]
mov		edx, 0
mov		ebx, 2
div		ebx

call		CrLf
mov		edx, OFFSET title_median
call		WriteString
call		WriteDec
call		CrLf
call		CrLf

displayMedian_end:
pop		edx
pop		ebx
pop		eax
pop		ebp
ret		8
displayMedian ENDP



; Procedure name: displayList
; Description: Prints the current array
; Receives: @array [ebp+16], request [ebp+12], @title [ebp+8]
; Returns: N/A
; Preconditions: N/A
; Registers changed: eax, ecx, edx, esi
; Note: Push order is OFFSET array (ebp+16), then request by value (ebp+12), then OFFSET title1 or title2 (ebp+8)
displayList PROC
push	ebp
mov		ebp, esp
mov		esi, [ebp+16]		; move to esi the address of the array (@array)
mov		ecx, [ebp+12]		; move to ecx the number of values in the array
mov		edx, [ebp+8]		; mov to edx the address of the title that was pushed

call		WriteString			; print the title that was pushed
call		CrLf
displayList_loop:
mov		eax, [esi]			; get current element into eax


; Sub-procedure name: newLineCheck 
; Description: Prints a new line every 10 values
; Trying to pass these by value and by reference caused displayList 
; to malfunction in its first call, but not its second (???). Not
; yet resolved.
push		eax
push		edx
mov		eax, print_count
mov		edx, 0
div		line_count
cmp		edx, 0
JE			newLineCheck_CrLf
JNE		newLineCheck_end

newLineCheck_CrLf:
call		CrLf

newLineCheck_end:
pop		edx
pop		eax
;
call		WriteDec
mov		edx, OFFSET spaces
call		WriteString
add		esi, 4
add		print_count, 1
loop		displayList_loop

mov		print_count, 0	; reset print_count to 0
call		CrLf

pop		ebp
ret		12
displayList ENDP


END main
