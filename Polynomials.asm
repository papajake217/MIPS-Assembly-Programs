############## Jake Papaspiridakos ##############
############## 113325146 #################
############## jpapaspirida ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_term
create_term:
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

#Save args in s registers
move $s0,$a0
move $s1,$a1	




#struct Term {
   #int coeff		// coefficient of a term (4 bytes)
   #int exp			// exponent of a term (4 bytes)
   #Term* next_term 	// Pointer to the next term in the polynomial //(4 bytes)
#}


# If the coefficient is 0 or the exponent is negative, then return -1 in $v0.

beqz $s0,createError
bltz $s1,createError



#Allocate 12 bytes on the heap
li $a0, 12
li $v0, 9
syscall 


#now address of allocated memory is in $v0

#coeff is in s0, exp is in s1

sw $s0,0($v0)	#store coeff in first 4 bytes
sw $s1,4($v0)	#store exp in next 4 bytes
sw $zero,8($v0)	#store zero in pointer to next term

j finishCreate


createError:

li $v0,-1
j finishCreate

finishCreate:

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28
  jr $ra

.globl create_polynomial
create_polynomial:
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

move $s0,$a0  #terms in s0
move $s6,$ra  #ra in s6


jal fixDuplicates	#check for duplicates and fix them
#Now that the array is cleared of duplicates, construct the linked list

lw $a0,0($s0)	#load base into a0
lw $a1,4($s0)	#load exp into a1
jal create_term	
bltz $v0,emptyArray	#if return was less than 0 (-1), array is empty
move $s1,$v0	#head stored in s1
move $s2,$s1	#previous = head
#s0 is address of array
li $s5,1		#s5 = 1 (head is one node), s5 will count num of nodes in the polynomial
createPolyLoop:
addi $s0,$s0,8		#iterate array to next node

lw $a0,0($s0)		#load base into a0
lw $a1,4($s0)		#load exp into a1
jal create_term		#create new node, currentNode = new Node(base,exp)
bltz $v0,polyDone	#if return is less than 0 (-1), finish. If currentNode == null, done
addi $s5,$s5,1
sw $v0,8($s2)		#store return address as link of previous node. previousNode.next = currentNode;

move $s2,$v0		#previous = currentNode

j createPolyLoop	#continue Loop


polyDone:	#end of loop reached
sw $zero,8($s2)

li $a0, 8	
li $v0, 9
syscall		#allocate 8 bytes on heap

sw $s1,0($v0)	#store head in first 4 bytes of v0
sw $s5,4($v0)	#store number of nodes in next 4 bytes

j finishPoly


emptyArray:
li $v0,0		#load null into return value
j finishPoly		#finish function



finishPoly:

move $ra,$s6	#restore ra

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28
  jr $ra

fixDuplicates:
#takes in terms[] in a0
#checks for any repeat exponents in terms[] and then fixes it
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

#a0 holds base addr of terms
move $s6,$ra

#nested loop to check for duplicate nodes

#load first exponent into t0

move $s4,$a0
outerLoop:	
lw $s0,4($s4)		#load exponent into s0
lw $t0,0($s4)		#load base into t0 (temporary since only quick check needed so dont care after)
beqz,$t0,finishFix	#if base == 0, then end of array reached	

move $s1,$s4		#move current node's address into s1 so you can iterate starting from there 
innerLoop:
#s1 holds address of nodes being searched
addi $s1,$s1,8	#go to next node

lw $t1,0($s1)	#load base into t1
lw $t2,4($s1)	#load exp into t2

beqz $t1,innerLoopDone	#if base == 0, then terms array is done so finish inner loop

beq $t2,$s0,duplicateFound	#if t2 == exp in outer loop, branch
#duplicate not found so continue loop
j innerLoop

duplicateFound:
#S4 is original node's address (node that was searching for a duplicate of itself)
lw $t0,0($s4)  #load base of og node into t0
add $t0,$t0,$t1		#add duplicate node's base to og nodes base
sw $t0,0($s4)		#store it back into og node's base

move $a0,$s1	#move addr into args
jal shiftDuplicate	#shift everything to the left starting at this duplicate node.
addi $s1,$s1,-8
j innerLoop

innerLoopDone:
addi $s4,$s4,8		#iterate terms address by 8 bytes
j outerLoop

finishFix:

move $ra,$s6

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28
jr $ra


#shifts whole array left starting at address in a0, stop when (0,-1) is hit
shiftDuplicate: 

addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

#a0 holds address

