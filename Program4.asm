TITLE Project 3 - Data Validation, Looping, and Constants     (Proj3_turneste.asm)

; Author: Steven Turner
; Last Modified: 02/06/2021
; OSU email address: turneste@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number: 3             Due Date: 02/07/2021
; Description: Asks user to input a number in given range until a positive number is entered. After
;			   a positive number is entered, displays number of valid numbers entered, sum, max, min,
;              average rounded to 0 decimal places, and average rounded to 2 decimal places.

INCLUDE Irvine32.inc

  ; Constants for user input validation
  lowBound1		=	-200
  highBound1	=	-100
  lowBound2		=	-50
  highBound2	=	-1

.data
  ; Name, program, and extra credit
  nameAndProg	BYTE	"Steven Turner             Project 3 - Data Validation, Looping, and Constants",13,10,0
  extraCred1	BYTE	"**EC: Program numbers lines during user input",13,10,0
  extraCred2	BYTE	"**EC: Program calculates and displays average as a decimal point number",13,10,0

  ; User name and integer
  space			BYTE	" ",0
  decimal		BYTE	".",0
  prompt1		BYTE	"Please enter your name: ",0
  userName		BYTE	33 DUP(0)
  lineCounter	DWORD	?
  userGreet		BYTE	"Hello, ",0
  prompt2		BYTE	"Please enter a number between -200 and -100 or -50 and -1: ",0
  userNum   	SDWORD	?
  invalid		BYTE	"Invalid number",13,10,0

  ; Arithmetic calculations and display
  counter		SDWORD	?
  counterDisp	BYTE	"The number of valid integers entered is: ",0
  sum			SDWORD	?
  sumDisp		BYTE	"The sum is: ",0
  min			SDWORD	?
  minDisp		BYTE	"The minimum is: ",0
  max			SDWORD	?
  maxDisp		BYTE	"The max is: ",0
  avg   		SDWORD	?
  remainder     SDWORD  ?
  avgDisp	    BYTE	"The average is: ",0
  decAvg        SDWORD  ?
  decAvgRem		SDWORD  ?
  decAvgTens	SDWORD  ?
  decAvgHunds	SDWORD  ?
  decAvgDisp	BYTE	"The average rounded to two decimal places is: ",0

  ; Parting message
  goodbye		BYTE	"Goodbye, ",0

  .code
main PROC
;----------------------------------------------------------
; Displays programmer name and program, and which extra
;		credit options were chosen
;----------------------------------------------------------

  MOV	EDX, OFFSET nameAndProg
  CALL	WriteString

  MOV	EDX, OFFSET extraCred1
  CALL	WriteString

  MOV	EDX, OFFSET extraCred2
  CALL  WriteString
  CALL  CrLf

;----------------------------------------------------------
; Prompt user for name, and greet user. Promt user for
;		valid integer, and display error message if not in
;		range. Continue to ask for integer until a positive
;		integer is entered
;----------------------------------------------------------

  ; User greeting
  MOV	EDX, OFFSET prompt1
  CALL	WriteString

  MOV	EDX, OFFSET userName
  MOV	ECX, 32
  CALL	ReadString

  MOV	EDX, OFFSET userGreet
  CALL  WriteString

  MOV	EDX, OFFSET userName
  CALL	WriteString
  CALL  CrLf
  CALL  CrLf

  ; Input validation of users number
_NumCheck:
  ADD	lineCounter, 1 ;increment counter for display only
  MOV	EAX, lineCounter
  CALL  WriteDec

  MOV	EDX, OFFSET decimal
  CALL	WriteString

  MOV	EDX, OFFSET space
  CALL  WriteString

  MOV	EDX, OFFSET prompt2
  CALL	WriteString

  CALL	ReadInt
  MOV	userNum, EAX

  ; is num < -200
  MOV	EAX, userNum
  CMP	EAX, lowBound1
  JS	_NumInvalid

  ; is num > -100
  MOV	EBX, highBound1
  CMP	EBX, EAX
  JNS	_NumValid ; if number passed first boundry, valid num

    ; is num > -1
  MOV	EBX, highBound2
  CMP	EBX, EAX
  JS	_Finish

  ; is num < -50
  CMP	EAX, lowBound2
  JS	_NumInvalid

  JMP	_NumValid

  ; Display error message and loop back for invalid number
