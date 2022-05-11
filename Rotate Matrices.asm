######### Jake Papaspiridakos ##########
######### 113325146 ##########
######### jpapaspirida ##########

######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########

.text
.globl initialize
initialize:
 #Parameters:
 #la $a0, Filename
 #la $a1, Buffer
 
 addi $sp,$sp,-12
 sw $s0,0($sp)
 sw $s1,4($sp)
 sw $s2,8($sp)
 
 move $t0, $a1    #save buffer into t0
 
 move $t8,$a1
 
 li $a1, 0	#signifies read mode
 li $a2, 0	#ignored but should be 0
 li $v0, 13	#read file
 syscall
 bltz $v0,openFileError		#throw error if v0 is -1 meaning error opening
 move $t9,$v0
 li $t8,83
 # readFile(descriptor,buffer,maxCharactersToRead)
 move $a0,$v0			#move file descriptor to a1
 move $a1,$t0			#move buffer to a1
 li $a2, 1
 
 li $t5, 2	
 li $t4, 0
  readSpecs:
  beq $t4,$t5,readLoop
 li $v0, 14
 syscall
 beqz $v0,EOF
 bltz $v0,openFileError
 
 lb $t1, 0($a1)
 li $t2, '1'
 blt $t1,$t2,newLineCheckTwo
 li $t2, '9'
 bgt $t1,$t2,openFileError
 addi $t1,$t1,-48
 addi $t4,$t4,1
 sb $t1,0($a1)
 
 addi $a1,$a1,4
 j readSpecs
 
 newLineCheckTwo:
 li $t2,10			
 beq $t2,$t1,readSpecs		
 li $t2,13			
 bne $t1,$t2, openFileError	
 li $v0, 14			
 syscall
 blez $v0,EOF

 lb $t1,0($a1)
 li $t2,10
 bne $t2,$t1, openFileError
 j readLoop
 
 
 
 
 
 
 
 
 
 
 
 readLoop:
 beq $t8,$t4,EOFMax
 li $v0, 14
 syscall
 beqz $v0,EOF
 bltz $v0,openFileError
 
 lb $t1, 0($a1)
 li $t2, '0'
 blt $t1,$t2,newLineCheck
 li $t2, '9'
 bgt $t1,$t2,openFileError
 addi $t1,$t1,-48
 
 sb $t1,0($a1)
 
 addi $a1,$a1,4
 addi $t4,$t4,1
 j readLoop
 
 newLineCheck:
 li $t2,10
 beq $t2,$t1,readLoop
 li $t2,13
 bne $t1,$t2, openFileError
 li $v0, 14
 syscall
 blez $v0,EOF
 lb $t1,0($a1)
 li $t2,10
 bne $t2,$t1, openFileError
 j readLoop
 
 EOF:
 
 li $v0,16
 move $a0,$t9
 syscall
 sb $zero,0($a1)
 li $v0,1
 j return
 
 EOFMax:
 li $v0,16
 move $a0,$t9
 syscall
  li $v0,1
 j return
 #Errors Section:
 openFileError:
 bltz $t4,finishError
 li $t2, 0
 sb $t2,0($t0)
 addi $t0,$t0,4
 addi $t4,$t4,-1
 j openFileError
 finishError:
 
 li $v0,-1
 j return
 
 #marker to return 
 return:
 
 
 lw $s0,0($sp)
 lw $s1,4($sp)
 lw $s2,8($sp)
 addi $sp,$sp,12
 
jr $ra


.globl write_file
write_file:
addi $sp,$sp,-12
sw $s0,0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)

#a0 = filename    a1 = buffer

move $s2,$a1		#s2 = buffer

li $a1,1
li $a2,0
li $v0,13
syscall
bltz $v0,writeReturn
move $t9,$v0
#File is now opened and v0 contains descriptor
move $a0,$v0		#a0 = descriptor
move $a1,$s2
li $a2,1

lb $s0,0($s2)
addi $t0, $s0,'0'
sb $t0, 0($s2)
move $a0,$t9
move $a1,$s2
li $a2,1
li $v0, 15
syscall

