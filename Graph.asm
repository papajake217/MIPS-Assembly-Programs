############## Jake Papaspiridakos##############
############## 113325146 #################
############## jpapaspirida ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_person
create_person:	
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)
#Node* create_person(Network* ntwrk)
# a0 = network address
move $t0, $a0 	#copy of t0 in a0 for later maybe
lbu $t7,0($a0)	#store max number of nodes
addi $a0,$a0,8	#go to size of node
lbu $t1,0($a0)	#t1 holds size of node

addi $a0,$a0,8  #go to byte 16 which holds the current number of nodes
lbu $t2,0($a0)	#load the num of nodes
bgeu $t2,$t7,fullNetworkException	#branch if num of nodes is greater than or equal to max
addi $t3,$t2,1	#increment it by 1
sb $t3,0($a0)	#store it back into the struct
#t2 holds previous num of nodes
addi $a0,$a0,8		#go to nodes
mult $t2,$t1		# multiply num of nodes in network and size to get how much to add
mflo $t1		
add $a0,$a0,$t1		#increment to next available node
move $t7,$a0
lbu $t1,8($t0)
li $t0,0
storeZeroLoop:
beq $t0,$t1,zeroLoopDone
sb $zero,0($a0)

addi $a0,$a0,1
addi $t0,$t0,1
j storeZeroLoop
zeroLoopDone:

move $v0,$t7

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28
  jr $ra
  
fullNetworkException:
li $v0,-1
jr $ra


.globl add_person_property
add_person_property:
#int add_person_property(Network* ntwrk, Node* person, char* prop_name, char* prop_val)
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

move $s1,$a1
move $s2,$a2
move $s3,$a3

move $s0,$a0			#save a0 in s0
move $a0,$a2			#move prop name into a0 argument
move $s6,$ra			#save ra in s6
jal compareName			#compare the names
beqz $v0,addPersonError		#if prop name != "NAME" throw error
#move $ra,$s6			#load ra back from s1


lbu $t0,8($s0)		#t0 = size_of_node
move $s5,$t0
move $a0,$s3
move $a1,$t0
jal checkNameLength

beqz $v0,addPersonError

#Now go through and check that Person exists AND name is unique
move $a0,$s0			#a0 = network
move $a1,$s3			#a1 = prop_val (persons name)


jal get_person		#get_person(network,prop_val)
bnez $v0,addPersonError		#if v0 = 0, no person with that name exists -> name is unique
move $a0,$s0			#a0 = network
move $a1,$s1			#a1 = person node

jal personExists 	#personExists(network,node)
beqz $v0,addPersonError		#if 0 returned, person does not exist so throw error

#now I just gotta change the name



#s1 holds the person node reference and its already verified so use that
#s3 holds the name so copy that too

li $t5,0		#t5 = chars copied
copyNameLoop:
lbu $t0,0($s3)		#load char into t0
beqz $t0,AddPersonSuccess	#when null terminator is hit finish with success!
sb $t0,0($s1)		#store char in person node	



addi $s1,$s1,1		#iterate to next char
addi $s3,$s3,1		#go to next char in s3
addi $t5,$t5,1		#t5++
j copyNameLoop



addPersonError:
li $v0, 0
j finishAddPerson


AddPersonSuccess:
beq $s5,$t5,wordCleared
sb $zero,0($s1)

addi $s1,$s1,1
addi $t5,$t5,1
j AddPersonSuccess
wordCleared:

li $v0,1
lbu $t0,8($s0)
beq $t0,$t5,finishAddPerson		#if name.length == max length then skip adding null terminator
sb $zero,0($s1)
j finishAddPerson

finishAddPerson:
move $ra,$s6		#restore ra so no infinite loop
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28

  jr $ra

compareName:
#takes in string in $a0
# returns 1 in v0 if the string is "NAME" else return 0
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

move $t0,$a0
lbu $t1,0($t0)
li $t2, 'N'
bne $t1,$t2,notNameException

