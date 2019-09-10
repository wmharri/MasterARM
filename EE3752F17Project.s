		area project, code, readonly
pinsel0		equ 0xe002c000
u0start		equ 0xe000c000
lcr0		equ 0xc
lsr0		equ 0x14
ramstart	equ 0x40000000
stackstart	equ 0x40000200
	
	; register list: r0 used to handle output strings
	;				 r1 stores input parameter for Transmit subroutine
	;				 r2 stores number of digits
	;
	;				 r4 stores return value of Receive subroutine
	;				 r5 is used to get number of turns
	;				 r6 is used to store the memory address for array of # digits correct
	;				 r7 is used to generate a random number seed
	

			entry
			bl UARTConfig
;			ldr r8,=654321
;			bl intDiv				Testing a failed attempt at implementing integer division
;			add r8, r8, #0x30
;			mov r1, r8
;			mov r8, r11
;			bl Transmit
;			bl intDiv
;			add r8, r8, #0x30
;			mov r1, r8
;			mov r8, r11
;			bl Transmit
;			bl intDiv
;			add r8, r8, #0x30
;			mov r1, r8
;			mov r8, r11
;			bl Transmit
;			bl intDiv
;			add r8, r8, #0x30
;			mov r1, r8
;			mov r8, r11
;			bl Transmit
;			bl intDiv
;			add r11, r11, #0x30
;			add r8, r8, #0x30
;			mov r1, r11
;			bl Transmit
;			mov r1, r8
;			bl Transmit			
			
;testloop	b testloop		;####
restart		mov r2, #0					; start of game
			mov r3, #10
			ldr r0, =msg_promptSize
			bl print_msg
			mov r7, #0
input		bl Receive
			mov r1, r4
;			add r2, r2, r1
;			sub r2, r2, #0x30
			bl Transmit
			cmp r1, #13		; search for Enter key
			beq checklow
			cmp r1, #0x30 ; character smaller than '0'
			movlo r1, #'\n'
			bllo Transmit
			ldrlo r0, =msg_error
			bllo print_msg
			blo restart
			cmp r1, #0x39	; character larger than '9'
			movhi r1, #'\n'
			blhi Transmit
			ldrhi r0, =msg_error
			blhi print_msg
			bhi restart
			mul r2, r3, r2	; if numeric
			add r2, r2, r1
			sub r2, r2, #0x30
			b input
checklow	cmp r2, #4		; checks size not too small
			bhs checkhigh
			ldrlo r0, =msg_error
			bllo print_msg
			b restart
checkhigh	cmp r2, #15		; checks size not too large
			bls skipcheck
			ldrhi r0, =msg_error
			blhi print_msg
			b restart
skipcheck	mov r1, #'\n'
			bl Transmit
		
		; put a print loop here
;			bl Transmit
;			add r2, r2, #0x30
;			mov r1, r2
;			bl Transmit
;			mov r1, r7
;			bl Transmit

			ldr r5, =turns_table	; gets address for # turns
			mov r3, r2
			sub r3, r3, #4
			add r3, r3, r3, LSL #1
			add r5, r3
			
diffloop	ldr r0, =msg_diff	; gets difficulty, and # turns
			bl print_msg
			bl Receive
			mov r1, r4
			bl Transmit
			mov r1, #'\n'
			bl Transmit
			cmp r4, #69
			beq numRounds
			cmp r4, #101
			beq numRounds
			cmp r4, #77
			addeq r5, r5, #1
			beq numRounds
			cmp r4, #109
			addeq r5, r5, #1
			beq numRounds
			cmp r4, #72
			addeq r5, r5, #2
			beq numRounds
			cmp r4, #104
			addeq r5, r5, #2
			beq numRounds
			ldr r0, =msg_error
			bl print_msg
			b diffloop
			
numRounds	ldrb r5, [r5]
;			mov r1, r5
;			bl Transmit


			bl rng
			ldr r6,=testSoln
			mov r3, r2
soln		bl rng
			mov r8, r7, lsr #28
			cmp r8, #9
;			movls r1, #'Y'
;			movhi r1, #'N'
			bhi soln
			cmp r8, #0
			blt soln
			strb r8, [r6], #1
			mov r1, r8
			bl Transmit
			sub r3, r3, #1
			cmp r3, #0
			bgt soln

			mov r3, #0