_NumInvalid:
  MOV	EDX, OFFSET invalid
  CALL	WriteString
  JMP	_NumCheck

;----------------------------------------------------------
; When a valid number is entered, store number or valid
;		numbers entered, min, max, sum, rounded average,	
;		and decimal rounded average
;----------------------------------------------------------

_NumValid:
  ;increment counter for calcs
  INC	counter

  ; calculate sum
  MOV	EAX, sum
  ADD	EAX, userNum
  MOV	sum, EAX

  ; Check if min
  MOV	EAX, userNum
  CMP	EAX, min
  JNS	_Max
  MOV	min, EAX

_Max: ; Check if max
  MOV	EAX, max
  CMP	EAX, 0
  JE	_InitialMax ; Set max if current value is 0
  MOV	EAX, userNum
  CMP	EAX, max
  JS	_Avg
  MOV	max, EAX
  JMP	_Avg

_InitialMax: ; Set initial max value
  MOV	EAX, userNum
  MOV	max, EAX

  ; Calculate average
_Avg:
  MOV   EAX, sum
  CDQ
  IDIV  counter
  MOV   avg, EAX
  MOV   remainder, EDX

  ; Round up or down
  MOV   EAX, remainder
  ADD   EAX, remainder
  NEG	EAX
  CMP   EAX, counter
  JLE   _DecAvg  ; If 2 x remainder is more than divisor of average (counter), decimal is > .5
  MOV   EAX, avg
  SUB   EAX, 1
  MOV   avg, EAX

  ; Calculate decimal rounded average
_DecAvg:
  MOV	EAX, sum
  CDQ
  IDIV	counter
  MOV	decAvg, EAX
  MOV	decAvgRem, EDX
  
  ; Calculates tenths place
  MOV	EAX, decAvgRem
  MOV	EBX, 10
  IMUL	EBX
  CDQ
  IDIV	counter
  MOV	decAvgTens, EAX
  MOV	decAvgRem, EDX

  ; Calculate hundreths place
  MOV	EAX, decAvgRem
  MOV	EBX, 10
  IMUL	EBX
  CDQ	
  IDIV	counter
  MOV	decAvgHunds, EAX
  JMP	_NumCheck

_Finish:
;----------------------------------------------------------
; Dispaly number of valid numbers entered, sum, max, min,
;		rounded average, and decimal average to two decimal
;		places, and display a parting message. If no valid
;		numbers entered, skip to parting message
;----------------------------------------------------------
  CALL CrLf
  ; Count of validated numbers entered. if not valid inputs entered, display message and skip to f
  MOV	EAX, counter
  CMP	EAX, 0
  JE	_Goodbye
  MOV	EDX, OFFSET counterDisp
  CALL	WriteString
  CALL	WriteDec
  CALL  CrLf

  ; Sum of valid numbers
  MOV	EDX, OFFSET sumDisp
  CALL	WriteString
  MOV	EAX, sum
  CALL	WriteInt
  CALL  CrLf

  ; Max number
  MOV	EDX, OFFSET maxDisp
  CALL	WriteString
  MOV	EAX, max
  CALL	WriteInt
  CALL  CrLf

  ; Min number
  MOV	EDX, OFFSET minDisp
  CALL	WriteString
  MOV	EAX, min
  CALL	WriteInt
  CALL  CrLf

  ; Average, rounded to 0 decimal places
  MOV	EDX, OFFSET avgDisp
  CALL	WriteString
  MOV	EAX, avg
  CALL	WriteInt
  CALL  CrLf

  ; Average, rounded to 2 decimal places
  MOV	EDX, OFFSET decAvgDisp
  CALL  WriteString
  MOV	EAX, decAvg
  CALL	WriteInt
  MOV	EDX, OFFSET decimal
  CALL  WriteString
  MOV	EAX, decAvgTens
  NEG	EAX
  CALL  WriteDec
  MOV	EAX, decAvgHunds
  NEG	EAX
  CALL	WriteDec
  CALL  CrLf
  CALL  CrLF

; Parting message
_Goodbye:
  MOV	EDX, OFFSET goodbye
  CALL  WriteString
  MOV	EDX, OFFSET userName
  CALL  WriteString
  CALL  CrLF

	Invoke ExitProcess,0	; exit to operating system
main ENDP

END main