lbu $t1,1($t0)
li $t2, 'A'
bne $t1,$t2,notNameException

lbu $t1,2($t0)
li $t2, 'M'
bne $t1,$t2,notNameException


lbu $t1,3($t0)
li $t2, 'E'
bne $t1,$t2,notNameException

lbu $t1,4($t0)
bnez $t1,notNameException
#if the string was equal to "NAME\z" load 1 into v0 and return
li $v0,1
j finishNameCheck
notNameException:
li $v0,0
j finishNameCheck


finishNameCheck:

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28

jr $ra


compareNodeName:
#names to compare are in a0 and a1, size of node in a2
#returns 0 in v0 if they are not equal, 1 if they are
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)


li $t4,0
compareLoop:
beq $t4,$a2,equalDone
lbu $t0,0($a0)
lbu $t1,0($a1)
bne $t0,$t1,notEqual
beqz $t0,equalDone

addi $a0,$a0,1
addi $a1,$a1,1
addi $t4,$t4,1
j compareLoop


notEqual:
li $v0,0
j finishComparing

equalDone:
lbu $t0,0($a1)
bnez $t0,notEqual
li $v0, 1
j finishComparing

finishComparing:

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28

jr $ra


checkNameLength:
#name in a0, length in a1
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

li $t0,0
nameLengthLoop:
lbu $t1,0($a0)				#load char into t1
beqz $t1,nameLengthDone			#check if t1 is null terminator
addi $t0,$t0,1				#iterate length by 1
addi $a0,$a0,1
j nameLengthLoop
#check if t0 = a1
nameLengthDone:
ble $t0,$a1,verified
li $v0,0
j finishLengthCheck
verified:
li $v0,1


finishLengthCheck:

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28

jr $ra

personExists:
#a0 = network, a1 = person node
#return 0 in v0 if doesnt exist, 1 if they do
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

lbu $t0,8($a0)		#t0 = size of node
lbu $t1,16($a0)		#t1 = num of nodes
li $t2, 0		# t2 = 0, compare this to num of nodes to know when to stop
addi $a0,$a0,24
findPersonLoop:
beq $t2,$t1,personDoesNotExist		#if t2 = num of nodes, then no match found
beq $a0,$a1,personDoesExist		#if a0 = a1, the node exists in the network


add $a0,$a0,$t0				#iterate network by node size
addi $t2,$t2,1				# t2++
j findPersonLoop

personDoesExist:
li $v0,1
j personExistExit


personDoesNotExist:
li $v0,0
j personExistExit

personExistExit:


lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
addi $sp,$sp,28

jr $ra


.globl get_person
get_person:
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

move $s6,$ra
move $s0, $a0		#move network into s0
lbu $s1,16($a0)		# s1 = num of nodes
lbu $s3,8($a0)		# s3 = SIZE OF NODE
addi $s0,$s0,24		# move s0 to nodes section
li $s2,0		#s2 = 0
move $s4,$a1		# s4 = name

getPersonLoop:
beq $s2,$s1,noPersonFound		#if s2 = number of nodes end since no match found


move $a0,$s0			#move node address into a0
move $a1,$s4			#move name into a1
move $a2,$s3
jal compareNodeName		#compare names, if 0 then not equal, if not then they are equal
bnez $v0,personFound		#0 not returned so names are equal, now branch

add $s0,$s0,$s3			#increment by size of node
addi $s2,$s2,1			#increment s2 by 1 (comparing to how many nodes in network)
j getPersonLoop


noPersonFound:
li $v0, 0
j finishFind


personFound:
move $v0,$s0		#move address of node into v0
j finishFind

finishFind:
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

.globl add_relation
add_relation:
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

#remember to store ra in s6 so you dont get caught lackin
move $s6,$ra

#save all arguments in their raw form
move $s0,$a0
move $s1,$a1
move $s2,$a2


#----CHECKS-----#

