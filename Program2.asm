TITLE Project 5 - Arrays, Addressing, and Stack-Passed Parmeters     (Proj5_turneste.asm)

; Author: Steven turner
; Last Modified: 2/28/2021
; OSU email address: turneste@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number: 5                Due Date: 2/28/2021
; Description: Generates an array of random nubers based on arraysize and bondries given by constants. Displays array,
;			   sorts array, calculates and displays median, dispalys sorted array, and finally calculates occurances
;			   of each number in array and displays.

INCLUDE Irvine32.inc

ARRAYSIZE = 200
LO = 10
HI = 29

.data

  intro1			BYTE	"Steven Turner			Project 5 - Arrays, Addressing, and Stack-Passed Parmeters",13,10,10,0
  intro2			BYTE	"Program generates a list of random numbers, displays the median and sorted list, ",13,10,"and displays a list of the number of occurances of each number.", 13, 10, 10,0

  randArray				DWORD	ARRAYSIZE DUP(?)
  unsortedTitle		BYTE	"Unsorted Array",13,10,10,0

  medianTitle		BYTE	"Median",13,10,10,0

  sortedTitle		BYTE	"Sorted Array",13,10,10,0

  counts			DWORD	ARRAYSIZE DUP(?)
  countTitle		BYTE	"Number Counts",13,10,10,0

.code
main PROC

; Introduce program

  PUSH	OFFSET intro1
  PUSH	OFFSET intro2

  CALL	introduction

; Fill array with random integers

  PUSH	OFFSET randArray
  PUSH	LO ; 
  PUSH	HI ;
  PUSH	ARRAYSIZE ;8

  CALL	fillArray

; Display list of integers

  PUSH	OFFSET unsortedTitle
  PUSH	OFFSET randArray
  PUSH	ARRAYSIZE

  CALL	displayList

; Sort smallest to largest

  PUSH	OFFSET randArray
  PUSH	ARRAYSIZE

  CALL	sortList

; Calculate and display median

  PUSH	OFFSET medianTitle
  PUSH	OFFSET randArray
  PUSH	ARRAYSIZE

  CALL	displayMedian

; Dispaly sorted List

  PUSH	OFFSET sortedTitle
  PUSH	OFFSET randArray
  PUSH	ARRAYSIZE

  CALL	displayList

; create an array called counts which counts how many times each number occurs in list

  PUSH	OFFSET randArray
  PUSH	ARRAYSIZE
  PUSH	OFFSET counts
  PUSH	LO
  PUSH	HI

  CALL	countList

; Display count array

  PUSH	OFFSET countTitle
  PUSH	OFFSET counts
  PUSH	ARRAYSIZE

  CALL	displayList

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;------------------------------------------------------------------
;Name: introduction
;Description: Displays programmer and title, explains program to user
;Preconditions: None
;Postconditions: None
;Receives: intro1, intro2
;Returns: None
;------------------------------------------------------------------

introduction PROC

  PUSH	EBP
  MOV	EBP, ESP
  PUSH	EDX

  MOV	EDX, [EBP + 12] ; Display programmer and title
  CALL	WriteString

  MOV	EDX, [EBP + 8] ; Explain program
  CALL	WriteString

  POP	EDX
  POP	EBP
  RET	8

introduction ENDP

;------------------------------------------------------------------
;Name: fillArray
;Description: Fills randArray with random integers based on given array size and boundries
;Preconditions: None
;Postconditions: None
;Receives: LO, HI, ARRAYSIZE
;Returns: randArray
;------------------------------------------------------------------

fillArray PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	EAX
  PUSH	ECX
  PUSH	EDI

  CALL	Randomize

  MOV	ECX, [EBP + 8]  ; Set counter to arraySize
  MOV	EDI, [EBP + 20]  ; Set destination pointer to randArray
  _fillLoop:
	  MOV	EAX, [EBP + 12]
	  INC	EAX
	  CALL	RandomRange  ; Range with upper limit at HI
  
	  CMP	EAX, [EBP + 16]
	  JL	_fillLoop  ; Check if number is lower than LO

	  MOV	[EDI], EAX
	  ADD	EDI, 4
  LOOP	_fillLoop

  POP	EDI
  POP	ECX
  POP	EAX
  POP	EBP

  RET	16

fillArray ENDP

;------------------------------------------------------------------
;Name: sortList
;Description: Sorts randArray from smallest to largest
;Preconditions: randArray has been filled by fillArray
;Postconditions: None
;Receives: LO, HI, ARRAYSIZE
;Returns: randArray
;------------------------------------------------------------------

sortList PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	ESI

  MOV	ESI, [EBP + 12]  ; Set source pointer ro randArray
  MOV	EDI, ESI
  ADD	EDI, 4	; Set destination pointer to next value
  MOV	ECX, [EBP + 8]  ; Set loop to ARRAYSIZE	

  _sortOuterLoop: ; Check every location in array once
	  PUSH	ECX
	  PUSH	ESI
	  PUSH	EDI
		_sortInnerLoop: ; Move largest unsorted number to the end of the list
			  MOV	EAX, [ESI]
			  CMP	EAX, [EDI]
			  JLE	_lessThan

			  PUSH	ESI
			  PUSH	EDI
			  CALL	exchangeElements

			_lessThan:
			  ADD	ESI, 4
			  ADD	EDI, 4
		LOOP	_sortInnerLoop

	  POP	EDI
	  POP	ESI
	  POP	ECX
  LOOP	_sortOuterLoop

  POP	ESI
  POP	ECX
  POP	EBX
  POP	EAX

  POP	EBP
  RET	8	
sortList ENDP

