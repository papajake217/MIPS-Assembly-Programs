########### Jake Papaspiridakos ############
########### jpapaspirida ################
########### 113325146 ################

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
.globl substr
substr:
li $t0, 0	#load 0 into t0 to check if either bound is negative
blt $a1,$t0,invalidBound
blt $a2,$t0,invalidBound
j pastCheck

invalidBound:
li $v0,-1
jr $ra

pastCheck:

move $t4, $a0
move $t5, $a0

li $t0,0

writeStringLoop:
blt $t0,$a1,boundCheck
bge $t0,$a2,stringLoopDone

lbu $t3, 0($t4)
sb $t3, 0($a0)
addi $a0,$a0, 1


boundCheck:

addi $t0,$t0,1
addi $t4,$t4,1
j writeStringLoop


stringLoopDone:
sb $zero, 0($a0)

li $v0, 0

 jr $ra




.globl encrypt_block
encrypt_block:
addi $sp,$sp,-32
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $t4, 16($sp)
sw $t5, 20($sp)
sw $t6, 24($sp)
sw $t7, 28($sp)



li $t0,0
li $t6, 0
li $t5,4


blockLoop:
beqz $t5,blockEndLoop
lbu $t1, 0($a0)
lbu $t2, 0($a1)
xor $t0,$t1,$t2
sll $t6, $t6, 8
or $t6,$t6,$t0

addi $a0,$a0,1
addi $a1,$a1,1
addi $t5,$t5,-1
j blockLoop

blockEndLoop:

move $v0, $t6


lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $t7, 28($sp)
addi $sp,$sp,32

 jr $ra

.globl add_block
add_block:
addi $sp,$sp,-32
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $t4, 16($sp)
sw $t5, 20($sp)
sw $t6, 24($sp)
sw $t7, 28($sp)



sll $t0,$a2,24
srl $t0,$t0,24

sll $t1,$a2,16
srl $t1,$t1,24

sll $t2,$a2,8
srl $t2,$t2,24


li $t6, 4
multu $t6,$a1
mflo $t4
srl $t3,$a2,24

add $a0,$a0,$t4
sb $t0, 0($a0)
sb $t1, 1($a0)
sb $t2, 2($a0)
sb $t3, 3($a0)


lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $t7, 28($sp)
addi $sp,$sp,32

 jr $ra

.globl gen_key
gen_key:
addi $sp,$sp,-32
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $t4, 16($sp)
sw $t5, 20($sp)
sw $t6, 24($sp)
sw $t7, 28($sp)


li $t2, 4
multu $t2,$a1
mflo $t2
add $a0,$a0,$t2

move $t0, $a0
move $t1, $a1

li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
sb $a0, 0($t0)
addi $t0,$t0,1

li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
sb $a0, 0($t0)
addi $t0,$t0,1

li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
sb $a0, 0($t0)
addi $t0,$t0,1

li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
sb $a0, 0($t0)
addi $t0,$t0,1


lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $t7, 28($sp)
addi $sp,$sp,32


 jr $ra

.globl encrypt
encrypt:

move $t7, $a0
move $t6, $a1
move $t5, $a2
move $t4, $a3

li $t0, 4
divu $a3,$t0
mfhi $t0
li $t1, 0
beq $t0,$t1,afterPadding
li $t1, 1
beq $t0,$t1, remainderOne
li $t1,2
beq $t0,$t1, remainderTwo
li $t1,3
beq $t0,$t1,remainderThree

remainderThree:
add $a0,$a0,$a3
move $t0, $a0
li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
addi $t0,$t0,1
sb $a0, 0($t0)
addi $t0,$t0,1
sb $zero,0($t0)
addi $a3,$a3,1
j afterPadding

remainderTwo:
add $a0,$a0,$a3
move $t0, $a0
li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
addi $t0,$t0,1
sb $a0, 0($t0)
addi $t0,$t0,1

li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
sb $a0, 0($t0)
addi $t0,$t0,1
sb $zero,0($t0)
addi $a3,$a3,2

j afterPadding

remainderOne:
add $a0,$a0,$a3
move $t0, $a0
li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
addi $t0,$t0,1
sb $a0, 0($t0)
addi $t0,$t0,1

li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
sb $a0, 0($t0)
addi $t0,$t0,1

li $a1, 93
li $v0, 42
syscall
addi $a0,$a0,33
sb $a0, 0($t0)
addi $t0,$t0,1

sb $zero,0($t0)
addi $a3,$a3,3
j afterPadding

afterPadding:

li $t0,4
div $a3,$t0
mflo $t0
li $t1,0		#t1 = bindex


encryptLoop:
beq $t1,$t0,continueEncrypt

move $a0,$t6			#key -> $a0
move $a1, $t1			# bindex -> $a1

move $t4, $ra		


jal gen_key


move $a1,$t6			#key from gen_key -> a1
li $t2,4			#load 4 into t2
mult $t2,$t1			#bindex * 4
mflo $t2			#t2 = bindex * 4
add $a1,$t2,$a1			#key + (bindex*4)
move $a0,$t7			# move plaintext into a0


jal encrypt_block		#encrypt_block(plaintext,key + (bindex*4))


move $a0,$t5			#cipher -> a0
move $a1, $t1			# bindex -> a1
move $a2,$v0			# return value from encrypt block -> a2
jal add_block			# add_block(cipher,bindex,$v0)


move $ra,$t4			# restore ra
addi $t1, $t1, 1		# bindex++
addi $t7,$t7,4			# plaintext++


j encryptLoop

continueEncrypt:



 jr $ra

.globl decrypt_block
decrypt_block:
addi $sp,$sp,-40
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $t4, 16($sp)
sw $t5, 20($sp)
sw $t6, 24($sp)
sw $t7, 28($sp)
sw $t8, 32($sp)
sw $t9, 36($sp)

lb $t0, 0($a1)
lb $t1, 1($a1)
lb $t2, 2($a1)
lb $t3, 3($a1)

sb $t3, 0($a1)
sb $t2, 1($a1)
sb $t1, 2($a1)
sb $t0, 3($a1)

move $t4, $a1

move $t7, $ra

jal encrypt_block

move $a1,$t4

lb $t0, 0($a1)
lb $t1, 1($a1)
lb $t2, 2($a1)
lb $t3, 3($a1)

sb $t3, 0($a1)
sb $t2, 1($a1)
sb $t1, 2($a1)
sb $t0, 3($a1)


move $ra,$t7

lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $t7, 28($sp)
lw $t8, 32($sp)
lw $t9, 36($sp)
addi $sp,$sp,40


jr $ra

.globl decrypt
decrypt:
move $t0,$a0
move $t1,$a1
move $t2,$a2
move $t3,$a3
#t0 - t3 reserved



li $t4, 4
div $t2,$t4
mflo $t2
li $t4, 0	#t4 -> bindex

decryptLoop:
beq $t2, $t4, endDecrypt

#t0 -> cipherText	t1 -> key       t2 -> nchars     t3 -> plaintext


move $a1,$t1		# a1 = key



move $a0, $t0		# a0 = cipherText
move $t8, $ra		# preserve ra


jal decrypt_block	#decrypt_block(cipherText,key)

move $a2,$v0		# $v0(return value) -> $a2
move $a1,$t4		# $a1 -> bindex
move $a0,$t3		# $a0 -> plaintext

jal add_block		# addblock(plaintext,bindex, decryptedblock)


move $ra,$t8		#get ra back

addi $t4,$t4,1		#bindex++
addi $t0,$t0,4		#ciphertext += 4
addi $t1,$t1,4		#key += 4
j decryptLoop
endDecrypt:

 jr $ra