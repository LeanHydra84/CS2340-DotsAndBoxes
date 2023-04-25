    .data

strv: .asciiz "Testing: \n"

    .text

main:

    li $s0, 8

    addi $v0, $0, 4
    la $a0, strv
    syscall

    jal draw_board

    addi $v0, $0, 10
    syscall
