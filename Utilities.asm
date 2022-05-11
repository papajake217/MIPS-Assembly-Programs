################# Jake Papaspiridakos #################
################# jpapaspirida #################
################# 113325146 #################

################# DO NOT CHANGE THE DATA SECTION #################

.data
arg1_addr: .word 0
arg2_addr: .word 0
num_args: .word 0
invalid_arg_msg: .asciiz "One of the arguments is invalid\n"
args_err_msg: .asciiz "Program requires exactly two arguments\n"
invalid_hand_msg: .asciiz "Loot Hand Invalid\n"
newline: .asciiz "\n"
zero: .asciiz "Zero\n"
nan: .asciiz "NaN\n"
inf_pos: .asciiz "+Inf\n"
inf_neg: .asciiz "-Inf\n"
mantissa: .asciiz ""

.text
.globl hw_main
hw_main:
    sw $a0, num_args
    sw $a1, arg1_addr
    addi $t0, $a1, 2
    sw $t0, arg2_addr
    j start_coding_here

start_coding_here:
	li $t1, 2		#int t1 = 2
	lw $t2, num_args	#int t2 = num_args
	bne $t1,$t2, invalidNumArgsExit	   #if t1 != t2, throw exception
	
	li $t1, 0		#char t1 = null
	lw $t2, arg1_addr	#String t2 = arg1_addr
	lbu $t2, 1($t2)		#Char t2 = t2[1]
	bne $t1, $t2, invalidArgsExit	#if t1 != t2 throw exception
	
	
	lw $t3, arg1_addr       # String t1 =arg1_addr
	lbu $s6, 0($t3)		# char s6 = t1[0]
	
D:
	li $t2, 'D'		# t2 = 'D'
	beq $s6,$t2,stringToDecimal  #if t1 == 'D' continue	
	
O:
	li $t2, 'O'
	beq $s6,$t2,decodeIType


S:
	li $t2,'S'
	beq $s6,$t2,decodeIType

T:
	li $t2, 'T'
	beq $s6,$t2,decodeIType


I:
	li $t2,'I'
	beq $s6,$t2,decodeIType

F:
	li $t2,'F'
	beq $s6,$t2,decodeIType


L:
	li $t2,'L'
	beq $s6,$t2,lootCard

	
	j invalidArgsExit
	
	
	
	
stringToDecimal:
	li $t1, 0	#i = 0
	lw $s3, arg2_addr    #s3 = arg2_addr
	li $s0, 0		# Total sum to keep track
	li $s1, 10		# Multiplier for conversion
	li $s5, 0		# 0 if positive, 1 if negative. Boolean flag
	validateLoop:
		lbu  $t4, 0($s3)	#load string[i]
		beqz $t4,continueExecution  #if end of string, continue
		li $t7, '-'			#t7 = '-'
		#if negative detected, branch and jump back to continue loop and set s5 to 1
		
		beq $t4, $t7, negativeCondition   #if char is '-', continue loop by skipping past digit check
		li $t7, '0'			# t7 = '0'
		blt $t4,$t7,invalidArgsExit   #if less than '0', exception
		li $t7, '9'			# t7 = '9'
		bgt $t4,$t7,invalidArgsExit   #if greater than '9', exception
		mult $s0,$s1			# mult s0 and t5, basically s0 * 10
		mflo $s0			# load hi into s0	
				
		addi $t7,$t4, -48 		#subtract '0' from char to get int
		addu $s0, $s0, $t7		# add int to sum
		j continueLoop
		
		negativeCondition:
			li,$s5, 1
			
		continueLoop:
			
			addi $s3,$s3,1
			j validateLoop
	
	
		continueExecution:
			li $t2, 1		# t2 = 1
			bne $s5,$t2,negativeCheckpoint #check if boolean flag is false (meaning num is positive)
			li $t2, -1	#load -1 to multiply the number by
			mult $s0, $t2	#multiply -1 by result
			mflo $s0	#Store it back in s0
		
			
			
		negativeCheckpoint:	#past the negative check
		
			li $v0, 1		
			move $a0, $s0
			syscall
			j endProgram
		

