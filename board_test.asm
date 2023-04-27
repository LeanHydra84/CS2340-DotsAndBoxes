    .text

main:

    li $s0, 8
    li $s1, 6

    # TEST CODE


    jal draw_board

    addi $v0, $0, 10
    syscall