shiftLoop:
lw $t0,4($a0)		#load base into t0
bltz $t0,shiftDone	#check if exp == 0 and if so shift is done (end of array reached)

lw $t1,8($a0)		#load next base into t1
lw $t2,12($a0)		#load next exponent into t2
sw $t1,0($a0)		#store next base into current base
sw $t2,4($a0) 		#store next exponent into current exponent

addi $a0,$a0,8		#iterate to next element

j shiftLoop

shiftDone:

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28
jr $ra




.globl sort_polynomial
sort_polynomial:
addi $sp,$sp,-32
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)
sw $s7,28($sp)

move $s6,$a0	#save polynomial into s6 for later maybe

lw $s5,4($a0)	#store number of terms in s5

move $s4,$ra

li $s0,1
beq $s5,$s0,sortDone	#if one element, its already sorted


li $s0,0	#i=0

lw $s2, 0($a0)		#head = s2
move $s3,$s2		#s3 = head
outerSortLoop:	

beq $s0,$s5,sortDone		#if i==terms, sort done



li $s1,1	#j = 1    run one less loop here since j and j+1 considered


move $s3,$s2	#move head into s3


innerSortLoop:
beq $s1,$s5,innerSortDone	#j < num terms


lw $t0,4($s3)			#load exponent into t0
lw $t1,8($s3)			#load nextnode into t1
lw $t1,4($t1)			#load nextNodes exponent into t1

blt $t1,$t0,noSwap		#if nextNode < node, then correct order so no swap

#else continue and swap

move $a0,$s3		#move node to a0
lw $a1,8($s3)		#move node.next into a1
jal swap


noSwap:

lw $s3,8($s3)	#node = node.next
addi $s1,$s1,1	#j++
j innerSortLoop

innerSortDone:
addi $s0,$s0,1	#i++

j outerSortLoop

sortDone:
#restore ra
move $ra,$s4
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
lw $s7,28($sp)
addi $sp,$sp,32
    jr $ra




swap:	#swap two nodes in a linked list (their values) 
# a0 takes in reference to node1 
# a1 is node2
addi $sp,$sp,-32
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)
sw $s7,28($sp)


lw $t0,0($a0)	#load base of node1 into t0
lw $t1,4($a0)   #load exp of node1 into t1

lw $t2,0($a1)	#load base of node2 into t2
lw $t3,4($a1)	#load exp of node2 into t3

sw $t2,0($a0)	#store base of node2 into node1
sw $t3,4($a0)	#store exp of node2 into node1

sw $t0,0($a1)	#same thing but into node2
sw $t1,4($a1)

#swap done

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
lw $s7,28($sp)
addi $sp,$sp,32
jr $ra


.globl add_polynomial
add_polynomial:
addi $sp,$sp,-32
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)
sw $s7,28($sp)

move $s7,$ra	#preserve ra

#a0 holds polynomial 1, a1 holds polynomial 2


beqz $a0,polyErrorCheck1	#check if either a0 or a1 is null
beqz $a1,polyErrorCheck2

#First Allocate memory, (8 bytes * (poly1.numTerms + poly2.numTerms))

lw $t0,4($a0)	#t0 = poly1.numTerms
lw $t1,4($a1)	#t1 = poly2.numTerms

move $s0,$a0		#preserve original args
move $s1,$a1


add $t0,$t0,$t1	   #t0 += t1

li $t1,8

mult $t1,$t0	   #(8 bytes * (poly1.numTerms + poly2.numTerms))

mflo $t0	   #t0 = product
addi $t0,$t0,8   #8 more bytes for the last term
move $a0,$t0	  #move num bytes needed into a0
li $v0, 9	
syscall 	#allocate heap space

#v0 now holds address of allocated space

move $s2,$v0	#s2 holds base address of terms

lw $t0,4($s0)	#t0 = poly1.numTerms
lw $t1,4($s1)	#t1 = poly2.numTerms

lw $s0,0($s0)
lw $s1,0($s1)


move $t2,$s2	#t2 = address
li $t3,0	#t3 = 0
poly1AddLoop:
beq $t3,$t0,poly1Done	#if t3 = num of terms, finish

lw $t4,0($s0)		#load base into t4
lw $t5,4($s0)		#load exp into t5

sw $t4,0($t2)		#store base into terms[]	
sw $t5,4($t2)		#store exp into terms[]

lw $s0,8($s0)		# node = node.next
addi $t2,$t2,8		#iterate address by 8
addi $t3,$t3,1		#t3++
j poly1AddLoop

poly1Done:


li $t3,0		#t3 = 0

poly2AddLoop:		#repeat same thing for poly2, but use s1 (poly2).

