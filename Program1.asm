TITLE Project 6 - String Primatives and MACROs     (Proj6_turneste.asm)

; Author: Steven Turner
; Last Modified: 3/13/2021
; OSU email address: turneste@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number:                 Due Date: 3/14/2021
; Description: Program takes a signed decimal as a string, converts to decimal and calculates sum and average, then
;			   returns results back in the form of a string

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mgetString
;
; Description: Takes a number from user and stores string value in an array
; bytes are stored for use in ReadVal
;
; Preconditions: None
;
; Receives:
; _prompt	= prompt address
; _input	= strArray address
; _count	= USERNUMS
; _bytes	= bytes address
;
; returns: User input is placed in strArray
; ---------------------------------------------------------------------------------

mgetString MACRO _prompt, _input, _count, _bytes
  PUSH	EAX
  PUSH	ECX
  PUSH	EDX  
  PUSH	EDI
  
  MOV	EDX, _prompt
  CALL	WriteString

  MOV	EDX, _input
  MOV	ECX, _count
  CALL	ReadString
  MOV	EDI, _bytes
  MOV	[EDI], EAX
  CALL	CrLf


  POP	EDI
  POP	EDX
  POP	ECX
  POP	EAX

  ENDM

; ---------------------------------------------------------------------------------
; Name: mdisplayString
;
; Description: Displays number at given address
;
; Preconditions: Given address points to an array of ASCII characters
;
; Receives:
; _input	= address of number to be displayed
;
; returns: output to screen
; ---------------------------------------------------------------------------------
mdisplayString MACRO input
  PUSH	EDX
  
  MOV	EDX, input
  Call	WriteString

  POP	EDX
  ENDM

  USERNUMS = 10 ; number or inputs by user
  CALCNUMS = 1 ; number of calculations

.data

  intro		BYTE	"You will be asked to enter 10 signed integers. The numbers need to be small enough to fit in a 32 bit register.",13,10,0
  intro2	BYTE	"After you have entered 10 numbers, the sum and average will be displayed",13,10,10,0
  nameProj	BYTE	"Steven Turner             Project 6 - String Primatives and MACROS",13,10,10,0
  prompt	BYTE	"Please enter a signed integer: ",0
  validate	BYTE	"What you entered is either out of range or not a number.",13,10,0
  strArray	BYTE	120 DUP(0)
  strArray2	BYTE	120 DUP(0)
  strCount	DWORD	LENGTHOF strArray
  bytes		DWORD	?
  numArray	SDWORD	10 DUP(0)
  numCount	DWORD	LENGTHOF numArray
  sum		SDWORD	0
  average	SDWORD	?
  sumString	BYTE	12 DUP (0)
  avgString	BYTE	12 DUP (0)
  sumCount	DWORD	LENGTHOF sumString
  arrTitle	BYTE	"You entered the following numbers: ",13,10,10,0
  sumTitle	BYTE	"The sum of these numbers is: ",13,10,10,0
  avgTitle	BYTE	"The average of these numbers is: ",13,10,10,0

.code
main PROC

  ; Display name and project title
  PUSH	OFFSET intro2
  PUSH	OFFSET intro
  PUSH	OFFSET nameProj
  CALL	Introduction

  ; Get 10 signed integers from the user
  PUSH	OFFSET validate
  PUSH	OFFSET numArray
  PUSH	OFFSET prompt
  PUSH	OFFSET strArray
  PUSH	USERNUMS
  PUSH  OFFSET bytes
  CALL	ReadVal

  ; Convert numbers back to string for outputting
  PUSH	USERNUMS
  PUSH	strCount
  PUSH	OFFSET strArray2
  PUSH	OFFSET numArray
  CALL	NumToAscii

  ; Display numbers entered back to user
  PUSH	OFFSET arrTitle
  PUSH	USERNUMS
  PUSH	strCount
  PUSH	OFFSET strArray2
  CALL	WriteVal

  ; Calculate sum and average
  PUSH	OFFSET average
  PUSH	USERNUMS
  PUSH	OFFSET numArray
  PUSH	OFFSET sum
  CALL	Calculations

  ; Convert sum to string for output
  PUSH	sumCount
  PUSH	OFFSET sumString
  PUSH	OFFSET sum
  CALL	SingleNumToAscii

    ; Display sum to user
  PUSH	OFFSET sumTitle
  PUSH	CALCNUMS
  PUSH	sumCount
  PUSH	OFFSET sumString
  CALL	WriteVal

  ; Convert average to string for output
  PUSH	sumCount
  PUSH	OFFSET avgString
  PUSH	OFFSET average
  CALL	SingleNumToAscii

  ; Display average to user
  PUSH	OFFSET avgTitle
  PUSH	CALCNUMS
  PUSH	sumCount
  PUSH	OFFSET avgString
  CALL	WriteVal

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;------------------------------------------------------------------
;Name: introduction
;Description: Displays programmer and title, explains program to user
;Preconditions: None
;Postconditions: None
;Receives: intro, intro2, nameProj
;Returns: None
;------------------------------------------------------------------

