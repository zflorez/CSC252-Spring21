# 
# Author: Zachary Florez
# Course: CSC 252
# Description: 
#

.data
MED:	 	.asciiz "median: "
COMPARE: 	.asciiz "Comparisons: "
NEWLINE:		.asciiz "\n"
SPACE:		.asciiz " "
SUM: 		.asciiz "sum: "
ONE:		.asciiz "one: "
TWO:		.asciiz "two: "
THREE:		.asciiz "three: "
WAS_NEGATIVE_1: .asciiz "'one' was negative\n"
WAS_NEGATIVE_2: .asciiz "'two' was negative\n"
WAS_NEGATIVE_3: .asciiz "'three' was negative\n"

.text
.globl studentMain
studentMain: 
	addiu $sp, $sp, -24  # allocate stack space -- default of 24 here
	sw    $fp, 0($sp)    # save caller’s frame pointer
	sw    $ra, 4($sp)    # save return address
	addiu $fp, $sp, 20   # setup main’s frame pointer
	
	la       $s0, median  	# $s0 = &median
	lw 	 $s1, 0($s0)	# $s1 = median
	la       $s0, absVal  	# $s0 = &absVal
	lw 	 $s2, 0($s0)	# $s2 = &absVal
	la       $s0, sum     	# $s0 = &sum
	lw 	 $s3, 0($s0)	# $s3 = sum
	la       $s0, rotate	# $s0 = &rotate
	lw 	 $s4, 0($s0)	# $s4 = rotate
	la       $s0, dump	# $s0 = &dump
	lw 	 $s5, 0($s0)	# $s5 = dump
	la 	 $s0, one	# $s0 = &one
	lw 	 $s6, 0($s0)	# $s6 = one
	la  	 $s0, two	# $s0 = &two
	lw 	 $s7, 0($s0)	# $s7 = two
	la 	 $s0, three	# $s0 = &three
	lw 	 $s0, 0($s0) 	# $s0 = three
	


	# Start of Task 1: median
	addi $t0, $zero, 1	# t0 = 1
	bne $s1, $t0, END_MEDIAN # if (median == 1)
	
	bne $s6, $s7, ELSE_IF 	# if (one == two)
	
	addi $v0, $zero, 4   	# print_str
	la $a0, MED		# print_str("median: ")
	syscall
	
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s6	# print_int(one)
	syscall
	
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall 
	
	j LAST_PRINT		# jump to print a new line 
		
	bne $s6, $s0, ELSE_IF	# if (one == three)
	
	addi $v0, $zero, 4   	# print_str
	la $a0, MED		# print_str("median: ")
	syscall
	
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s6	# print_int(one)
	syscall
	
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
		
	j LAST_PRINT		# jump to print a new line    
	
	ELSE_IF: 
	bne $s7, $s0, ELSE 	# else if (two == three)
	
	addi $v0, $zero, 4 	# print_str
	la $a0, MED		# print_str("median: ")
	syscall
		
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s7 	# print_int(two)
	syscall
		
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
		
	j LAST_PRINT		# jump to print a new line 
		
		
	ELSE: 
	slt $t0, $s6, $s7 	# $t0 = (one < two)
	slt $t1, $s6, $s0 	# $t1 = (one < three)
	slt $t2, $s7, $s0 	# $t2 = (two < three)
		
	addi $v0, $zero, 4 	# print_str
	la $a0, COMPARE		# print_str("Comparisons: ")
	syscall
		
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $t0 	# print_int(cmp12)
	syscall
		
	addi $v0, $zero, 4	# print_str
	la $a0, SPACE		# print_str(" ")
	syscall
	
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $t1 	# print_int(cmp13)
	syscall
	
	addi $v0, $zero, 4	# print_str
	la $a0, SPACE		# print_str(" ")
	syscall
		
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $t2 	# print_int(cmp23)
	syscall
		
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
		
	bne $t0, $t1, NEXT_IF 	# if (cmp12 == cmp23)
			
	addi $v0, $zero, 4 	# print_str
	la $a0, MED		# print_str("median: ")
	syscall
		
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s7 	# print_int(two)
	syscall
		
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
		
	j LAST_PRINT		# jump to print a new line 
		
	NEXT_IF:
	beq $t0, $t2, LAST_IF	# if (cmp12 != cmp13)
			
	addi $v0, $zero, 4 	# print_str
	la $a0, MED		# print_str("median: ")
	syscall
		
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s6 	# print_int(one)
	syscall
		
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
		
	j LAST_PRINT		# jump to print a new line 
		
	LAST_IF:
	beq $t1, $t2, LAST_PRINT	# if (smp13 != cmp23)
			
	addi $v0, $zero, 4 	# print_str
	la $a0, MED		# print_str("median: ")
	syscall
		
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s0 	# print_int(three)
	syscall
		
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
		
	j LAST_PRINT		# jump to print a new line
	
	LAST_PRINT:
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall

	j END_MEDIAN
	
	END_MEDIAN:	 	# Median part over 
	

	
	
	# Start of Task 2 absVal. 
	addi $t9, $zero, 1 		# t9 = 1
	bne $s2, $t9, END_ABSVAL 	# if (absVal == 1)
	srl $t0, $s6, 31		# $t0 = MSB of one
	srl $t1, $s7, 31		# $t1 = MSB of two
	srl $t2, $s0, 31		# $t2 = MSB of three
	
	bne $t0, $t9, CHECK_2 	# if (one is negative)
	addi $v0, $zero, 4 	# print_str
	la $a0, WAS_NEGATIVE_1	# print_str("one was negative")
	syscall
			

	sub $s6, $zero, $s6	# s6 = 0 + one (one negated)
	
	la $t5, one 		# t5 = &one
	sw $s6, 0($t5)		# s6 = (one negated)
		
	j CHECK_2
	
	CHECK_2:
	bne $t1, $t9, CHECK_3 	# if (two is negative)
	addi $v0, $zero, 4 	# print_str
	la $a0, WAS_NEGATIVE_2	# print_str("two was negative")
	syscall
			
	sub $s7, $zero, $s7	# t3 = 0 + two (two negated)
	
	la $t6, two 		# t6 = &two
	sw $s7, 0($t6)		# s7 = (two negated)
	
	j CHECK_3
	
	CHECK_3:
	bne $t2, $t9, ABS_VAL_PRINT 	# if (three is negative)
	
	addi $v0, $zero, 4 	# print_str
	la $a0, WAS_NEGATIVE_3	# print_str("three was negative")
	syscall
			
	sub $s0, $zero, $s0	# s0 = 0 + three (three negated)
	
	la $t7, three 		# t7 = &three
	sw $s0, 0($t7)		# s0 = (three negated)
			
	j ABS_VAL_PRINT
	
	ABS_VAL_PRINT: 
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
		
	j END_ABSVAL
			
	END_ABSVAL: 	# Task 2 absVal over
	
	
	
	# Start of Task 3 sum
	bne $s3, $t9, END_SUM	# if (sum == 1)
	
	add $t5, $s6, $s7	# t5 = one + two 
	add $t5, $t5, $s0	# t5 = (one + two) + three
	
	addi $v0, $zero, 4 	# print_str
	la $a0, SUM		# print_str("sum: ")
	syscall
	
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $t5	# print_int(sum)
	syscall
	
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall	
	
	j SUM_PRINT
	
	SUM_PRINT: 
	addi $v0, $zero, 4	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
	
	j END_SUM
	
	END_SUM: 		# Task 3 sum OVER
	
	
	
	# Start of Task 4 rotate
	bne $s4, $t9, END_ROTATE # if (rotate == 1)
	
	add $t0, $zero, $s0 	# t0 = three
	add $t1, $zero, $s7 	# t1 = two
	add $t2, $zero, $s6 	# t2 = one

	add $s6, $t0, $zero 	# one = three
	add $s7, $t2, $zero 	# two = one
	add $s0, $t1, $zero 	# three = two
	
	la $t0, three 		# $t0 = &three
	sw $s0, 0($t0)		# three = two

	la $t0, two 		# $t0 = &two
	sw $s7, 0($t0)		# two = one
	
	la $t0, one 		# $t0 = &one
	sw $s6, 0($t0)		# one = three
	
	j END_ROTATE
	
	END_ROTATE: 		# Task 4 rotate over
	
	
	
	# Start of Task 5 dump 
	bne $s5, $t9, END_DUMP 	# if (dump == 1)
	
	addi $v0, $zero, 4 	# print_str
	la $a0, ONE		# print_str("one: ")
	syscall
	
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s6	# print_int(one)
	syscall
	
	addi $v0, $zero, 4 	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
	
	addi $v0, $zero, 4 	# print_str
	la $a0, TWO		# print_str("two: ")
	syscall
	
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s7	# print_int(two)
	syscall
	
	addi $v0, $zero, 4 	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
	
	addi $v0, $zero, 4 	# print_str
	la $a0, THREE		# print_str("three: ")
	syscall
	
	addi $v0, $zero, 1 	# print_int
	add $a0, $zero, $s0	# print_int(three)
	syscall
	
	addi $v0, $zero, 4 	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall

	addi $v0, $zero, 4 	# print_str
	la $a0, NEWLINE		# print_str("\n")
	syscall
	
	j END_DUMP
	
	END_DUMP: 		# Task 5 dump OVER



END:
	lw    $ra, 4($sp)    # get return address from stack
	lw    $fp, 0($sp)    # restore the caller's frame pointer
	addiu $sp, $sp, 24   # restore the caller's stack pointer
	jr $ra 		     # return the caller's code
	
			