digitGet	ldr r6, =testSoln
			ldrb r8, [r6, r3]
			;mov r1, r8					; ####
			;bl Transmit
			sub r8, #0x30
			ldr r9, =digitsAns
			ldrb r10, [r9, r8]
			add r10, r10, #1
			strb r10, [r9, r8]
			add r3, r3, #1
			cmp r3, r2
			bne digitGet
			

;			ldr r6,=digits
;			ldr r8,=testSoln

round		ldr r6,=digits
			ldr r8,=testSoln
			ldr r0,=msg_input		;game begins
			bl print_msg
			mov r3, #0
			mov r11, #0
			ldr r10,=digits
cleanup		strb r11, [r10, r3]	; restores digit counts to zero
			add r3, r3, #1
			cmp r3, #10
			bne cleanup
			mov r3, #0			; r3 used here to keep track of number of digits
			mov r12, #0
inputloop	bl Receive
			mov r1, r4
			bl Transmit
			cmp r4, #13
			bne notCgRn		; not Carriage Return
			cmp r3, r2
			beq afterInput
			ldr r0,=msg_error
			bl print_msg
			b round
;			beq afterInput
notCgRn		cmp r4, #0x30
			movlo r1, #'\n'
			bllo Transmit
			ldrlo r0,=msg_error
			bllo print_msg
			blo round
			cmp r4, #0x39
			movhi r1, #'\n'
			blhi Transmit
			ldrhi r0,=msg_error
			blhi print_msg
			blhi round
			sub r10, r4, #0x30
			ldrb r11, [r6, r10]
			add r11, r11, #1
			strb r11, [r6, r10]
			ldrb r9, [r8], #1
			; some error-checking, and then
			cmp r4, r9
			addeq r12, r12, #1
			add r3, r3, #1
;			cmp r3, r2
			b inputloop		; inputloop ends here
afterInput	cmp r12, r2
			beq winning
;			ldr r0,=msg_win		; ####
;			bl print_msg
			ldr r8,=digitsAns
			ldr r9,=digits
			mov r0, #0
			mov r6, #0
numCorrect	ldrb r10, [r8, r6]
			ldrb r11, [r9, r6]
			cmp r10, r11
			addls r0, r0, r10
			addhi r0, r0, r11
			add r6, r6, #1
			cmp r6, #10
			bne numCorrect
;			ldr r0, =msg_win	; ####
;			bl print_msg
			mov r6, r0		; freeing up r0 for output
			sub r6, r6, r12
			add r6, r6, #0x30
			add r12, r12, #0x30
			mov r1, #'\n'
			bl Transmit
			ldr r0,=msg_promptStart
			bl print_msg
			mov r1, r12
			bl Transmit
			cmp r6, #1
			moveq r8, #6
			movne r8, #7
			ldr r0,=msg_promptVary
prntdig1	ldrb r1, [r0]
			add r0, r0, #1
			bl Transmit
			sub r8, r8, #1
			cmp r8, #0
			bne prntdig1
			ldr r0,=msg_promptMiddle
			bl print_msg
			mov r1, r6
			bl Transmit
			cmp r12, #1
			moveq r8, #6
			movne r8, #7
			ldr r0,=msg_promptVary
prntdig2	ldrb r1, [r0]
			add r0, r0, #1
			bl Transmit
			sub r8, r8, #1
			cmp r8, #0
			bne prntdig2
			ldr r0,=msg_promptEnd
			bl print_msg
			sub r5, r5, #1
			cmp r5, #0
			; if win, skip to winning
			bne round
			mov r1, #'\n'
			bl Transmit
			ldr r0,=msg_lose
			bl print_msg
			b end
			;print losing condition
			; skip to end
winning		mov r1, #'\n'
			bl Transmit
			ldr r0,=msg_win ; print winning condition
			bl print_msg
end			bl Transmit
playAgain	ldr r0,=msg_replay
			bl print_msg
			bl Receive
			mov r1, r4
			bl Transmit
			mov r1, #'\n'
			bl Transmit
			cmp r4, #78
			beq loop
			cmp r4, #110
			beq loop
			cmp r4, #89
			beq restart
			cmp r4, #121
			beq restart
			ldr r0,=msg_error
			bl print_msg
			b playAgain