Introduction PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	EDX
  
  MOV	EDX, [EBP+8]
  CALL	WriteString

  MOV	EDX, [EBP+12]
  CALL	WriteString

  MOV	EDX, [EBP+16]
  CALL	WriteString

  POP	EDX
  POP	EBX

  RET	12

Introduction ENDP

;------------------------------------------------------------------
;Name: ReadVal
;Description: Takes 10 signed integers as strinfs from the user, validates they can fit
; in a 32 bit register and are numbers, then converts the strings to numbers for
; processing.
;Preconditions: None
;Postconditions: None
;Receives: validate, numArray, prompt, strCount, mgetString
;Returns: strArray
;------------------------------------------------------------------

ReadVal PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
  PUSH	ESI
  PUSH	EDI

  MOV	EDI, [EBP+24] ; number array
  MOV	ESI, [EBP+16] ; string array
  MOV	EDX, [EBP+12] ; 10 numbers inputted

  _InputLoop:
      PUSH	EDI
	  PUSH	EDX
	  PUSH  ESI

	  MOV	EBX, 0 ; set initial value for negative number check
	  CLD
	  
	  _NewNum:
	  mgetString [EBP+20], ESI, 12, [EBP+8]

	  MOV	EAX, [EBP+8] ; number of bytes read for validate loop
	  MOV	ECX, [EAX]
	  MOV	EAX, 0 	  
	  LODSB

	  CMP	AL, 43  ; check plus sign
	  JNE	_NegSign
	  LODSB  ; move past sign

	  SUB	ECX, 1
	  CMP	ECX, 0
	  JE	_Invalid ; single char entered

	  JMP	_ValidateLoop

	  _NegSign:
		  CMP	EAX, 45 ; check negative sign
		  JNE	_ValidateLoop

		  CMP	ECX, 11 ; Greater than 10 bytes entered will not fit in 32-bit reg
		  JG	_Invalid

		  MOV	EBX, 1	; store to set negative num
		  LODSB
	  
		  SUB	ECX, 1
		  CMP	ECX, 0
	  JE	_Invalid

	  ; Check if number less than -2,147,483,648
	  CMP	ECX, 10
	  JL	_Lower			
			
	  CMP	AL, 50  ;2
	  JG	_Invalid
	  LODSB
	  CMP	AL, 49   ;1
	  JG	_Invalid
	  LODSB
	  CMP	AL, 52   ;4
	  JG	_Invalid
	  LODSB
	  CMP	AL, 55   ;7
	  JG	_Invalid
	  LODSB
	  CMP	AL, 52   ;4
	  JG	_Invalid
	  LODSB
	  CMP	AL, 56   ;8
	  JG	_Invalid
	  LODSB
	  CMP	AL, 51   ;3
	  JG	_Invalid
	  LODSB
	  CMP	AL, 54   ;6
	  JG	_Invalid
	  LODSB
	  CMP	AL, 52   ;4
	  JG	_Invalid
   	  LODSB
	  CMP	AL, 56   ;8
	  JG	_Invalid
			
	  SUB	ESI, 9
	  JMP	_Lower 

	  _Invalid:
	  POP	ESI
	  PUSH	ESI
	  MOV	EDX, [EBP+28]
	  CALL	WriteString
	  JMP	_NewNum
	  
	_ValidateLoop:
		CMP	ECX, 10 ; Greater than 10 bytes entered will not fit in 32-bit reg
		JG	_Invalid


	; Check if number greater than 2,147,483,647
		CMP	ECX, 10
		JL	_Lower			
			
		CMP	AL, 50  ;2
		JG	_Invalid
		LODSB
		CMP AL, 49   ;1
		JG	_Invalid
		LODSB
		CMP AL, 52   ;4
		JG	_Invalid
		LODSB
		CMP AL, 55   ;7
		JG	_Invalid
		LODSB
		CMP AL, 52   ;4
		JG	_Invalid
		LODSB
		CMP AL, 56   ;8
		JG	_Invalid
		LODSB
		CMP AL, 51   ;3
		JG	_Invalid
		LODSB
		CMP AL, 54   ;6
		JG	_Invalid
		LODSB
		CMP AL, 52   ;4
		JG	_Invalid
		LODSB
		CMP AL, 55   ;7
		JG	_Invalid
			
		SUB	ESI, 9

	_Lower:
		; check num is within bounds
		CMP	AL, 57
		JG	_Invalid
		CMP	AL, 48 
		JGE	_Valid
		JMP	_Invalid

		_Valid:		
	LODSB
    LOOP	_ValidateLoop
	  

	POP   ESI

	; convert ASCII character to num
	PUSH	EBX ; negative "flag"
	PUSH	[EBP+8] ; bytes read
	PUSH	ESI ; string array loc
	PUSH	EDI ; num array loc
	CALL	AsciiToNum

	POP	EDX
	POP	EDI
	ADD	ESI, 12
	ADD	EDI, 4

    DEC	EDX
    CMP	EDX, 0
    JE	_ExitLoop
    JMP	_InputLoop

  _ExitLoop:
  
  POP	EDI
  POP	ESI
  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX
  POP	EBP
  RET	24