;------------------------------------------------------------------
;Name: exchangeElements
;Description: Exchanges contiguous elements to sort list
;Preconditions: [ESI] is greater than [EDI] 
;Postconditions: None
;Receives: ESI, EDI
;Returns: ESI, EDI
;------------------------------------------------------------------

exchangeElements PROC
	  PUSH	EBP
	  MOV	EBP, ESP
	  PUSH	EAX
	  PUSH	EDI
	  PUSH	ESI
	  	  
	  MOV	EDI, [EBP + 8]
	  MOV	ESI, [EBP + 12]

	  MOV	EAX, [ESI] ; Store current
	  XCHG	[EDI], EAX ; Exchange next and current storage
	  MOV	[ESI], EAX ; Set current to next

	  POP	ESI
	  POP	EDI
	  POP	EAX
	  POP	EBP
	  RET	8
exchangeElements ENDP

;------------------------------------------------------------------
;Name: displayMedian
;Description: Calculates and display median of randArray
;Preconditions: randArray is in sorted order
;Postconditions: None
;Receives: medianTitle, randArray, ARRAYSIZE
;Returns: Displays median
;------------------------------------------------------------------

displayMedian PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
  PUSH	ESI

  MOV	EDX, [EBP + 16] ; Display title
  CALL	WriteString

  MOV	ESI, [EBP + 12] ; Set source pointer to beginning of randArray
  MOV	EAX, [EBP + 8]
  MOV	EDX, 0
  MOV	EBX, 2
  DIV	EBX
  CMP	EDX, 0  ; Check whether given ARRAYSIZE is even
  MOV	ECX, EAX
  JE	_evenArray

  _oddLoop: ; Find middle value for odd array
		ADD		ESI, 4
  LOOP	_oddLoop

  MOV		EAX, [ESI]
  CALL	WriteDec
  CALL	CrLf

  JMP	_finish

  _evenArray: ; Find lower median for even array
		DEC	ECX
		_evenLoop:
			ADD		ESI, 4
  LOOP	_evenLoop

  MOV	EAX, [ESI] ; Calculate average of high and low median
  ADD	ESI, 4
  MOV	EBX, [ESI]
  ADD	EAX, EBX
  MOV	EBX, 2
  MOV	EDX, 0
  DIV	EBX

  CMP	EDX, 0
  JE	_noRound
  INC	EAX  ; Round up

_noRound:  ; Display median
  CALL	WriteDec
  CALL	CrLf
  CALL	CrLf

_finish:
  POP	ESI
  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX

  POP	EBP
  RET	12
displayMedian ENDP

;------------------------------------------------------------------
;Name: displayList
;Description: displays a list based on given ARRAYSIZE, 20 numbers per line
;Preconditions: None
;Postconditions: None
;Receives: sortedTitle/unsortedTitle/medianTitle, randArray/counts, ARRAYSIZE
;Returns: Displays list
;------------------------------------------------------------------

displayList PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH  EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
  PUSH	ESI

  MOV	EDX, [EBP + 16]  ;Dispaly title
  CALL	WriteString

  MOV	ECX, [EBP + 8]  ; Loop count to ARRAYSIZE
  MOV	ESI, [EBP + 12]  ; someArray location
  MOV	EDX, 1  ; Count for carriage returns
_showElement:
	  MOV	EBX, 0
	  CMP	EBX, [ESI]
	  JE	_countArrayStop ; Do not display 0 values in count array

	  MOV	EAX, [ESI]
	  CALL	WriteDec
	  MOV	AL, " "
	  CALL	WriteChar
	  ADD	ESI, 4

	  PUSH	EAX
	  PUSH	EDX

	  MOV	EAX, EDX  ; Check if carriage return is needed at 20 nums
	  MOV	EBX, 20
	  MOV	EDX, 0
	  DIV	EBX
	  CMP	EDX, 0
	  JNE	_noCarriage
	  CALL	CrLf

	_noCarriage:
	  POP	EDX
	  POP	EAX
	  INC	EDX
	_countArrayStop:
  LOOP	_showElement

  CALL	CrLF

  POP	ESI
  POP   EDX
  POP	EBX
  POP	ECX
  POP	EAX
  POP	EBP

  RET	12

displayList ENDP

;------------------------------------------------------------------
;Name: countList
;Description: Counts the number of occurances for each number in array
;Preconditions: randArray is in sorted order
;Postconditions: None
;Receives: randArray, ARRAYSIZE, LO, HI 
;Returns: counts
;------------------------------------------------------------------

countList PROC
  PUSH	EBP
  MOV	EBP, ESP
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
  PUSH	ESI
  PUSH	EDI

  MOV	ESI, [EBP + 24] ; Set source pointer to randArray
  MOV	EDI, [EBP + 16] ; Set destination pointer to counts
  MOV	EAX, 0
  MOV	EBX, [EBP + 12] ; LO
  MOV	EDX, [EBP + 8] ;HI
  MOV	ECX, [EBP + 20] ;ARRAYSIZE
	_arrayLoop: ; Check every number in array
		  _countLoop:  ; Count occurances of each number
			  CMP	EBX, [ESI]
			  JNE	_nextNum
			  INC	EAX
			  ADD	ESI, 4
			  LOOP	_countLoop
		  _nextNum:
		  MOV	[EDI], EAX
		  ADD	EDI, 4

		  CMP	[ESI], EDX
		  JA	_complete
		  INC	EBX
		  MOV	EAX, 0
	  JMP	_arrayLoop
_complete:

  POP	EDI
  POP	ESI
  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX
  POP	EBP
  RET	20
countList ENDP

END main
