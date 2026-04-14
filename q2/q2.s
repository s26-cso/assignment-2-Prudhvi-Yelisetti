.section .data
iq_array:   .fill 100, 8, 0
res_array:  .fill 100, 8, 0
fmt_int:    .asciz "%ld "
fmt_nl:     .asciz "\n"

.section .text
.globl main

main:
    # store register values
    addi sp, sp, -48
    sd x1, 40(sp)
    sd x9, 32(sp)   # argc
    sd x18, 24(sp)  # argv
    sd x19, 16(sp)  # n
    sd x20, 8(sp)   # stack_base
    sd x21, 0(sp)   # loop index i

    mv x9, x10      # argc
    mv x18, x11     # argv pointer (CRITICAL: Save argv here)

    li x5, 1
    ble x9, x5, exit_early

    addi x19, x9, -1 # n = argc - 1
    li x21, 0        # i = 0

input_loop:
    bge x21, x19, start

    # Load argv[i + 1]
    addi x5, x21, 1
    slli x5, x5, 3
    add x5, x18, x5
    ld x10, 0(x5)    # x10 now holds the string pointer for atoi

    call atoi        # Result is in x10

    # Store integer in iq_array
    la x6, iq_array
    slli x7, x21, 3
    add x6, x6, x7
    sd x10, 0(x6)

    addi x21, x21, 1
    j input_loop

start:
    mv x20, sp       # Mark the base of the system stack
    addi x21, x19, -1 # i = n - 1 (Right to Left)

nge_loop:
    blt x21, x0, print_setup

    # Load current IQ: iq_array[i]
    la x5, iq_array
    slli x6, x21, 3
    add x6, x5, x6
    ld x22, 0(x6)

pop_loop:
    beq sp, x20, empty_stack # If sp == base, stack is empty

    ld x28, 0(sp)            # Peek index from top of stack

    # Load IQ at the index found on stack
    la x5, iq_array
    slli x6, x28, 3
    add x6, x5, x6
    ld x7, 0(x6)

    # If iq_array[stack_top] > current_iq, we found the NGE
    bgt x7, x22, nonempty_stack

    # Pop and continue
    addi sp, sp, 8
    j pop_loop

empty_stack:
    li x23, -1               # Fix: Added 'x' to register name
    j save_res

nonempty_stack:
    mv x23, x28              # The index at top of stack is the NGE position

save_res:
    # res_array[i] = x23
    la x5, res_array
    slli x6, x21, 3
    add x6, x5, x6
    sd x23, 0(x6)

    # Push current index onto stack
    addi sp, sp, -8
    sd x21, 0(sp)

    addi x21, x21, -1
    j nge_loop

print_setup:
    mv sp, x20               # Restore sp before calling printf
    li x21, 0                # i = 0

print_loop:
    bge x21, x19, print_done

    la x10, fmt_int
    la x5, res_array
    slli x6, x21, 3
    add x6, x5, x6
    ld x11, 0(x6)
    call printf

    addi x21, x21, 1
    j print_loop

print_done:
    la x10, fmt_nl
    call printf

exit_early:
    # restore registers
    ld x1, 40(sp)
    ld x9, 32(sp)
    ld x18, 24(sp)
    ld x19, 16(sp)
    ld x20, 8(sp)
    ld x21, 0(sp)
    addi sp, sp, 48

    li x10, 0
    ret