ReadVal ENDP

;------------------------------------------------------------------
;Name: AsciiToNum
;Description: converts an array a ascii characters, and converts them
; to there respective number
;Preconditions: Number string has been entered and validated in ReadVal
; ESI, EDI, bytes and EBX have been filled by Readval before being pushed.
;Postconditions: None
;Receives: strArray and numArray offset, bytes, EBX containing a value
; that determines sign
;Returns: numArray
;------------------------------------------------------------------

AsciiToNum PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	ESI
  PUSH	EDI
  PUSH	ECX
  PUSH	EAX
  PUSH	EDX

  CLD
  MOV	ESI, [EBP+16]
  MOV	ECX, [ESI] ; number of bytes read

  MOV	ESI, [EBP+12] ; string starting location
  MOV	EDI, [EBP+8]  ; number starting location

  MOV	EBX, 0

  MOV	EAX, 0  
  MOV	EDX, [EBP+20] ; negative check
  PUSH	EDX
  CMP	EDX, 0
  JE	_convertAscii
  LODSB ; if negative move past and negate final result
  DEC	ECX

_convertAscii:
  MOV	EAX, EBX
  MOV	EDX, 10
  MUL	EDX
  MOV	EBX, EAX ; new factor which is equal to 10x old number

  MOV	EAX, 0
  LODSB
  SUB	EAX, 48  ; convert letter to num
  ADD	EBX, EAX ; add factor to num, then loop for how many bytes have been read

  LOOP	_convertAscii

  POP	EDX
  CMP	EDX, 0
  JE	_Finish
  NEG	EBX  ; negate if number was negative

_Finish:
  MOV	[EDI], EBX

  POP	EDX
  POP	EAX
  POP	ECX
  POP	EDI
  POP	ESI
  POP	EBP
  RET	16
AsciiToNum ENDP

;------------------------------------------------------------------
;Name: Calculations
;Description: Calcualates the sum and average of an array of numbers
; given by ReadVal
;Preconditions: ReadVal has read 10 valid numbers and converted them
; from ASCII characters to numbers
;Postconditions: None
;Receives: numArray, arraysize
; that determines sign
;Returns: sum, average
;------------------------------------------------------------------

Calculations PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH  ESI
  PUSH  ECX
  PUSH	EAX

  MOV	EDI, [EBP+8]
  MOV	ESI, [EBP+12] ; num array
  MOV	ECX, [EBP+16] ; array size
_CalcLoop: ; calculate sum
  MOV	EAX, [ESI]
  ADD	[EDI], EAX ; sum
  ADD	ESI, 4
  LOOP	_CalcLoop

  MOV	EAX, [EDI]
  MOV	EBX, 10 
  CDQ
  IDIV	EBX
  MOV	EDI, [EBP+20]  ; calculate average
  MOV	[EDI], EAX

  POP	EAX
  POP	ECX
  POP	ESI
  POP	EBP
  RET	16
Calculations ENDP

;------------------------------------------------------------------
;Name: NumToAscii
;Description: Converts an array of numbers to there ASCII representations
;Preconditions: Number string has been entered and validated in ReadVal,
; and then converted numbers
;Postconditions: None
;Receives: numArray, USERNUMS, arraysize
;Returns: strArray2
;------------------------------------------------------------------

NumToAscii PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	ESI
  PUSH	EDI
  PUSH	ECX
  PUSH	EAX
  
  MOV	ECX, [EBP+20]; user nums
  MOV	EDI, [EBP+12] ; string loc
  ADD	EDI, [EBP+16] ; array size
  DEC	EDI

  MOV	ESI, [EBP+8] ; num loc
  ADD	ESI, 36
  STD

