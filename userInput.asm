#USER INPUT FOR DOTS AND BOXES
	.data
playerMove: .asciiz "Enter user move"
buffer: .space 6 #space for a 5 character string plus null terminator
invalidInput: .asciiz "Enter a valid string (ex: \"a1-b1\")"

	.text
	
	.globl getinput
	
get_input:
	#prompt for user input
	li $v0, 4
	la $a0, playerMove
	syscall
	
	li $v0, 8
	la $a0, buffer
	li $a1, 6
	syscall
	
	#Validate the input string's length and format (e.g., check if it has the correct length of 5 characters and follows the "X1-Y1" pattern).
	#check if input string has 5 characters
	la $t0, buffer
	li $t1, 0
	li $t2, 5
	countCharacters:
		lb $t3, 0($t0)
		beqz $t3, checkLength
		addi $t1, $t1, 1
		addi $t0, $t0, 1
		j countCharacters
		
	checkLength:
		bne $t1, $t2, invalidInput
		
		#proceed to validate the input
		#loading the string into separate registers for ease of access later on
		la $t0, buffer
		lb $t1, 0($t0)
		lb $t2, 1($t0)
		lb $t3, 2($t0)
		lb $t4, 3($t0)
		lb $t5, 4($t0)
		
		#Check if the first and fourth characters are digits
		blt $t1, 'A', invalidInput
		bgt $t1, 'z', invalidInput
		blt $t4, 'A', invalidInput
		bgt $t4, 'z', invalidInput
		
		#Check if the second and fifth characters are digits
		blt $t2, '0', invalidInput
  		bgt $t2, '9', invalidInput
  		blt $t5, '0', invalidInput
  		bgt $t5, '9', invalidInput
  		
  		#Check if the third character is a hyphen
  		bne $t3, '-', invalidInput
	
	#Convert the letter (column) and number (row) characters to row and column indices, considering that indices are 0-based.
	li $t2, 'a' #load ascii value of a
	sub $s0, $t1, $t2 # subtract ascii value of 'a' to get the column index
	sub $s2, $t4, $t2 # same thing
	#s0 and s3 hold column index (starting at 0)
	
	li $t2, '1' #load ascii value of 1
	sub $s1, $t1, $t2 #subtract ascii value of '1' to get row index
	sub $s3, $t5, $t2 #same thing
	#s1 and s3 hold row index (starting at 0) 
	#use these indices to update the board state
	
	
	
	#Check if the move is valid according to the game rules.
	#no clue how to do this yet
	
	#Update the board state with the given move.
	#no clue how to do this yet either
	
	li $v0, 10
	syscall
	
	jr $ra