li $t0,10
sb $t0, 0($s2)
move $a0,$t9
move $a1,$s2
li $a2,1
li $v0,15
syscall


addi $s2,$s2,4
lb $s1,0($s2)
addi $t0,$s1,'0'
sb $t0,0($s2)
move $a0,$t9
move $a1,$s2
li $a2,1
li $v0, 15
syscall

li $t0,10
sb $t0, 0($s2)
move $a0,$t9
move $a1,$s2
li $a2,1
li $v0,15
syscall

addi $s2,$s2,4

#s0 holds row num, s1 holds column num, s2 holds buffer

li $t0, 0	#i = 0

writeOuterLoop:
beq $t0,$s0,writeReturn
addi $t0,$t0,1
li $t1, 0	#j = 0
writeInnerLoop:
beq $t1,$s1,lineEnd
addi $t1,$t1,1

lb $t2,0($s2)
addi $t2,$t2,'0'
sb $t2,0($s2)

move $a0,$t9		
move $a1,$s2

li $a2,1
li $v0,15
syscall
addi $s2,$s2,4
j writeInnerLoop

lineEnd:
addi $s2,$s2,-4
li $t2, 10
sb $t2, 0($s2)
move $a0,$t9		
move $a1,$s2

li $a2,1
li $v0,15
syscall

addi $s2,$s2,4
j writeOuterLoop

writeReturn:
li $v0,16		#close file
move $a0,$t9
syscall

lw $s0,0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp,$sp,12
jr $ra



.globl rotate_clkws_90
rotate_clkws_90:
addi $sp,$sp,-12
sw $s0,0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)

lb $s0,0($a0)		#s0 holds rows
lb $s1,4($a0)		#s1 holds columns
move $s2,$a0		#s2 holds buffer address for function calls

sb $s0,4($a0)		#swap rows and columns in the buffer
sb $s1,0($a0)

move $t9,$a0
addi $a0,$a0,8		#t9 will now be the address of the matrix
			#a0 will be preserved as the base of the buffer address


li $t1,0 	#j = 0

rotateColumnLoop:
beq $t1,$s1,endRotate

li $t0,0
rotateRowLoop:
beq $t0,$s0,iterateColumn

mult $s1,$t0
mflo $t2
add $t2,$t2,$t1
li $t3,4
mult $t2,$t3
mflo $t2
add $t2,$t2,$a0
lb $t3,0($t2)
addi $sp,$sp,-4
sb $t3,0($sp)

addi $t0,$t0,1
j rotateRowLoop

iterateColumn:
addi $t1,$t1,1
j rotateColumnLoop

endRotate:

mult $s0,$s1
mflo $t0
li $t1,4
mult $t0,$t1
mflo $t1
add $a0,$a0,$t1

finishUpLoop:
addi $a0,$a0,-4
beqz $t0,returnRotate
lb $t1,0($sp)
addi $sp,$sp,4

sb $t1, 0($a0)

addi $t0,$t0,-1
j finishUpLoop
returnRotate:

move $s0,$t9
move $s1,$a1
move $s2,$ra
move $a0,$t9
#void mirror(Buffer* buffer, char* filename)
jal mirror

move $a0,$s1
move $a1,$s0



move $ra,$s2

lw $s0,0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp,$sp,12
jr $ra

.globl rotate_clkws_180
rotate_clkws_180:
addi $sp,$sp,-12
sw $s0,0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
#void rotate_clkws_180(Buffer* buffer, char* filename)
move $s0,$a0
move $s1,$a1
move $s2,$ra
#int initialize(char* filename, Buffer* buffer)
jal rotate_clkws_90

move $a0,$s1
move $a1,$s0
jal initialize

move $a0,$s0
move $a1,$s1

jal rotate_clkws_90

move $ra,$s2


lw $s0,0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp,$sp,12
 jr $ra

.globl rotate_clkws_270
rotate_clkws_270:
 addi $sp,$sp,-12