#1. no person with name1 exists in the network
move $a0,$s0
move $a1,$s1
jal get_person
#if person 1 does not exist throw error
beqz $v0,addRelationError


#2. no person with name2 exists in the network
move $a0,$s0
move $a1,$s2
jal get_person
#if person 2 does not exist throw error
beqz $v0,addRelationError

#3. network at capacity (current edges == max edges)
lbu $t0,4($s0)		#load total/max edges into t0
lbu $t1,20($s0)		#load current number of edges into t1
#if current >= max, throw error
bge $t1,$t0,addRelationError


#4. relation between the two already exist
move $a0,$s0		#move network into a0
move $a1,$s1		#move name1 into a1
move $a2,$s2		#move name2 into a2
jal getRelation		#get address of relation if one exists already
bnez $v0,addRelationError	#if return value is not 0, then relation exists so error

#5. name1 == name2
#use old function to compare two strings
move $a0,$s1		#move name1 into a0
move $a1,$s2		#move name2 into a1
lbu $a2,8($s0)
jal compareNodeName	#compareNodeName(name1,name2) -> 1 if equal, 0 if not

bnez $v0,addRelationError	#if 0 is not returned, they are equal so throw error


#####ADD ACTUAL RELATION####

lbu $t0,12($s0)		#t0 = size of edge
lbu $t1,20($s0)		#t1 = num of edges


mult $t0,$t1		# size * num of edges
mflo $t0		#load into t0

addi $t1,$t1,1		# num of edges++
sb $t1,20($s0)		#store back into num of edges

move $a0,$s0		#move network into s0
move $a1,$s1		#move name1 into a1
jal get_person		#get person node address

move $s1,$v0		#move person1 address into s1

move $a0,$s0		#same as above except for person2
move $a1,$s2
jal get_person

move $s2,$v0

#now s1 and s2 hold references to the nodes to add the relation to
lbu $t0,12($s0)		#t0 = size of edge
lbu $t1,20($s0)		#t1 = num of edges

addi $t1,$t1,-1
mult $t0,$t1		# size * num of edges
mflo $t0		#load into t0


lbu $t2,0($s0)		#total nodes	
lbu $t3,8($s0)		#size of node

mult $t2,$t3
mflo $t2			#total * size

addi $s0,$s0,24		#go into edge section
add $s0,$s0,$t2
add $s0,$s0,$t0		#go to next empty edge

#now in next empty edge

sw $s1,0($s0)		#store node1 into first 4 bytes of the edge
sw $s2,4($s0)		#store node2 into the next 4
li $t0,0
sw $t0,8($s0)		#store relation int in the next 4, 0 by default

li $v0,1
j addRelationFinish


addRelationError:
li $v0,0
j addRelationFinish

addRelationFinish:
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

#return the address of the edge, 0 if there isnt any
getRelation:
#(network,string 1,string 2)
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

#remember to store ra in s6 so you dont get caught lackin
move $s6,$ra

move $s0,$a0
move $s1,$a1
move $s2,$a2


move $a0,$s0
move $a1,$s1
jal get_person
move $s1,$v0



move $a0,$s0
move $a1,$s2
jal get_person
move $s2,$v0

#now s1 holds pointer to first person and s2 holds pointer to second person

#edges address = $t0
#first node reference = 0($t0)
#second node reference = 4($t0)
#relation integer = 8($t0)


lbu $t0,12($s0)	#t0 = size of edges
lbu $t1,20($s0)	#t1 = number of edges
li $t2,0	#t2 = 0
move $a0,$s0

lbu $t2,0($s0)
lbu $t3,8($s0)

mult $t2,$t3
mflo $t2


addi $a0,$a0,24
add $a0,$a0,$t2
li $t2,0
edgeLoop:			#loop through edges
beq $t1,$t2,noEdgeFound		#if iterated up to number of edges, then stop and no edge found
lw $t3,0($a0)			#load node1 into t3
lw $t4,4($a0)			#load node2 into t4