_convertNum:
  PUSH	ECX ; Loop for each number entered

  MOV	AL, 0
  STOSB

  MOV	ECX, 10 ; for each potential digit in num

  MOV	EDX, 0
  PUSH	EDX
  MOV	EAX, [ESI]
  CMP	EAX, 0 ; check if it is a negative number
  JG	_positive
  POP	EDX
  NEG	EAX
  MOV	EDX, 1
  PUSH	EDX

  DEC	ECX
  
  _positive:

  MOV	EDX, 0
  MOV	EBX, 10 
  DIV	EBX  ; divide the first number by 10
  MOV	EBX, EAX

  CMP	EAX, 0
  JE	_complete
 
  MOV	EAX, 0
  MOV	AL, DL ; put remainder, which is the last character, into string array
  ADD	AL, 48 ; convert to ascii
  STOSB
  MOV	EAX, EBX
  LOOP	_positive

_complete:
  MOV	AL, DL
  ADD	AL, 48
  STOSB

  POP	EDX
  CMP	EDX, 1
  JNE	_noSign
  MOV	AL, 45
  STOSB

_noSign:
  SUB	ESI, 4
  POP	ECX
  LOOP	_convertNum

  POP	EAX
  POP	ECX
  POP	EDI
  POP	ESI
  POP	EBP

  RET	16

NumToAscii ENDP

;------------------------------------------------------------------
;Name: SingleNumToAscii
;Description: Converts a single number to ASCII representation
;Preconditions: Number string has been entered and validated in ReadVal,
; and then converted numbers, and Calculations has been run
;Postconditions: None
;Receives: sum, average, bytes, arraysize
;Returns: sumArray or avgArray
;------------------------------------------------------------------

SingleNumtoAscii PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	ESI
  PUSH	EDI
  PUSH	ECX
  PUSH	EAX
  
  MOV	EDI, [EBP+12] ; string loc
  ADD	EDI, [EBP+16]
  DEC	EDI

  MOV	ESI, [EBP+8] ; num loc
  STD

  MOV	AL, 0
  STOSB

  MOV	ECX, 10

  MOV	EDX, 0
  PUSH	EDX
  MOV	EAX, [ESI] ; Load first number into esi
  CMP	EAX, 0 ; check if it is a negative number
  JGE	_positive
  POP	EDX
  NEG	EAX
  MOV	EDX, 1
  PUSH	EDX

  DEC	ECX
  
  _positive:

  MOV	EDX, 0
  MOV	EBX, 10 
  DIV	EBX  ; divide the first number by 10
  MOV	EBX, EAX

  CMP	EAX, 0
  JE	_complete
 
  MOV	EAX, 0
  MOV	AL, DL ; put remainder, which is the last character, into string array
  ADD	AL, 48 ; convert to ascii
  STOSB
  MOV	EAX, EBX
  LOOP	_positive

_complete:
  MOV	AL, DL
  ADD	AL, 48
  STOSB

  POP	EDX
  CMP	EDX, 1
  JNE	_noSign
  MOV	AL, 45
  STOSB

_noSign:
  POP	EAX
  POP	ECX
  POP	EDI
  POP	ESI
  POP	EBP

  RET	12
SingleNumtoAscii ENDP

;------------------------------------------------------------------
;Name: WrteVal
;Description: Takes an array or single number of ASCII characters and outputs to screen
;Preconditions: NumToAscii or SingleNumToAscii have filled there respective arrays
;Postconditions: None
;Receives: sumArray/avgArray/strArray2 along with their title, the number of values to be
; displayed, and their array size
;Returns: none
;------------------------------------------------------------------

WriteVal PROC
  PUSH	EBP
  MOV	EBP, ESP

  MOV	EDX, [EBP+20] ; title
  CALL	WriteString

  MOV	ECX, [EBP+16] ; number of values to be displayed
  MOV	EDI, [EBP+8] ; input array

  CLD

  ; conversion to ASCII put values at end of array
  ; scan until there is a zero then begin reading
  PUSH	ECX
  MOV	ECX, [EBP+12] ; array size
  MOV	AL, 0
  REPZ	SCASB
  POP	ECX

  DEC	EDI

_DisplayLoop:
  mdisplayString EDI

  CMP	ECX, 1
  JE	_NoComma

  MOV	AL, 44
  CALL  WriteChar
  MOV	AL, 32
  CALL	WriteChar

  _NoComma:
  ; conversion to ascii added 0's at the end of each num
  ; scan for next 0, and next num will be after that 0
  PUSH	ECX
  MOV	ECX, 120
  MOV	AL, 0
  REPNZ	SCASB
  POP	ECX

  LOOP	_DisplayLoop
  CALL	CrLF
  CALL	CrLF
  POP	EBP
  RET	16

WriteVal ENDP

END main
