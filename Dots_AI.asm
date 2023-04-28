.data 
	#sub array to store only the empty tiles
	empty_tiles: .space 192
	_side_tiles: .space 192
.text
.globl AI_turn

	
AI_turn:
	#load the address of the board array
	la $t0, board	
	la $t3, empty_tiles
	la $t5, side_tiles
	
	#counters to keep track of array sizes and indexes
	li $t2, 0
	li $t4, 0
	li $t6, 0
	li $t8, 0
	
#loops through the array and adds all the tiles that aren't captured yet to the array
empty_check:

	#check if the tile is not captured and branch if it isn't
	lw $t1, 0($t0)
	andi $t1, $t1, 32
	bne $t1, 32, is_captured
	
	#if it sn't captured, then add it to the sub array
	
	#count the number of sides filled and store in $t8
	andi $t7, $t1, 1
	bnez $t7, right
	addi $t8, $t8, 1
right:
	andi $t7, $t1, 2
	bnez $t7, left
	addi $t8, $t8, 1
left:
	andi $t7, $t1, 4
	bnez $t7, down
	addi $t8, $t8, 1
down:
	andi $t7, $t1, 8
	bnez $t7, up
	addi $t8, $t8, 1
up:
	#branch if there are less than 3 sides
	bne $t8, 3, less_sides
	sw $t2, ($t5)
	addi $t6, $t6, 1
	addi $t5, $t5, 4
	j is_captured
	
less_sides:
	sw $t2, ($t3)
	addi $t4, $t4, 1
	addi $t3, $t3, 4
	
is_captured:
	
	#check if it is about to go out of bounds of the array
	addi $t2, $t2, 1
	beq  $t2, 48, done_loop
	
	addi $t0, $t0, 4
	j empty_check
	
done_loop:
	#reset the address pointer of the empty array
	la $t3, empty_tiles
	
	#if there is at least one tile with 3 sides filled use that array instead
	beqz $t6, less_3_setup
	la $t3, side_tiles
	move $t4, $t6
less_3_setup:	

	#Generate a random number to randomly select a tile
	li $v0, 42 
	move $a1, $t4# Set upper bound to number of empty tiles
	syscall     # your generated number will be at $a0
	
#traverse the loop to get to the index of empty tile
sub_loop:
	beq $a0, 0, sub_loop_done
	addi $t3, $t3, 4
	addi $a0, $a0, -1
	
	j sub_loop
	
sub_loop_done:
	
	#load the index of the empty tile to t1
	lw $t1, ($t3)
	la $t0, board
	
#loops through the board to get to the empty tile
sub_loop2:
	beq $t1, 0, sub_loop2_done
	addi $t0, $t0, 4
	addi $t1, $t1, -1
	
	j sub_loop2

sub_loop2_done:

	lw $t1, 0($t0)
	
	#randomly select an empty side of the tile to fill in
	
side_loop:
	#Generate a random number to randomly select a tile
	li $v0, 42 
	li $a1, 4 # Set upper bound to number of sides
	syscall
	
	#t3 will contain the mask or selected bit of the side
	li $t3, 1
	
#shift t3 a random amount of times to get a random side
	j shift_loop
shifted:
	#if the randomly selected side is already filled then try again
	and $t4, $t1, $t3
	bnez $t4, side_loop

	#if the randomly selected side is empty then set it to be selected
	or $t1, $t1, $t3
	
	#check if tile is meant to be captured, jump to exit 
	andi $t4, $t1, 15
	bne $t4, 15, exit
	
	#capture the tile by AI, set 6th bit to 1
	ori $t1, $t1, 32
	#AI gets another turn if it captures a tile
	j AI_turn
	
exit:
	#store the changes into the board array
	sw $t1, 0($t0)
	jr $ra
	
#shifts the number left x amount of times
shift_loop:
	beq $a0, 0, shifted
	sll $t3, $t3, 1
	addi $a0, $a0, -1

j shift_loop