beq $t3,$s1,caseFirstEqual		#if node1 == person1 then branch to first case
beq $t3,$s2,caseSecondEqual		#if node1 == person2 then branch to second case
j continueEdgeLoop			#else continue loop and iterate
caseFirstEqual:	
bne $t4,$s2,continueEdgeLoop		#if node2 != person2 then no match so continue loop
move $v0,$a0				#else move the edge address into v0 and end loop
j finishEdge

caseSecondEqual:
bne $t4,$s1,continueEdgeLoop		#same as above except check node1 instead
move $v0,$a0
j finishEdge

continueEdgeLoop:

addi $t2,$t2,1			#iterate edge on by 1
add $a0,$a0,$t0			#iterate address by size of edge
j edgeLoop


noEdgeFound:
li $v0,0			#load 0 since no edge found
j finishEdge			#finish

finishEdge:

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



.globl add_relation_property
add_relation_property:
#Network* ntwrk, char* name1, Node* name2, char* prop_name, int prop_val
# return 0 if failed, 1 if success
lw $t0,0($sp)
li $t1,1
beq $t0,$t1,continueAddRelationProperty		#if prop_val == 1 continue
li $v0,0				#else load 0 and jump back
jr $ra

continueAddRelationProperty:

addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)

#remember to store ra in s6 so you dont get caught lackin
move $s6,$ra

#Preserving Args#

move $s0,$a0
move $s1,$a1
move $s2,$a2
move $s3,$a3
	


###CHECKS#####
#1.A relation between a person with name1 and person2 with name2 exists in the network
move $a0,$s0			
move $a1,$s1
move $a2,$s2
jal getRelation			#getRelation(network,string name1, string name2)
beqz $v0,addRelationPropError	#if no relation exists, then throw error
move $s4,$v0		#hold edge reference in s4 for later use

#2. The argument prop_name == ?FRIEND? -> $s3 = "FRIEND"

lbu $t0,0($s3)
li $t1, 'F'
bne $t0,$t1,addRelationPropError

lbu $t0,1($s3)
li $t1, 'R'
bne $t0,$t1,addRelationPropError

lbu $t0,2($s3)
li $t1, 'I'
bne $t0,$t1,addRelationPropError

lbu $t0,3($s3)
li $t1, 'E'
bne $t0,$t1,addRelationPropError

lbu $t0,4($s3)
li $t1, 'N'
bne $t0,$t1,addRelationPropError

lbu $t0,5($s3)
li $t1, 'D'
bne $t0,$t1,addRelationPropError

lbu $t0,6($s3)
bne $t0,$zero,addRelationPropError

#now checks are done, so change relation int to 1


li $t0,0
#s4 still holds edge reference
sw $t0,8($s4)

li $v0,1
j finishAddRelationProp


addRelationPropError:
li $v0,0
j finishAddRelationProp



finishAddRelationProp:

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

.globl is_a_distant_friend
is_a_distant_friend:
addi $sp,$sp,-28
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)
  #Network* ntwrk, char* name1, char* name2)
  move $s6,$ra
  #preserve args
  
  move $s0,$a0
  move $s1,$a1
  move $s2,$a2
  
  
    # First check if relation exists to eliminate cases
  jal getRelation
  bnez $v0,notDistantFriendError	#if v0 != 0 then an edge exists between them
  
  # Now check if either exists in the network
  #use get_person

  move $a0,$s0		#a0 = network
  move $a1,$s1		#a1 = person1
  jal get_person	# returns 0 if no person exists
  beqz $v0,dneError	# branch to dneError if person1 doesnt exist
  
  move $s3,$v0		#save reference into s3
  
  move $a0,$s0		#same as above but with person2
  move $a1,$s2		
  jal get_person
  beqz $v0,dneError
  
  li $v0,1
  j distantFriendFinish
  
  
  
  notDistantFriendError:
  li $v0,0
  j distantFriendFinish
  
  dneError:
  li $v0,-1
  j distantFriendFinish
  
  distantFriendFinish:
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