.section .data
filename: .asciz "input.txt"
mode: .asciz "r"
yes: .asciz "Yes\n"
no: .asciz "No\n"

.section .text
.globl main

main:
    addi sp, sp, -56
    sd x1, 48(sp)   # storing return address
    sd x9, 40(sp)   # file
    sd x18, 32(sp)   # i
    sd x19, 24(sp)   # j
    sd x5, 16(sp)   # n
    sd x6, 8(sp)   # left
    sd x7, 0(sp)   # right

    # open file
    la x10, filename
    la x11, mode
    call fopen
    mv x9, x10

    # exit if can't open
    beq x9, x0, exit

    # move the cursor to end of file
    li x11, 0
    li x12, 2
    call fseek

    # store the size of file into x5(n)
    mv x10, x9
    call ftell
    mv x5, x10
    
    # i=0, j=n-1
    mv x18, x0
    addi x19, x5, -1

    # entering while loop
    beq x0, x0, while_loop

while_loop:
    # fseek(file, i, SEEK_SET)
    mv x10, x9
    mv x11, x18
    li x12, 0
    call fseek
    
    # left(x6) = fgetc(file)
    mv x10, x9
    call fgetc
    mv x6, x10

    # fseek(file, j, SEEK_SET)
    mv x10, x9
    mv x11, x19
    li x12, 0
    call fseek
    
    # right(x7) = fgetc(file)
    mv x10, x9
    call fgetc
    mv x7, x10

    bne x6, x7, print_no    # if left != right, print no
    
    addi x18, x18, 1    # i++
    addi x19, x19, -1   # j--

    blt x18, x19, while_loop    # if i < j go again into the loop

    beq x0, x0, print_yes   # if i >= j print yes

# prints yes
print_yes:
    la x10, yes
    call printf

    beq x0, x0, exit

# prints no
print_no:
    la x10, no
    call printf

    beq x0, x0, exit

# return
exit:
    # restore all the values which are stored in stack
    ld x7, 0(sp)
    ld x6, 8(sp)
    ld x5, 16(sp)
    ld x19, 24(sp)
    ld x18, 32(sp)
    ld x9, 40(sp)
    ld x1, 48(sp)
    addi sp, sp, 56

    ret