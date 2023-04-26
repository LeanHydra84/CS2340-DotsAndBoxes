    .data

board: .space 64
dotstr: .asciiz " . "
hdash: .asciiz "--"
halfspacer: .asciiz "  "
threespacer: .asciiz "   "

    .text
    .globl draw_board
    .globl get_capture_char

### TEMP REGISTERS:
## $t0 : Array indexer
## $t1 : Horizontal Line counter
## $t2 : Vertical Height (NOT the same as tile height)
## $t4 : Vertical Line counter
## $t3 : 
###

draw_board:
	# TEST CODE
	la $t0, board
	li $t1, 8
	
	sb $t1, 0($t0)
	sb $t1, 5($t0)
	sb $t1, 6($t0)
	sb $t1, 63($t0)
	# END TEST CODE

	# save return address
    subi $sp, $sp, 4
    sw $ra, ($sp)
    
	jal print_abcs

	# $s0 contains dimension

	li $t0, 0 # Array indexer
	li $t1, 0 # Horizontal line counter
	li $t4, 0 # Vertical line counter

	# number of total rows drawn (tiles + dots)
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
    
    # GET LINE LEFT->RIGHT from below tile
    add $t5, $t0, $t1 # Get address of below tile
    subi $t6, $t2, 1
    bne $t4, $t6, db_horiz_skip_edgecase # check if last row
    
    # EDGE CASE
    sub $t5, $t5, $s0 # subtract row size to get tile above
    lb $t5, board($t5)
    andi $t5, $t5, 4 # 0100
    beqz $t5, db_draw_horiz_blank
    j db_draw_horiz_dash
    
db_horiz_skip_edgecase:
    lb $t5, board($t5)
	andi $t5, $t5, 8 # 1000
	beqz $t5, db_draw_horiz_blank
	
db_draw_horiz_dash:
	# Draw horizontal dash
	li $v0, 4
	la $a0, hdash
	syscall
	
	j db_process_eol
	
db_draw_horiz_blank:
	li $v0, 4
	la $a0, halfspacer
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
    
db_process_eol: # checks for end of line, adds newline + other stuff
    # New Lines
    addi $t1, $t1, 1
    
    blt	$t1, $s0, db_skipnewline
    addi $t4, $t4, 1
    andi $t5, $t4, 0x1 # Mask bit for odd numbers
    beqz $t5, db_printnewline
    
    li $v0, 4
    la $a0, dotstr
    syscall
    
db_printnewline:
    li $t1, 0
    li $v0, 11 # print char
    li $a0, 0xA # Newline ascii code
    syscall

    

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
# END DRAW FUNCTION


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
# END GET_CAPTURE_CHAR FUNCTION


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

	# end pabc_loop
	
	# trailing newline
	li $v0, 11
	li $a0, 10
	syscall
	
	jr $ra
# END PRINT_ABC FUNCTION

set_line_between:
	# $a0 : dot 1 x
	# $a1 : dot 1 y
	# $a2 : dot 2 x
	# $a3 : dot 2 y
	
	beq $a0, $a2, slb_vline # if both x values are the same, the line is vertical
slb_hline:
	
	# Top address = board offset: (d1X + s0 * minY)
	# Bottom address = board offset: (d1X + s0 * maxY)
	
	# get minY
	
	
	mul $t1, $s0, #MINY
	
	
	
	jr $ra
slb_vline:

	# Left address = board offset: (s0 * d1Y + minX)
	# Right address = board offset: (s0 * d1Y + maxX)
	jr $ra

# END SET_LINE_BETWEEN FUNCTION


	