beq $t3,$t1,poly2Done

lw $t4,0($s1)
lw $t5,4($s1)

sw $t4,0($t2)			
sw $t5,4($t2)		


lw $s1,8($s1)
addi $t2,$t2,8
addi $t3,$t3,1
j poly2AddLoop

poly2Done:
#ok now terms[] is constructed, need last element though (0,-1)

sw $zero,0($t2)
li $t4, -1
sw $t4,4($t2)

#terms[] finished, now need to call create_polynomial

move $a0,$s2	#move base address of terms into a0
jal create_polynomial

#v0 holds polynomial, but must sort it too

move $a0,$v0
move $s0,$v0	#preserve polynomial

jal sort_polynomial

move $v0,$s0	#return value is polynomial
j finishAddPoly

polyErrorCheck1:	#if poly1 is null
beqz $a1,bothNullCase	#if poly2 is also null, both are null
move $v0,$a1		#move poly1 into return value
j finishAddPoly

polyErrorCheck2:	#if poly2 is null, poly1 is not null since this case doesnt occur if it is
move $v0,$a0		#move poly1 into return value
j finishAddPoly

bothNullCase:		#both are null
#must return empty polynomial where head == null and terms ==0

#allocate 8 bytes (one polynomial on heap)
li $a0,8
li $v0,9
syscall

sw $zero,0($v0)		#head = null
sw $zero,4($v0)		#numTerms = 0
j finishAddPoly

finishAddPoly:

move $ra,$s7 	#restore ra
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
lw $s7,28($sp)
addi $sp,$sp,32
  jr $ra

.globl mult_polynomial
mult_polynomial:
addi $sp,$sp,-36
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)
sw $s7,28($sp)
sw $ra,32($sp)


beqz $a0,EmptyPolynomial
beqz $a1,EmptyPolynomial


move $s0,$a0		#preserve args
move $s1,$a1

jal sort_polynomial	#sort first


move $a0,$a1

jal sort_polynomial


move $a0,$s0
move $a1,$s1


#a0,a1 holds polys

lw $t0,4($a0)	#t0 = poly1.numterms
lw $t1,4($a1)	#t1 = poly2.numterms

mult $t0,$t1	# multiply num terms to get resulting number of terms
mflo $t0	#t0 = product

li $t1,8
mult $t0,$t1	#multiply total number of terms needed by 8 bytes 
mflo $t0	# move into t0
addi $t0,$t0,8	#add 8 more bytes for null term		

move $a0,$t0	#move into a0 for heap memory allocation
li $v0,9
syscall

#v0 has allocated memory, it will be the array of terms

move $s2,$v0	#save it in s2


######################################

#s0 = poly1*
#s1 = poly2*
#s2 = terms[] base address


######################################

lw $s0,0($s0)	#get head of list of both polys
lw $s1,0($s1)

move $t7,$s2	#move working address of terms[] into t7

outerMultLoop:

beqz $s0,multLoopDone	#if NULL done

lw $t0,0($s0)	#t0 = pNode.base
lw $t1,4($s0)	#t1 = pNode.exp



lw $s0,8($s0)	#pNode = pNode.next
move $t5,$s1
innerMultLoop:


beqz $t5,outerMultLoop	#if null, end reached

lw $t2,0($t5)	#t2 = qNode.base
lw $t3,4($t5)	#t3 = qNode.exp



mult $t2,$t0	# pNode.base * qNode.base
mflo $t2	# t2 = product 

add $t3,$t3,$t1	 # t3 = pNode.exp + qNode.exp

sw $t2,0($t7)	#store new base
sw $t3,4($t7)	#store new exponent

addi $t7,$t7,8	#iterate terms[] by 8 (for next base/exponent)


lw $t5,8($t5)	#qNode = qNode.next
j innerMultLoop

multLoopDone:		#now terms[] holds result of multiplying the polynomials

sw $zero,0($t7)
li $t0, -1
sw $t0,4($t7)		#store (0,-1) at end of terms[]


move $a0,$s2

jal create_polynomial
beqz $v0,EmptyPolynomial

move $a0,$v0
move $s0,$v0

jal sort_polynomial

move $v0,$s0

j finishMultiplyPoly


EmptyPolynomial:
#make empty polynomial

li $a0,8
li $v0,9
syscall

sw $zero,0($v0)
sw $zero,4($v0)



finishMultiplyPoly:
#take care of exceptions

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
lw $s7,28($sp)
lw $ra,32($sp)
addi $sp,$sp,32
  jr $ra