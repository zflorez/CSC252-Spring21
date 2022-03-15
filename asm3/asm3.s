# Author: 	Zachary Florez
# Course: 	CSC 252
# Program: 	asm3.s
# Description: 	This program executes five different functions, strlen, 
#		gcf, bottles, longestSorted, and rotate. All functions
#		are not tied together and do their own things. More
#		descriptions below for each function. 

.data
NEWLINE: 		.asciiz "\n"
SPACE: 			.asciiz " "
EXCLAMATION: 		.asciiz "!\n"
PERIOD:			.asciiz ".\n"

bottlesFirst:		.asciiz " bottles of "
bottlesSecond: 		.asciiz " on the wall, "
bottlesThird: 		.asciiz "Take one down, pass it around, "
bottlesFourth:		.asciiz " on the wall"
bottlesLast: 		.asciiz "No more bottles of "
b:			.asciiz "b is equal to: "

.text
.globl 	strlen
.globl	gcf
.globl	bottles
.globl	longestSorted
.globl	rotate

	# This function strlen takes in a single parameter that is a 
	# pointer to a string. It then loops through the entire string
	# and counts the number of characters there are in said string. 
	# After all that is implemented then it then returns the count
	# of how many chars are in the string parameter. 
	strlen:
	addiu	$sp, $sp, -24		# create stack space
	sw 	$ra, 4($sp) 		# save frame pointer
	sw 	$fp, 0($sp)		# save return address
	addiu 	$fp, $sp, 20		# change frame pointer
	
	addi 	$v0, $zero, 0 		# v0 = count
	add 	$t1, $zero, $a0		# t1 = string
	
	str_loop:
	lb 	$t0, 0($t1) 		# t0 = str[i]
	beq	$t0, $zero, str_done 	# if (str[i] = null)
	addi 	$t1, $t1, 1		# add 1 to pointer of str
	addi 	$v0, $v0, 1		# count ++ 
	
	j str_loop			# jump back to loop
		
	str_done:
	lw 	$fp, 0($sp)		# load old return address
	lw 	$ra, 4($sp)		# load old frame pointer
	addiu 	$sp, $sp, 24		# change stack pointer
	jr 	$ra			# return 
	
	
	
	
	
	# This next function gcf takes in two different integer parameters
	# a and b and then calculates the Greatest Common Factor between
	# a and b. This function is also RECURSIVE. 
	gcf:
	addiu	$sp, $sp, -24		# create stack space
	sw 	$ra, 4($sp) 		# save frame pointer
	sw 	$fp, 0($sp)		# save return address
	addiu 	$fp, $sp, 20		# change frame pointer
	
	# Store values for arguments
	add 	$t0, $zero, $a0		# t0 = int a
	add 	$t1, $zero, $a1		# t1 = int b
	
	first_if:
	slt 	$t2, $t0, $t1		# t2 = (a < b)
	beq 	$t2, $zero, second_if	# if (a >= b) try second if
	
	add 	$t2, $zero, $t0 		# t2 = a
	add 	$t0, $zero, $t1		# a = b
	add 	$t1, $zero, $t2		# b = a
	
	second_if:
	addi 	$t2, $zero, 1		# t2 = 1
	bne 	$t1, $t2, third_if 	# if (b != 1) try third ii 
	
	addi	$v0, $zero, 1		# retVal = 1
	j 	epilogue			# return 1
	
	third_if:
	
	div 	$t0, $t1			# hi/lo a/b
	mfhi	$t2 			# t2 = a % b 
	bne 	$t2, $zero, gcf_else	# if (a % b != 0) do else 
	
	add	$v0, $zero, $t1		# retVal = b
	j 	epilogue			# return b 
	
	gcf_else:
	div 	$t0, $t1			# hi/lo a/b
	mfhi	$t2			# t0 = a % b 
	
	add 	$a0, $zero, $t1		# a = b
	add 	$a1, $zero, $t2 		# b = a % b 
	jal 	gcf
	
	epilogue:
	lw 	$fp, 0($sp)		# load old return address
	lw 	$ra, 4($sp)		# load old frame pointer
	addiu 	$sp, $sp, 24		# change stack pointer
	jr	$ra
	
	
	
	
	
	# This next function bottles takes in two parameters, first is a 
	# integer count and the next parameter is a character thing. 
	# What this function does is stimulates the bottles on the wall song
	# until there are no more (thing) bottles to pass around to one another. 
	# NO return value for this function. 
	bottles:
	addiu	$sp, $sp, -24		# create stack space
	sw 	$ra, 4($sp) 		# save frame pointer
	sw 	$fp, 0($sp)		# save return address
	addiu 	$fp, $sp, 20		# change frame pointer
	
	add 	$t4, $zero, $a0 		# t4 = count
	add 	$t5, $zero, $a1		# t5 = drink 
	add 	$t0, $zero, $a0 		# i = count 
	
	bottlesLoop:
	slt 	$t1, $zero, $t0 		# 0 < i
	addi 	$t2, $zero, 1		# t2 = 1 
	bne 	$t1, $t2, bottlesAfter	# if ( i < 0 ) exit for loop
	
	addi 	$v0, $zero, 1		# print_int
	add 	$a0, $zero, $t0	 	# print_int(i)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, bottlesFirst 	# print_str(bottlesFirst)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	add 	$a0, $zero, $t5		# print_str(drink)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, bottlesSecond 	# print_str(bottlesSecond)
	syscall
	
	addi 	$v0, $zero, 1		# print_int
	add 	$a0, $zero, $t0	 	# print_int(i)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, bottlesFirst 	# print_str(bottlesFirst)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	add 	$a0, $zero, $t5		# print_str(drink)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, EXCLAMATION 	# print_str("!\n")
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, bottlesThird 	# print_str(bottlesThird)
	syscall
	
	sub 	$t0, $t0, $t2 		# i --
	
	addi 	$v0, $zero, 1		# print_int
	add 	$a0, $zero, $t0	 	# print_int(i)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, bottlesFirst 	# print_str(bottlesFirst)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	add 	$a0, $zero, $t5		# print_str(drink)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, bottlesFourth 	# print_str(bottlesFouth)
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, PERIOD	 	# print_str(".\n")
	syscall
	
	addi 	$v0, $zero, 4		# print_str
	la 	$a0, NEWLINE	 	# print_str("\n")
	syscall
	
	beq 	$t0, $zero, bottlesAfter # if i = 0, exit loop
	j bottlesLoop
	
	bottlesAfter: 
	addi 	$v0, $zero, 4 		# print_str()
	la 	$a0, bottlesLast		# print_str(No more..)
	syscall 
	
	addi 	$v0, $zero, 4		# print_str()
	add 	$a0, $zero, $t5 		# print_str(drink)
	syscall
	
	addi 	$v0, $zero, 4 		# print_str()
	la 	$a0, bottlesFourth	# print_str(" on the wall")
	syscall
	
	addi 	$v0, $zero, 4 		# print_str()
	la 	$a0, EXCLAMATION		# print_str("!\n")
	syscall
	
	addi 	$v0, $zero, 4 		# print_str()
	la 	$a0, NEWLINE		# print_str("\n")
	syscall
	
	
	lw 	$fp, 0($sp)		# load old return address
	lw 	$ra, 4($sp)		# load old frame pointer
	addiu 	$sp, $sp, 24		# change stack pointer
	jr	$ra			# END BOTTLES
	
	
	
	
	
	# This next function longestSorted takes in two different parameters, 
	# first is a integer array which is a pointer to an array and the 
	# next parameter is a integer length of the array. In this function 
	# we scan through the array and search for the longest sequence of
	# integers that are sorted in ascending order. We finally return that 
	# value. 
	longestSorted:
	addiu	$sp, $sp, -24		# create stack space
	sw 	$ra, 4($sp) 		# save frame pointer
	sw 	$fp, 0($sp)		# save return address
	addiu 	$fp, $sp, 20		# change frame pointer
	
	# Save sX registers here.
	addiu 	$sp, $sp, -32			
	sw 	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw 	$s2, 8($sp)
	sw 	$s3, 12($sp)
	sw 	$s4, 16($sp)
	sw 	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	
	add 	$t0, $zero, $a0
	add 	$s0, $zero, $a0		# s0 = int[] array
	add	$s1, $a1, $zero 		# s1 = array.length()
	
	firstCheck:
	bne  	$s1, $zero, secondCheck	# if (length != 0) jump to first
	add 	$v0, $zero, $zero	# retval = 0
	j 	LSepilogue
	
	secondCheck: 
	addi	$t2, $zero, 1		# t2 = 1
	bne 	$s1, $t2, algorithm	# if (length != 1) go to algorithm
	addi	$v0, $zero, 1		# retval = 1
	j 	LSepilogue
	
	algorithm:
	addi 	$s2, $zero, 1	 	# s2 = count = 1
	addi 	$s3, $zero, 1		# s3 = longest = 1
	
	add 	$s4, $zero, $zero 	# s4 = i = 0
	
	forLoop:

	addi 	$t1, $s1, -1		# t1 = length - 1
	slt 	$t0, $s4, $t1		# t0 = (i < length - 1)
	beq 	$t0, $zero, retLongest	# if (false) return longest
	
	addi 	$t0, $s4, 1		# t0 = i + 1
	addi 	$t2, $zero, 4 		# t2 = 4
	
	mult 	$t0, $t2 		# (i + 1) * 4
	mflo	$t0 			# t0 = (i - 1) * 4
	
	mult 	$s4, $t2			# (i) * 4
	mflo 	$t1 			# t1 = (i) * 4
	
	add 	$t0, $s0, $t0 		# t0 = &a[i+1]
	add 	$t1, $s0, $t1 		# t1 = &a[i]
	
	lw	$t2, 0($t0)		# t2 = array[i + 1]
	lw 	$t3, 0($t1) 		# t3 = array[i]
	
	slt 	$t4, $t2, $t3 		# t4 = (a[i + 1]) < a[i])
	addi 	$t5, $zero, 1		# t5 = 1
	beq 	$t4, $t5, continueLoop	# if (true) 
	
	addi 	$s2, $s2, 1		# count ++
	
	slt 	$t4, $s3, $s2 		# t4 = (max < count)
	beq 	$t4, $zero, doElse 	# if (false)
	add	$s3, $s2, $zero 		# longest = count
	
	j 	continueLoop
	
	doElse: 
	addi 	$s2, $zero, 1		# count = 1
	
	continueLoop:
	addi	$s4, $s4, 1		# i ++
	j 	forLoop	
	
	retLongest:
	add 	$v0, $zero, $s3 
	j 	LSepilogue
	
	
	LSepilogue:
	
	# Load s0, s1, s2, s3 registers back.
	lw	$s7, 28($sp)
	lw 	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw 	$s3, 12($sp)
	lw 	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addiu 	$sp, $sp, 32
	
	lw 	$fp, 0($sp)		# load old return address
	lw 	$ra, 4($sp)		# load old frame pointer
	addiu 	$sp, $sp, 24		# change stack pointer
	jr	$ra
	
	
	# The last function that we are implementing is a rotate function. 
	# This function takes in 7 different parameters and then calls 
	# a function util() that is given inside the testcases. And then
	# returns a integer value that is given from that util() 
	# function. 
	rotate:
	addiu	$sp, $sp, -28		# create stack space
	sw 	$ra, 4($sp) 		# save frame pointer
	sw 	$fp, 0($sp)		# save return address
	addiu 	$fp, $sp, 24		# change frame pointer
	
	lw 	$t4, 16($sp)		# t4 = d
	lw 	$t5, 20($sp)		# t5 = e
	lw 	$t6, 24($sp)		# t6 = f
	
	# Save sX registers here.
	addiu 	$sp, $sp, -32			
	sw 	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw 	$s2, 8($sp)
	sw 	$s3, 12($sp)
	sw 	$s4, 16($sp)
	sw 	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	
	# Now we can sRegisters use them. 
	add 	$s1, $zero, $a1		# s1 = a
	add 	$s2, $zero, $a2		# s2 = b
	add 	$s3, $zero, $a3		# s3 = c
	add	$s4, $zero, $t4		# s4 = d
	add 	$s5, $zero, $t5 		# s5 = e
	add 	$s6, $zero, $t6		# s6 = f
	
	# Initialize/Store returnVal, i, and count
	add 	$s0, $zero, $zero	# s0 = retVal
	add 	$t0, $zero, $zero	# i = 0
	add 	$s7, $zero, $a0 		# s7 = count
	
	# Start of for-loop until i >= count
	rotateLoop:
	addi 	$t1, $zero, 1		# t1 = 1
	slt	$t3, $t0, $s7		# t3 = (i < count)
	bne 	$t3, $t1, rotateAfter 	# if (i > count) exit for
	
	# Create new args for util()
	add 	$a0, $zero, $s1		# a0 = a
	add 	$a1, $zero, $s2		# a1 = b
	add 	$a2, $zero, $s3		# a2 = c
	add 	$a3, $zero, $s4		# a3 = d
	
	# Store last two params. 
	sw      $s5, -8($sp)		# param e
	sw      $s6, -4($sp)		# param f
	
	# Save tX Register in sX Register
	add	$s5, $zero, $t0		# s5 = $t0
	
	jal 	util
	add 	$s0, $s0, $v0 		# retval += util(a, b, c, d, e, f)
	
	# Get tX Register back
	add 	$t0, $zero, $s5
	
	# Get sX Registers back
	lw 	$s6, -4($sp)		# s6 = f
	lw 	$s5, -8($sp) 		# s5 = e
	
	# Swap all values
	add 	$t1, $zero, $s1		# t1 = a
	add	$s1, $zero, $s2		# a = b
	add 	$s2, $zero, $s3		# b = c
	add	$s3, $zero, $s4		# c = d
	add	$s4, $zero, $s5		# d = e
	add 	$s5, $zero, $s6		# e = f
	add 	$s6, $zero, $t1 		# f = temp
	
	addi 	$t0, $t0, 1		# i ++  
	j 	rotateLoop
	
	# Here after i >= count 
	rotateAfter:
	add	$v0, $zero, $s0 		# v0 = retVal
	
	# Store d, e, f back onto stack
	lw 	$s3, 16($sp)
	lw 	$s2, 20($sp)
	lw 	$s1, 24($sp)
	
	# Load s0, s1, s2, s3 registers back.
	lw	$s7, 28($sp)
	lw 	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw 	$s3, 12($sp)
	lw 	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addiu 	$sp, $sp, 32
	
	lw 	$ra, 4($sp)
	lw 	$fp, 0($sp)
	addiu 	$sp, $sp, 28
	jr	$ra
	
	
	