decodeIType:			#Note, t2 is reserved for now to hold the command of the user
	lw $s3, arg2_addr	#load arg2 into s3
	li $t1, 'F'
	beq $t1, $s6, pastFCheck
	li $t1, '0'		#load '0' to check for 0x
	li $t3, 'x'		#load 'x' to check for 0x
	li $t7, 8
	lbu  $t4, 0($s3)
	bne $t4,$t1,invalidArgsExit
	addi $s3, $s3, 1
	lbu $t4, 0($s3)
	bne $t4,$t3,invalidArgsExit
	addi $s3, $s3, 1
	pastFCheck:
	li $t7, 8
	li $s7, 0	#load 0 into s7, s7 will hold the bits
	li $s0, 0		#s0 = 0, will keep track of how many characters is in the string
	hexValidateLoop:
		lbu  $t4, 0($s3)	#load next character into t4
		beqz $t4,hexLoopEnd	#End loop if null character
		bgt $s0, $t7, invalidArgsExit	# Throw exception if s0 > 8 which means string has more than 8 digits
		li $t1 '0'			#load '0'
		blt $t4, $t1, invalidArgsExit	#check if less than '0' and throw exception
		li $t1, '9'			#load '9'
		bgt $t4,$t1, hexContinueAlpha	# If greater than 9, check if it A-F
		addiu, $t4, $t4, -48	# convert character digit to int
		sll $s7, $s7, 4
		or $s7,$s7,$t4
		
		j hexContinueLoop	# go to end of loop
		
	
	
	hexContinueAlpha:
		li $t1, 'A'
		blt $t4, $t1,invalidArgsExit
		li $t1, 'F'
		bgt $t4, $t1,invalidArgsExit
		addiu, $t5, $t4, -55
		sll $s7, $s7, 4
		or $s7,$s7,$t5
		
		j hexContinueLoop
		
	
	
	
	hexContinueLoop:
		addi $s3,$s3,1
		addi $s0, $s0, 1
		j hexValidateLoop
	
	
	
	hexLoopEnd:
		li $t1, 'O'
		beq,$s6,$t1,opcode
		li $t1, 'S'
		beq $s6,$t1,sourceRegister
		li $t1, 'T'
		beq $s6,$t1,destinationRegister
		li $t1, 'I'
		beq $s6, $t1, immediate
		li $t1, 'F'
		beq $s6,$t1, floatingPoint
		
		
	opcode:
		srl $s7,$s7,26
		li $v0, 1
		move $a0, $s7
		syscall
		j endProgram	
		
	sourceRegister:
		sll $s7,$s7,6
		srl $s7, $s7,27
		li $v0, 1
		move $a0, $s7
		syscall
		j endProgram
		
	destinationRegister:
		sll $s7,$s7,11
		srl $s7,$s7, 27
		li $v0, 1
		move $a0, $s7
		syscall
		j endProgram
	
	immediate:
		sll $s7, $s7, 16
		sra $s7, $s7, 16
		
		li $v0, 1
		move $a0, $s7
		syscall
		j endProgram
			
floatingPoint:
	li $t1, 8
	bne $s0,$t1, invalidArgsExit
	beqz $s7, zeroExit
	li $t1, 0x00000000
	beq $s7, $t1, zeroExit
	li $t1, 0x80000000
	beq $s7, $t1, zeroExit
	li $t1, 0xFF800000
	beq $s7, $t1, infNegExit
	li $t1, 0x7F800000
	beq $s7, $t1, infPosExit
	li $t1, 0x7F800001
	bge $s7, $t1, nanBounds
	j pastNan
	nanBounds:
		li $t1, 0x7FFFFFFF
		ble $s7,$t1, nanExit
		j pastNan
	
	
	
	pastNan:
		li $t1, 0xFF800001
		bge $s7, $t1, secondBoundsCheck
		j pastChecks
		secondBoundsCheck:
			li $t1, 0xFFFFFFFF
			ble $s7, $t1, nanExit
			j pastChecks
	
		
	pastChecks:
		move $t0, $s7		#t0 will hold sign
		srl $t0, $t0, 31	
		move $t1, $s7		#t1 will hold exponent
		sll $t1, $t1, 1
		srl $t1, $t1, 24
		move $t2, $s7		#t2 will hold mantissa
		sll $t2, $t2, 9
		srl $t2, $t2, 9

		li $t4, 127
		neg $t4,$t4
		add $t1,$t1,$t4
		move $a0, $t1
		
		li $s0, 1		#i = 1
		la $s4, mantissa	#preserve original mantissa address
		la $s5, mantissa	# s5  = mantissa address as iterated through
		li $t1, 23		#t1 stores num of bits in mantissa
		beqz $t0, putOne	# if sign is positive, just start loop
		li $t0, '-'
		sb $t0, 0($s5)
		addi $s5, $s5, 1
		putOne:
			li $t0, '1'
			sb $t0, 0($s5)
			addi $s5,$s5, 1
			li $t0, '.'
			sb $t0, 0($s5)
			addi $s5,$s5,1
		binaryLoop:
			li $t5, 24
			beq $t5,$s0,binaryLoopDone
			
			
			li $t5, 23
			neg $t6, $s0
			add $t5, $t5, $t6
			
			move $t7,$t2
			srlv $t7,$t7,$t5
			andi $t7, $t7, 1
			
			beqz $t7,appendZero
			j appendOne
			appendZero:
			li $t7, '0'
			sb $t7, 0($s5)
			j contBinaryLoop
			
			appendOne:
			li $t7, '1'
			sb $t7, 0($s5)
			j contBinaryLoop
			
			contBinaryLoop:
			
			addi $s5,$s5, 1
			addi $s0,$s0, 1
			j binaryLoop
			
			
			
			
		binaryLoopDone:
			li $t7, 0
			sb $t7, 0($s5)
			move $a1,$s4
			
		
		
		j endProgram

		
				