loop		b loop			

UARTConfig
			push {r5, r6, LR}
			ldr r5, =pinsel0
			bic r6, r6, #0xf
			orr r6, r6, #0x5
			str r6, [r5]
			ldr r5, =u0start
			mov r6, #0x83
			strb r6, [r5, #lcr0]
			mov r6, #3
			strb r6, [r5, #lcr0]
			pop {r5, r6, PC}
			
rng
			push {r1, LR}
			add r7, r7, r7, lsl #2
			add r7, r7, r7, lsl #4		; multiply by 0x01010101
			ldr r1, =0x31415927			; linear congruential generator, using values from cc65 (source: Wikipedia)
			add r7, r7, r1
			pop {r1, PC}
			
;intDiv			; binary division-with-remainder by 10
;			push {r9, r10, LR}
;			ldr r10, =1000000
;			cmp r8, r10
;			movhs r9, #-1
;			bhs endDiv
;			mov r9, #10			; r8 is the dividend, r9 the divisor
;			mov r10, #21		; one more step than # of bits
;			mov r11, #0			; r11 is the quotient
;divLoop		sub r8, r8, r9
;			cmp r8, #0
;			addlt r8, r8, r9
;			addge r11, r11, #1
;			lsr r9, r9, #1
;			lsl r11, r11, #1
;			sub r10, r10, #1
;			cmp r10, #0
;			bne divLoop
;endDiv		pop {r9, r10, PC}

print_msg
			push {r1, LR}
printloop	ldrb r1, [r0], #1
			cmp r1, #0
			beq print_exit
			bl Transmit
			b printloop
print_exit	;mov r1, #13 ; readying carriage return for print
			;bl Transmit
			pop {r1, PC}

; Blum Blum Shub: x[n+1] = x[n] * x[n] Mod M
; M = p * q, p, q prime
; possible values: p = 257, q = 263; p = 65519, q = 65521
; BUT -- I want a ten-digit value, not a 16 digit number

Receive
		push {r5, r6, lr}
		ldr r5, =u0start
wt		ldrb r6, [r5, #lsr0]
		add r7, r7, #1;
		tst r6, #0x01		; buffer full?
		beq wt
		ldrb r4, [r5]
		pop {r5, r6, pc}

Transmit
		push {r5, r6, lr}
		ldr r5, = u0start
wait	ldrb r6, [r5, #lsr0]	; get status of buffer
		tst r6, #0x20		; buffer empty?
		beq wait		; spin until buffer is empty
		strb r1, [r5]
		pop {r5, r6, pc}

msg_promptSize		dcb "Please enter the size of the number (4-15 digits).\n", 0
msg_error			dcb "Value entered is not admissible.\n", 0
msg_diff			dcb "What difficulty would you like? [E]asy, [M]edium, or [H]ard? ", 0
msg_input			dcb "What is your guess? ", 0
msg_promptStart		dcb "You have ", 0
msg_promptMiddle	dcb " correct, and ", 0
msg_promptEnd		dcb " in the wrong place.\n", 0
msg_promptVary		dcb " digits"
msg_win				dcb "That's correct!\n", 0
msg_lose			dcb "You have run out of turns.\n", 0
msg_replay			dcb "Would you like to play again? [Y]es/[N]o ", 0

ALIGN
turns_table
			dcb 20, 15, 10
			dcb	25, 20, 15
			dcb 30, 25, 20
			dcb 35, 30, 25
			dcb 40, 35, 30
			dcb 45, 40, 35
			dcb 50, 45, 40
			dcb 55, 50, 45
			dcb 60, 55, 50
			dcb 65, 60, 55
			dcb 70, 65, 60
			dcb 75, 70, 65
;			dcb 80, 75, 70
			
;ALIGN
;testSoln
;			dcb "1212344389006811"
			
			area guess_store, data, READWRITE
;guess		dcb 0, 0, 0, 0, 0, 0, 0, 0
digits		dcb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
digitsAns	dcb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
testSoln	dcb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 


		END