TITLE Project 4: Nested Loops and Procedures    (Proj4_turneste.asm)

; Author: Steven Turner
; Last Modified: 02/17/2021
; OSU email address: turneste@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number: 4                Due Date: 02/21/2021
; Description: Takes a number "n" given by user input, and returns a list containing "n" prime numbers

INCLUDE Irvine32.inc
  ; Lower and upper bounds are defined as constants
  LOWERBOUND = 1
  UPPERBOUND = 4000

.data
  ;introduction
  projName		BYTE	"Project 4: Nested Loops and Procedures              Steven Turner",13,10,13,10,0
  extraCred1	BYTE	"**EC:Columns are aligned to first digit",13,10,0
  extraCred2	BYTE	"**EC:4000 numbers display, 20 lines at a time",13,10,13,10,0
  greeting		BYTE	"Enter number of primes you wish to be displayed. Your value must be an integer 1 <= n <= 4000",13,10,13,10,0

  ;getUserData
  prompt		BYTE	"Please enter an integer: ",0
  userData		DWORD	?
  currentNum	DWORD	?

  ;validate
  invalid		BYTE	"Out of range, please enter a valid integer: ",0

  ;format
  oneSpace		BYTE	"   ",0
  twoSpace		BYTE	"    ",0
  threeSpace	BYTE	"     ",0
  fourSpace		BYTE	"      ",0
  fiveSpace		BYTE	"       ",0
  returnCount	DWORD	0

  ;showPrime
  continue		BYTE	"Press any key to continue: ",0

  ;farewell
  goodbye		BYTE	"Goodbye",13,10,0

.code
main PROC
  ; Program introduction
  CALL	introduction
  ; Request user data and validate
  CALL	getUserData
  ; Show number of primes requested by user input
  CALL	showPrimes
  ; Say farewell
  CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; -------------------------------------------------------------------
; Name: introduction
; 
; Displays program, programmer name, extra credit, and program
;	instructions
;
; Preconditions: None
; Postconditions: None
; Receives: projName, extraCred1, extraCred2, and greeting 
; Returns: None
; -------------------------------------------------------------------
introduction PROC
  PUSH	EDX

  MOV	EDX, OFFSET projName
  CALL	WriteString
  MOV	EDX, OFFSET extraCred1
  CALL  WriteString
  MOV	EDX, OFFSET extraCred2
  CALL  WriteString
  MOV	EDX, OFFSET greeting
  CALL  WriteString
  
  POP	EDX
  RET
introduction ENDP

; -------------------------------------------------------------------
; Name: getUserData
;
; Receives user input and stores in variable "userData"
;
; Preconditions: None
; Postconditions: None
; Receives: prompt
; Returns: userData
; -------------------------------------------------------------------
getUserData PROC
  PUSH	EAX
  PUSH	EDX
  
  MOV	EDX, OFFSET prompt
  CALL	WriteString
  CALL	ReadInt
  MOV	userData, EAX

  CALL	validate  ; confirm user data is in range
  CALL	CrLf
  POP	EDX  
  POP	EAX
  RET
getUserData ENDP

; -------------------------------------------------------------------
; Name: validate
;
; Checks if userData is valid, continues to prompt for valid entry
;		until user enters a valid number
;
; Preconditions: userInput must contain user input
; Postconditions: none
; Receives: userData, LOWERBOUND, UPPERBOUND, invalid
; Returns: userData
; -------------------------------------------------------------------
validate PROC
  PUSH EAX
  PUSH EDX

_check:  ; Check if value is within bounds
  MOV	EAX, userData
  CMP	EAX, LOWERBOUND
  JL	_invalid
  MOV	EAX, userData
  CMP	EAX, UPPERBOUND
  JG	_invalid
  JMP	_valid

_invalid:  ; prompt user for another number
  MOV	EDX, OFFSET invalid
  CALL	WriteString
  CALL  ReadInt
  MOV	userData, EAX
  JMP   _check

_valid:
  POP	EDX
  POP	EAX
  RET
validate ENDP

