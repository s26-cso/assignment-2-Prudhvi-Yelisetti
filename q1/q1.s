.text

.globl maxm
.globl make_node
.globl insert
.globl get
.globl getAtMost

.equ val, 0
.equ left, 8
.equ right, 16
.equ node, 24

maxm:
    blt x10, x11, max
    ret

max:
    mv x10, x11
    ret

# Takes an interger as input and returns a node pointer which contains the integer as it's value. 
make_node:      # node* make_node(int val)
    # Storing values in x5, x1 as x5 is being used, value in x1 will change as we are using call 
    addi sp, sp, -16
    sd x1, 8(sp)
    sd x5, 0(sp)

    # Storing val (input) int x5
    mv x5, x10

    # Allocating size of a Node into x10
    li x10, node
    call malloc
    
    # Assigning respective values into the node
    sw x5, val(x10)
    sd x0, left(x10)
    sd x0, right(x10)

    # Restoring values of x5, x1
    ld x5, 0(sp)
    ld x1, 8(sp)
    addi sp, sp, 16

    ret

# Takes root node pointer, integer val (value that should be inserted) as inputs, return root node pointer after updating
insert:      # node* insert(node* root, int val)
    # If node is not null, traverses otherwise insert at root
    bne x10, x0, traverse
    beq x10, x0, root_insert

    ret

# This function traverses through root, finds appropriate posotion for insertion of node.
traverse:
    lw x5, val(x10)

    # Decide whether to go right or left
    # If val < root->val go right
    bgt x5, x11, left_insert
    # else go left
    ble x5, x11, right_insert

    ret

# Calls recursion on insert func with root->left, val as inputs 
left_insert:
    # Stores the values of x10, x1, x5
    addi sp, sp, -24
    sd x10, 16(sp)
    sd x1, 8(sp)
    sd x5, 0(sp)

    # Replacing x10(node) with left(x10) (node->left) ans passing it through insert
    ld x10, left(x10)
    call insert

    # Storing new left subtree into node->left
    ld x5, 16(sp)
    sd x10, left(x5)

    # Restoring x10, x1, x5 values
    ld x10, 16(sp)
    ld x1, 8(sp)
    ld x5, 0(sp)
    addi sp, sp, 24

    ret

# Calls recursion on insert func with root->right, val as inputs 
right_insert:
    # Stores the values of x10, x1, x5
    addi sp, sp, -24
    sd x10, 16(sp)
    sd x1, 8(sp)
    sd x5, 0(sp)

    # Replacing x10(node) with right(x10) (node->right) ans passing it through insert
    ld x10, right(x10)
    call insert

    # Storing new right subtree into node->right
    ld x5, 16(sp)
    sd x10, right(x5)

    # Restoring x10, x1, x5 values
    ld x10, 16(sp)
    ld x1, 8(sp)
    ld x5, 0(sp)
    addi sp, sp, 24

    ret

# Insert new node in position of root
root_insert:
    # Store value of x1
    addi sp, sp, -8
    sd x1, 0(sp)

    # Store val into x10, pass it through make_node
    mv x10, x11
    call make_node

    # Restore the value of x1
    ld x1, 0(sp)
    addi sp, sp, 8

    ret

# Take a value as input, return the node with that value if any
get:
    # If root is Null, return Null
    beq x10, x0, get_null
    # Else continue

    # Store x5
    addi sp, sp, -8
    sd x5, 0(sp)

    # val(root) is assigned to x5 
    lw x5, val(x10)

    # move left if val(root) > val right otherwise
    bgt x5, x11, move_left
    blt x5, x11, move_right

    # Restore x5
    lw x5, 0(sp)
    addi sp, sp, 8

    ret

# Returns Null
get_null:
    mv x10, x0

    ret

move_left:
    # root = root->left
    ld x10, left(x10)

    # Restore x5
    lw x5, 0(sp)
    addi sp, sp, 8

    # get(root)
    beq x0, x0, get

move_right:
    # root = root->right
    ld x10, right(x10)

    # Restore x5
    lw x5, 0(sp)
    addi sp, sp, 8

    # get(root)
    beq x0, x0, get

getAtMost:
    beq x11, x0, return_negative1

    addi sp, sp, -8
    sd x5, 0(sp)

    lw x5, val(x11)

    bgt x5, x10, getAtMost_left
    blt x5, x10, getAtMost_right

    ld x5, 0(sp)
    addi sp, sp, 8
    
    lw x10, val(x11)

    ret

return_negative1:
    li x10, -1

    ret
    
getAtMost_left:
    ld x5, 0(sp)
    addi sp, sp, 8

    ld x11, left(x11)
    beq x0, x0, getAtMost

getAtMost_right:
    addi sp, sp, -16
    sd x1, 8(sp)
    sd x11, 0(sp)
    
    ld x11, right(x11)
    call getAtMost

    ld x5, 0(sp)
    lw x11, val(x5)
    call maxm


    ld x1, 8(sp)
    addi sp, sp, 16

    ld x5, 0(sp)
    addi sp, sp, 8

    ret