sw $s0,0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
#void rotate_clkws_180(Buffer* buffer, char* filename)
move $s0,$a0
move $s1,$a1
move $s2,$ra
#int initialize(char* filename, Buffer* buffer)
jal rotate_clkws_90

move $a0,$s1
move $a1,$s0
jal initialize

move $a0,$s0
move $a1,$s1

jal rotate_clkws_90

move $a0,$s1
move $a1,$s0
jal initialize

move $a0,$s0
move $a1,$s1

jal rotate_clkws_90

move $ra,$s2


lw $s0,0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp,$sp,12
 jr $ra


.globl mirror
mirror:
addi $sp,$sp,-12
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)

#a0 holds base address
#a1 holds file name

lb $s0,0($a0)	#s0 holds rows
lb $s1,4($a0)	#s1 holds columns

addi $a0,$a0,8

li $t0,0	#i = 0
mirrorRow:
beq $t0,$s0,mirrorEnd	#branch if i = rows
li $t1,0	#j = 0
move $t2,$a0
mult $t0,$s1
mflo $t3
li $t4,4
mult $t3,$t4
mflo $t4
add $t2,$t2,$t4
move $t5,$t2
addi $t0,$t0,1
mirrorColumn:		#push onto the stack in order with t2 as starting address of row
beq $t1,$s1,pushBack	#j < columns
lb $t7,0($t2)		#load byte at address of t2 (working address)
addi $sp,$sp,-4		#allocate room for next byte
sb $t7,0($sp)		#store byte on stacl

addi $t2,$t2,4		#iterate working address to next byte
addi $t1,$t1,1		#j++
j mirrorColumn

pushBack:
beqz $t1,mirrorRow	# j > 0

lb $t7,0($sp)		#pop from stack
sb $t7,0($t5)		#t5 holds copy of working address beginning
addi $t5,$t5,4		#iterate working address by 4
addi $t1,$t1,-1		#j--
addi $sp,$sp,4		#go back up the stack
j pushBack


mirrorEnd:
addi $a0,$a0,-8
move $t0,$a0
move $a0,$a1
move $a1,$t0

move $s0,$ra

jal write_file

move $ra,$s0



lw $s0,0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp,$sp,12
 jr $ra

.globl duplicate
duplicate:
addi $sp,$sp,-12
sw $s0,0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)

lb $s0,0($a0)	#s0 holds rows
lb $s1,4($a0)	#s0 holds columns

addi $a0,$a0,8	#iterate forward so a0 holds only matrix numbers
move $s2,$a0

li $t0,0	#i = 0
li $t7,0	#will hold the 
dupRowLoop:	
beq $t0,$s0,endConversion #i<rows
li $t1,0		#j = 0
li $t7,0	#will hold the number generated
dupInnerLoop:
beq $t1,$s1,insertNum

lb $t3,0($a0)

sll $t7,$t7,1
or $t7,$t7,$t3

addi $t1,$t1,1
addi $a0,$a0,4
j dupInnerLoop

insertNum:
li $t3,4
mult $t3,$t0

mflo $t3
add $t3,$t3,$s2

sb $t7,0($t3)

addi $t0,$t0,1
j dupRowLoop
endConversion:

li $t0,1

checkNumsOuter:
beq $t0,$s0,noDups
#addi $t0,$t0,1
li $t1,0
checkNumsInner:
beq $t1,$t0,nextLoop

li $t4,4
mult $t4,$t0
mflo $t4
add $t4,$t4,$s2
lb $t4,0($t4)		#array[i]

li $t5,4
mult $t5,$t1
mflo $t5
add $t5,$t5,$s2
lb $t5,0($t5)		#array[j]

beq $t5,$t4,dupFound

addi $t1,$t1,1
j checkNumsInner
nextLoop:
addi $t0,$t0,1
j checkNumsOuter

dupFound:

li $v0,1
addi $t0,$t0,1
move $v1,$t0
j dupfinish
noDups:
li $v0,-1
li $v1,0

dupfinish:
lw $s0,0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp,$sp,12
 jr $ra