; -------------------------------------------------------------------
; Name: showPrimes
;
; Display number of primes equal to userData
;
; Preconditions: userNum entered and valid
; Postconditions: none
; Receives: userData, currentNum, returnCount, continue
; Returns: none
; -------------------------------------------------------------------
showPrimes PROC
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX

  MOV	EBX, 1
  MOV	ECX, userData  

_PrintCheck:
  INC	EBX
  MOV	currentNum, EBX

  CALL	isPrime  ; Check if num is prime
  
  CMP	currentNum, 0  ; Do not print non prime nums
  JE	_PrintCheck
  
  INC	returnCount 

  MOV	EAX, EBX
  CALL	WriteDec

  CALL	format  ; Format spacing and line carraige returns
   
  MOV	EAX, returnCount ; Wait for user to press any key after 20 lines
  MOV	EDX, 0
  PUSH	EBX
  MOV	EBX, 200
  DIV	EBX
  POP	EBX
  CMP	EDX, 0
  JNE	_PrintLoop

  MOV	EDX, OFFSET continue
  CALL	WriteString
  CALL	ReadChar
  CALL	CrLF

_PrintLoop:
  LOOP	_PrintCheck

  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX
  RET
showPrimes ENDP

; -------------------------------------------------------------------
; Name: isPrime
;
; Sets currentNum to 0 if not prime, otherwise currentNum retains value
;
; Preconditions: currentNum contains value from showPrimes
; Postconditions: none
; Receives: currentNum
; Returns: currentNum
; -------------------------------------------------------------------
isPrime PROC
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
    
  MOV	EBX, 1 ; Set loop conditions
  MOV	ECX, 9

_checkPrime:
  INC	EBX
  MOV	EAX, currentNum
  CMP	EBX, EAX
  JE	_checkPrime ; loop back if current num = num being checked

  MOV	EAX, currentNum
  MOV	EDX, 0
  DIV	EBX
  CMP	EDX, 0
  JE	_notPrime	; Not prime if remainder is 0
  LOOP  _checkPrime
  JMP	_Finish

_notPrime:
  MOV	currentNum, 0
  JMP	_Finish

_Finish:
  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX

  RET
isPrime ENDP
; -------------------------------------------------------------------
; Name: format
;
; Adds spacing contigent on number of digits in number, and carriage
;		return every 10 numbers
;
; Preconditions: currentNum contains prime number from isPrime
; Postconditions: none
; Receives: currentNum, oneSpace, twoSpace, threeSpace, fourSpace, 
;		fiveSpace, returnCount
; Returns:
; -------------------------------------------------------------------
format PROC
  PUSH	EDX

  CMP	currentNum, 10
  JL	_fiveSpace
  CMP	currentNum, 100
  JL	_fourSpace
  CMP	currentNum, 1000
  JL	_threeSpace
  CMP	currentNum, 10000
  JL	_twoSpace

  MOV	EDX, OFFSET oneSpace
  CALL	WriteString
  JMP	_spaceDone

_twoSpace:
  MOV	EDX, OFFSET twoSpace
  CALL	WriteString
  JMP	_spaceDone

_threeSpace:
  MOV	EDX, OFFSET threeSpace
  CALL	WriteString
  JMP	_spaceDone

_fourSpace:
  MOV	EDX, OFFSET fourSpace
  CALL	WriteString
  JMP	_spaceDone

_fiveSpace:
  MOV	EDX, OFFSET fiveSpace
  CALL	WriteString

_spaceDone:  ; Add carriage return at 10 nums
  MOV	EAX, returnCount
  MOV	EDX, 0
  PUSH	EBX
  MOV	EBX, 10
  DIV	EBX
  POP	EBX
  CMP	EDX, 0
  JNE	_formatComplete
  CALL	CrLf

_formatComplete:
  POP	EDX
  RET
format ENDP

; -------------------------------------------------------------------
; Name: farewell
;
; Say goobye to user
;
; Preconditions: none
; Postconditions: none
; Receives: goodbye
; Returns: none
; -------------------------------------------------------------------
farewell PROC
  PUSH	EDX

  CALL	CrLf
  CALL	CrLf
  MOV	EDX, OFFSET goodbye
  CALL	WriteString

  POP	EDX
  RET
farewell ENDP

END main