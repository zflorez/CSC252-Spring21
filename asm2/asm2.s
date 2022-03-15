#
# Author: Zachary Florez
# Course: CSC 252
# Description: 	In this project we implement loops, iterating
#		over arrays of integers and strings. We implement 
#		these using for() and while() loops. 
#

.data 
NEWLINE: 	.asciiz "\n"
SPACE: 		.asciiz " " 

FIB: 		.asciiz "Fibonacci Numbers:\n"
FIB_ZERO: 	.asciiz "  0: 1\n"
FIB_ONE:		.asciiz "  1: 1\n"
FIB_SPACE: 	.asciiz "  "
FIB_COL: 	.asciiz ": "

ASCENDING:	.asciiz "Run Check: ASCENDING\n"
DESCENDING:	.asciiz "Run Check: DESCENDING\n"
NEITHER:		.asciiz "Run Check: NEITHER\n"

SWAP:		.asciiz "String successfully swapped!\n"


.text
.globl studentMain 
studentMain: 
	addiu 	$sp, $sp, -24		# allocate stack space -- default of 24 here
	sw 	$fp, 0($sp)		# save caller<92>s frame pointer
	sw	$ra, 4($sp) 		# save return address
	addiu 	$fp, $sp, 20		# setup main<92>s frame pointer
	
	la 	$s0, fib 		# s0 = &fib
	lw 	$s0, 0($s0) 		# s0 = fib
	la	$s1, square 		# s1 = &square
	lw	$s1, 0($s1) 		# s1 = square
	la	$s2, runCheck		# s2 = &runCheck
	lw	$s2, 0($s2) 		# s2 = runCheck 
	la 	$s3, countWords		# s3 = &countWords
	lw 	$s3, 0($s3) 		# s3 = countWords
	la	$s4, revString		# s4 = &revString
	lw 	$s4, 0($s4) 		# s4 = revString
	
	
	# Start of Task 1: Fibonacci 
	# For this task, we will first check if fib is not equal to zero. If
	# it is not equal to zero than what we do is print out Fibonacci 
	# numbers while 2 is less than the inputted fib integer. 

	beq 	$s0, $zero, END_FIB	# if (fib == 0), skip to end. 
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, FIB			# print_str("Fibonacci numbers:\n")
	syscall
	
	addi 	$v0, $zero, 4 		# print_str 
	la 	$a0, FIB_ZERO 		# print_str("  0: 1\n")
	syscall
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, FIB_ONE		# print_str("  1: 1\n")
	syscall
	
	addi 	$t0, $zero, 1 		# t0 = prev (1)
	addi 	$t1, $zero, 1		# t1 = beforeThat (1)
	addi 	$t2, $zero, 2		# t2 = n (2)
	
	FIB_WHILE:
	
	slt 	$t3, $s0, $t2		# t3 = (n > fib)
	addi 	$t5, $zero, 1 		# t5 = 1
	beq 	$t3, $t5, FIB_PRINT	# if (n <= fib)
	
	add 	$t4, $t0, $t1 		# cur = prev + beforeThat
	
	addi 	$v0, $zero, 4 		# print_str 
	la 	$a0, FIB_SPACE 		# print_str("  ")
	syscall
	
	addi 	$v0, $zero, 1 		# print_int
	add 	$a0, $zero, $t2		# print_int(n)
	syscall
	
	addi 	$v0, $zero, 4 		# print_str 
	la 	$a0, FIB_COL 		# print_str(":")
	syscall
	
	addi 	$v0, $zero, 1 		# print_int
	add 	$a0, $zero, $t4		# print_int(n)
	syscall
	
	addi 	$v0, $zero, 4 		# print_str 
	la 	$a0, NEWLINE 		# print_str("\n")
	syscall
	
	addi 	$t2, $t2, 1 		# n ++
	add 	$t1, $zero, $t0		# beforeThat = prev
	add 	$t0, $zero, $t4 		# prev = cur
	
	j FIB_WHILE
	
	 	
	FIB_PRINT:
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, NEWLINE		# print_str("\n")
	syscall
	
	END_FIB:				# End of Task 1
	
	
	
	# Start of Task 2: square
	# For this task all we do is implement the following code: 
	
	# if (square != 0) {
	#
	# 	// NOTE: square_fill is a byte
	# 	// NOTE: square_size is a word
	#
	# 	for (int row=0; row < square_size; row++) {
	# 		char lr, mid;
	#		if (row == 0 || row == square_size-1){
	#			lr = ’+’;
	#			mid = ’-’;
	#		} else {
	# 			lr = ’|’;
	#			mid = square_fill;
	#		}
	#
	# 		printf("%c", lr);
	# 		for (int i=1; i<square_size-1; i++)
	#			printf("%c", mid);
	#		printf("%c\n", lr); 
	# 	}
	#
	#	printf("\n");
	# }
	 
	beq 	$s1, $zero, END_SQUARE 	# if (square == 0), skip code
	
	add 	$t0, $zero, $zero 	# t0 =  row(0)
	
	la 	$s5, square_size 	# s5 = &square_size
	lw 	$s5, 0($s5) 		# s5 = square_size
	la 	$s6, square_fill		# s6 = &square_fill
	lb 	$s6, 0($s6) 		# s6 = square_fill
	
	SQUARE_OUTER_FOR: 
	
	slt	$t1, $t0, $s5 		# t1 = (row < square_size)
	
	beq 	$t1, $zero, SQUARE_PRI 	# if (row >= square_size), skip to "\n"
	
	beq 	$t0, $zero, SET1 	# if (row == 0)
	
	addi 	$t7, $zero, 1		# t7 = 1
	sub 	$t7, $zero, $t7		# t7 = -1
	
	add 	$t2, $s5, $t7 		# t2 = square_size - 1
	beq 	$t0, $t2, SET1		# if (row == square_size - 1)
	
	j SET2
	
	SET1:
	addi	$t8, $zero, 0x2B		# (t8) lr = '+'
	addi 	$t9, $zero, 0x2D 	# (t9) mid = '-'
	
	j PRINT_LR
	
	SET2:
	addi 	$t8, $zero, 0x7C 	# (t8) lr = '|'
	add 	$t9, $zero, $s6		# (t9) mid = square_fill
	
	j PRINT_LR
	
	PRINT_LR:
	
	addi 	$v0, $zero, 11 		# print_char
	add 	$a0, $zero, $t8		# print_char(lr)
	syscall
	
	addi 	$t7, $zero, 1 		# i ++
	
	addi 	$t6, $zero, 1		# t9 = 1
	sub 	$t6, $zero, $t6		# t9 = -1
	
	add 	$t2, $s5, $t6 		# t2 = square_size - 1
	
	SQUARE_INNER_FOR: 
	
	slt 	$t6, $t7, $t2 		# t6 = (i < square_size - 1)
	beq 	$t6, $zero, PRINT_LR2 	# if (i >= square_size - 1)
	
	addi 	$v0, $zero, 11 		# print_char
	add 	$a0, $zero, $t9		# print_char(mid)
	syscall
	
	addi 	$t7, $t7, 1		# t7 ++
	
	j SQUARE_INNER_FOR
	
	PRINT_LR2:
	addi 	$v0, $zero, 11 		# print_char
	add 	$a0, $zero, $t8		# print_char(lr)
	syscall
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, NEWLINE		# print_str("\n")
	syscall
	
	addi 	$t0, $t0, 1 		# row ++
	j SQUARE_OUTER_FOR		
	
	SQUARE_PRI:
	addi 	$v0, $zero, 4 		# print_str 
	la 	$a0, NEWLINE 		# print_str("\n")
	syscall
	
	END_SQUARE:
	
	
	
	
	# Start of Task 3: Run Check 
	# For this task we first start by checking if runCheck is equal to 
	# one. If it is we will then scan through the array of integers 
	# intArray. If intArray is sorted i ascending order then we print out
	# "Run Check: ASCENDING", if it is in decending order then we print
	# out "Run Check: DESCENDING". Otherwise we print out "Run Check: NEITHER
	# after any case we also print out a newline. If we run into a array 
	# that is size zero or size one we print out that is both ascending and 
	# descending. 
	
	addi 	$t1, $zero, 1
	bne 	$s2, $t1, END_RC
	
	la 	$t1, intArray	 	# t1 = &intArray

	la	$t2, intArray_len 	# t2 = &intArray_len
	lw	$t2, 0($t2) 		# t2 = intArray_len
	
	beq 	$t2, $zero, PRI_BOTH 	# if (length = 0) print both out. 
	addi 	$t0, $zero, 1		# t0 = 1
	beq 	$t2, $t0, PRI_BOTH 	# if (length = 1) print both out. 
	
	
	# First start to check if array is in ascending order.  
	add 	$t0, $zero, $zero	# i = 0
	
	RUN_ASC:
	add 	$t6, $t2, $t2		# t6 = arrayLength * 2
	add 	$t6, $t6, $t6 		# t6 = arrayLength * 4
	
	addi 	$t9, $zero, 4		# t9 = 4
	sub 	$t9, $zero, $t9		# t9 = -4
	add 	$t6, $t6, $t9
	
	beq 	$t0, $t6, PRI_ASC 	# if (i == intArray_len), exit while.
	
	add	$t6, $t0, $zero		# t6 = i
	addi 	$t7, $t0, 4		# t7 = i + 1
	
	add 	$t8, $t1, $t6 		# t8 = &intArray[i]
	lw 	$s6, 0($t8)	 	# s6 = intArray[i]
	
	add 	$t9, $t1, $t7 		# t9 = &intArray[i + 1]
	lw 	$s7, 0($t9)		# s7 = intArray[i + 1] 
	
	slt 	$t5, $s7, $s6 		# t5 = intArray[i + 1] < intArray[i]
	addi 	$t7, $zero, 1		# t7 = 1
	
	beq 	$t5, $t7, TRY_DES	# if (intArray[i] > intArray[i + 1])  
	
	addi 	$t0, $t0, 4		# i += 4
	
	add 	$t6, $t2, $t2		# t6 = arrayLength * 2
	add 	$t6, $t6, $t6 		# t6 = arrayLength * 4
	
	beq 	$t0, $t6, PRI_ASC	# if true: print out Run Check.
	
	j RUN_ASC 			# jump back to for loop. 

	# Start to see if array is in descending order. 
	TRY_DES:
	add 	$t0, $zero, $zero 	# i = 0
	
	RUN_DES:
	add 	$t6, $t2, $t2		# t6 = arrayLength * 2
	add 	$t6, $t6, $t6 		# t6 = arrayLength * 4
	
	addi 	$t9, $zero, 4		# t9 = 4
	sub 	$t9, $zero, $t9		# t9 = -4
	
	add 	$t6, $t6, $t9		# t6 = (arrayLength - 1)
	beq 	$t0, $t6, PRI_DES 	# if (i == intArray_len), exit while.
	
	add	$t6, $t0, $zero		# t6 = i
	addi 	$t5, $t6, 4 		# t5 = (i + 1)
	
	add 	$t6, $t1, $t6 		# t6 = &intArray[i]
	lw 	$s6, 0($t6)	 	# s6 = intArray[i]
	
	add 	$t5, $t1, $t5 		# t5 = &intArray[i + 1]
	lw 	$s7, 0($t5)		# t4 = intArray[i + 1] 
	
	slt 	$t5, $s6, $s7 		# t5 = intArray[i] < intArray[i + 1]
	addi 	$t7, $zero, 1		# t7 = 1
	
	beq 	$t5, $t7, PRI_NEITHER	# if (false) try descending order.  
	
	addi 	$t0, $t0, 4		# i += 4
	
	add 	$t6, $t2, $t2		# t6 = arrayLength * 2
	add 	$t6, $t6, $t6 		# t6 = arrayLength * 4
	
	beq 	$t0, $zero, PRI_DES	# if true: print out Run Check.
	
	j RUN_DES 			# jump back to for loop. 
	
	# Printing Statements
	PRI_ASC: 
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, ASCENDING		# print_str("Run Check: ASCENDING\n")
	syscall
	
	j TRY_DES			# Once you get here jump back to check for special cases.  
	
	PRI_DES: 
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, DESCENDING		# print_str("Run Check: DESCENDING\n")
	syscall
	
	j RC_PRINT			# Once you get here skip to last print. 
	
	PRI_NEITHER:
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, NEITHER		# print_str("Run Check: NEITHER\n")
	syscall
	
	j RC_PRINT
	
	PRI_BOTH:
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, ASCENDING		# print_str("Run Check: ASCENDING\n")
	syscall
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, DESCENDING		# print_str("Run Check: DESCENDING\n")
	syscall
	
	RC_PRINT: 
	addi 	$v0, $zero, 4 		# print_str 
	la 	$a0, NEWLINE 		# print_str("\n")
	syscall
	
	
	END_RC:				# End of Task 3 runCheck
	
	
	
	
	# Start of Task 4: countWords
	# For this task we first check if countWords is equal to one. If it 
	# isn't then proceed to next task. If it is equal to one then we read
	# in the string str and count the number of words in it, where words 
	# are seperated by a spaces or newlines. After that loop we print out the 
	# the number of words, again followed by a blank line. 
	
	addi 	$t0, $zero, 1		# t0 = 1
	beq 	$s3, $t0, START_CW 	# Start countWords if countWords == 1
	j END_CW
	
	START_CW:
	la 	$s7, str			# s7 = &str
	add 	$t0, $zero, $zero 	# t0 = 0 (word count)
	
	addi 	$t1, $zero, 0 		# i = 0
	
	CW_LOOP: 
	
	add 	$t2, $s7, $t1		# t2 = pointer to access array at. 
	lb 	$t3, 0($t2)		# t3 = str[i] 
	beq 	$t3, $zero, CW_PRINT 	# if (str[i] = null), last print.
	
	addi 	$t4, $t1, 1		# t4 = i + 1
	add 	$t4, $s7, $t4 		# t4 = &str[i + 1]
	lb 	$t4, 0($t4) 		# t4 = str[i + 1]
	
	# Now check if str[i] == " " or "\n" then we continue with our for loop
	# But if we have str[i] equals a char and then  && str[i + 1] == " " or "\n"
	# then count ++ (means we got to the end of a word)
	
	addi 	$t5, $zero, 0x20 	# t5 = " " 
	addi 	$t6, $zero, 0xA		# t5 = "\n"
	beq 	$t3, $t5, increment	# if str[i] = " " continue with loop. 
	beq 	$t3, $t6,  increment	# if str[i] = "\n" continue with loop.
	
	beq 	$t4, $t5, addCount 	# if str[i + 1] = " " then count ++
	beq 	$t4, $t6,  addCount	# if str[i + 1] = "/n" then count ++
	
	# if we get here then we are comparing two chars [same word], don't add to count. 
	j increment
	 
	addCount:
	addi 	$t0, $t0, 1		# count ++
	
	increment:
	addi 	$t1, $t1, 1		# i ++
	
	j CW_LOOP
	
	CW_PRINT: 
	
	addi 	$v0, $zero, 1 		# print_int
	add 	$a0, $zero, $t0		# print_int(count)
	syscall
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, NEWLINE		# print_str("\n")
	syscall
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, NEWLINE		# print_str("\n")
	syscall
	
	END_CW:				# End of Task 4 countWords
	
	
	# Start of Task 5: revString
	# For this task we first check if revString is equal to one. If it isn't
	# then we procees with the next task. If it is then we scan through the 
	# str and reverse it in memory, being able to handle any size string. 
	addi 	$t0, $zero, 1
	bne 	$s4, $t0, END_RS		# if (revString == 1)
	
	add 	$t0, $zero, $zero 	# t0 = head(0)
	add 	$t1, $zero, $zero	# t1 = tail(0)
	
	# advance the tail until we find the correct location. 
	firstWhile:
	add 	$t2, $s7, $t1 		# t2 = &str[tail]
	lb	$t2, 0($t2) 		# t2 = str[tail] 
	beq 	$t2, $zero, endWhile1 	# if (str[tail] == 0) exit while loop
	addi 	$t1, $t1, 1		# tail ++
	j firstWhile
	
	endWhile1:
	addi 	$t9, $zero, 1		# t9 = 1
	sub 	$t9, $zero, $t9		# t9 = -1
	add 	$t1, $t1, $t9 		# tail -- 
	
	# When we get here, tail gives the index of the last non-NULL
	# character in the string. If the string is empty, it actually 
	# would be -1. 
	secondWhile: 
	slt 	$t4, $t0, $t1		# t4 = (head < tail)
	addi 	$t2, $zero, 1		# t2 = 1
		
	bne 	$t2, $t4, printRS 	# if ( head > tail ), skip while loop
	
	add 	$t2, $s7, $t0 		# t2 = &str[head]
	lb	$t5, 0($t2) 		# t5 = str[head] 
	
	add 	$t3, $s7, $t1 		# t2 = &str[tail]
	lb	$t6, 0($t3) 		# t6 = str[tail] 
	
	sb 	$t5, 0($t3)		# str[tail] = str[head]
	sb 	$t6, 0($t2)		# str{head] = str{tail]
	
	
	addi 	$t0, $t0, 1		# head ++
	
	addi 	$t9, $zero, 1		# t9 = 1
	sub 	$t9, $zero, $t9		# t9 = -4
	
	add	$t1, $t1, $t9		# tail --
	
	j secondWhile
	
	printRS:
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, SWAP		# print_str("String successfully swapped!\n")
	syscall
	
	addi 	$v0, $zero, 4 		# print_str
	la 	$a0, NEWLINE		# print_str("\n")
	syscall
	
	END_RS: 				# End of Task 5 revString.  
	
	
END: 
	lw 	$ra, 4($sp) 	# get return address from stack
	lw 	$fp, 0($sp)	# restore the caller's frane pointer
	addiu 	$sp, $sp, 24 	# restore the caller's stack pointer
	jr 	$ra 		# return the caller's code
	
