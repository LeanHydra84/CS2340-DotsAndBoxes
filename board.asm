    .data

board: .space 64
dotstr: .asciiz "  .  "
halfspacer: .asciiz "  "
threespacer: .asciiz "   "

    .text
    .globl draw_board
    .globl get_capture_char

### TEMP REGISTERS:
## $t0 : Array indexer
## $t1 : Horizontal Line counter
## $t2 : Vertical Height (NOT the same as tile height)
## $t3 : 
## $t4 : Vertical Line counter
###

draw_board:

	la $t0, board
	li $t1, 16
	
	sb $t1, 0($t0)
	sb $t1, 5($t0)
	sb $t1, 6($t0)

	# save return address
    subi $sp, $sp, 4
    sw $ra, ($sp)
    
    jal print_abcs

    # $s0 contains dimension

    li $t0, 0 # Array indexer
    li $t1, 0 # Horizontal line counter
    li $t4, 0 # Vertical line counter

	mul $t2, $s0, 2
	addi $t2, $t2, 1
	
	# Hardcoded zero at the beginning
	li $v0, 1
	li $a0, 0
	syscall

db_loop_pt:
    li $v0, 4 # print char
    la $a0, dotstr
    syscall

    j db_process_eol
    
db_get_val:
	
	li $v0, 4
	la $a0, halfspacer
	syscall
	
    # GET ARRAY VALUE
    lb $a0, board($t0)
    jal get_capture_char
    
    # print value from get_capture_char function
    move $a0, $v0
    li $v0, 11
    syscall
    
    addi $t0, $t0, 1
    
    li $v0, 4
	la $a0, halfspacer
	syscall
    
db_process_eol:
    # New Lines
    addi $t1, $t1, 1
    
    blt	$t1, $s0, db_skipnewline
    
    li $t1, 0
    li $v0, 11 # print char
    li $a0, 0xA # Newline ascii code
    syscall
    
    addi $t4, $t4, 1
    
    andi $t5, $t4, 1 # Mask bit for odd numbers
    beqz $t5, db_printlinenumber
    
    # Align symbols
    li $v0, 4
    la $a0, threespacer
	syscall
	j db_skipnewline
	
db_printlinenumber:
	li $v0, 1
	srl $a0, $t4, 1
	syscall

db_skipnewline:
    andi $t5, $t4, 0x1 # Mask bit for odd numbers
    bge $t4, $t2, db_exit # Loop until all values visited
    
    beqz $t5, db_loop_pt
    j db_get_val
    
    
db_exit:
    
    # RETURN
    lw $t0, ($sp)
    addi $sp, $sp, 4
    jr $t0


# Function to get the capture symbol for a given tile byte
get_capture_char:
	andi $t8, $a0, 48 # 48 = 0b110000
	beq $t8, 16, bgcc_comp
	beq $t8, 32, bgcc_pl
	
	li $v0, 32 # ' ' space ascii value
	jr $ra
bgcc_comp:
	li $v0, 99 # c ascii value
	jr $ra
bgcc_pl:
	li $v0, 120 # x ascii value
	jr $ra


# Print A B C
print_abcs:
	li $t0, 0
	li $t1, 65 # A ascii
	
	li $v0, 11
	li $a0, 32
	syscall
	
pabc_loop:
	
	li $v0, 4
	la $a0, halfspacer
	syscall
	
	li $v0, 11
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, halfspacer
	syscall
	
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	blt $t0, $s0, pabc_loop
	
	li $v0, 11
	li $a0, 10
	syscall
	
	jr $ra
	
	
	