zeroExit:
	li $v0, 4
	la $a0, zero
	syscall
	j endProgram
	
infNegExit:
	li $v0, 4
	la $a0,inf_neg
	syscall
	j endProgram
							
infPosExit:
	li $v0, 4
	la $a0, inf_pos
	syscall
	j endProgram
										
nanExit:
	li $v0, 4
	la $a0, nan
	syscall
	j endProgram

		


lootCard:
	lw $s3, arg2_addr
	li $s0, 0	#let s0 = number of merchants
	li $s1, 0	#let s1 = number of pirates
	li $s2, 0	# s2 keeps track of if next char must be a digit or M/P
			# 0 - M/P	1 - digit
	li $s4, 0	# s4 keeps track of if pirate or merchant is associated with strength
			# 0 - M		1 - Pirate
cardLoop:
	lbu  $t4, 0($s3)		#load char[i]
	beqz $t4,loopCardEnd		#if char is null, end
	li $t1, 'M'
	beq $t4, $t1, merchant		#if char is M
	li $t1, 'P'
	beq $t4, $t1, pirate		#if char is P
	li $t1, '0'
	blt $t4, $t1, invalidHandExit
	li $t1, '9'
	bgt $t4, $t1, invalidHandExit
	j strength
	
merchant:		#merchant condition
	addi $s0, $s0, 1		#add 1 to merchant counter
	bnez $s2, invalidHandExit	#if s2 != 0, meaning its not right to put M/P, throw exception
	addi $s2,$s2, 1			# add 1 to s2 so program knows its time for digit
	addi $s3, $s3, 1		# iterate to next character
	li $s4, 0			# Set s4 to 0 to indicate merchant num
	j cardLoop			# jump back to top
	
pirate:
	addi $s1, $s1, 1		#same as above except add 1 to s1
	bnez $s2, invalidHandExit	 
	addi $s2,$s2, 1		
	addi $s3,$s3, 1
	li $s4, 1			
	j cardLoop	

	
strength:
	beqz $s4, merchantCheck
	#piratecheck
	li $t2, '1'
	blt $t4,$t2,invalidHandExit
	li $t2, '4'
	bgt $t4, $t2, invalidHandExit
	j continueStrength
	merchantCheck:
		li $t2, '3'
		blt $t4,$t2, invalidHandExit
		li $t2, '8'
		bgt $t4,$t2, invalidHandExit
		
	continueStrength:	
	li $t1, 1
	bne $s2, $t1, invalidHandExit	#if s2 != 1, its not time for a digit
	addi $s2, $s2, -1		# s2 -= 1 so program knows its time for M/P
	addi $s3, $s3, 1
	
	j cardLoop			# strength doesnt really matter so loop back up		
			
					
loopCardEnd:
	bnez $s2,invalidHandExit	# String should end with a strength, so s2 should be 0
	add $t7, $s0, $s1
	li $t1, 6
	bne $t1, $t7, invalidHandExit
	sll $s0,$s0, 3
	or $s0, $s0, $s1
	li $v0, 1
	move $a0, $s0
	syscall
	j endProgram
	
	
	
invalidNumArgsExit:
	li $v0, 4
	la $a0, args_err_msg
	syscall
	j endProgram

invalidArgsExit:
	li $v0, 4
	la $a0, invalid_arg_msg
	syscall
	j endProgram

invalidHandExit:
	li $v0, 4
	la $a0, invalid_hand_msg
	syscall
	j endProgram

endProgram:
	li $v0, 10
	syscall