.data
    _menu:    .asciz "1- Insert\n2- Delete\n3- Search\n4- Preorder\n"
    _menu1:   .asciz "5- Inorder\n6- Postorder\n7- Full tree\n"
    _menu2:   .asciz "8- Maximum\n9- Minimum\n0- Leave\n\n"

    _scanf_fmt:  .asciz "%d"
    _scanf_prompt: .asciz "Type a value: "

    _valueAlreadyExists_str: .asciz "This value is already on the tree\n"
    _valueNotExists:  .asciz "Value not found\n"
    _valueAtAddress:  .asciz "The value is at the address: %p\n"
    _maxOutput:  .asciz "The max value is: %d\n"
    _minOutput:  .asciz "The min value is: %d\n"
    _emptyTree:  .asciz "The tree is empty\n"
    _emptyTreeOps: .asciz "Just the insert operation is available\n"
    _newline: .asciz "\n"

    input_buf: .word 0     # buffer for scanf

.global main
.text

main:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)      # save s0
    mv   s0, zero       # root = null

menu:
    j    printMenu

continue_menu:
    la   a0, _newline
    call printf
    j    menu

end_menu:
    lw   s0, 4(sp)      # restore s0 (loses tree reference)
    lw   ra, 0(sp)
    addi sp, sp, 8
    li   a0, 0
    call exit

printMenu:
    la   a0, _menu
    call printf
    la   a0, _menu1
    call printf
    la   a0, _menu2
    call printf

inputMenu:
    la   a0, _scanf_fmt
    la   a1, input_buf
    call scanf
    lw   a0, input_buf

    beqz a0, end_menu

    li   t6, 1
    beq  a0, t6, insert

    li   t6, 2
    beq  a0, t6, delete

    li   t6, 3
    beq  a0, t6, search

    li   t6, 4
    beq  a0, t6, pre

    li   t6, 5
    beq  a0, t6, in

    li   t6, 6
    beq  a0, t6, post

    li   t6, 7
    beq  a0, t6, arvoreToda

    li   t6, 8
    beq  a0, t6, max

    li   t6, 9
    beq  a0, t6, min
    j    continue_menu

inputValue:
    addi sp, sp, -4
    sw   ra, 0(sp)

    la   a0, _scanf_prompt
    call printf

    la   a0, _scanf_fmt
    la   a1, input_buf
    call scanf
    lw   a0, input_buf

    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

insert:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s1, 4(sp)

    jal  inputValue
    mv   s1, a0         # save value in s1

    mv   a0, s0
    mv   a1, s1
    jal  searchNode

    bnez a0, valueExists
    mv   a0, s0
    mv   a1, s1
    jal  insertNode
    mv   s0, a0
    j    end_insert_

valueExists:
    la   a0, _valueAlreadyExists_str
    call printf

end_insert_:
    lw   s1, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 8
    j    continue_menu

delete:
    addi sp, sp, -4
    sw   ra, 0(sp)

    jal  inputValue
    mv   a1, a0
    mv   a0, s0
    jal  deleteNode
    mv   s0, a0

    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

search:
    addi sp, sp, -4
    sw   ra, 0(sp)

    jal  inputValue
    mv   a1, a0
    mv   a0, s0
    jal  searchNode

    beqz a0, value_not_found
value_found:
    mv   a1, a0
    la   a0, _valueAtAddress
    call printf
    j    end_search

value_not_found:
    la   a0, _valueNotExists
    call printf

end_search:
    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

pre:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz s0, emptyTree
    mv   a0, s0
    jal  preorder
    la   a0, _newline
    call printf

    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

in:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz s0, emptyTree
    mv   a0, s0
    jal  inorder
    la   a0, _newline
    call printf

    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

post:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz s0, emptyTree
    mv   a0, s0
    jal  postorder
    la   a0, _newline
    call printf

    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

arvoreToda:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz s0, emptyTree
    mv   a0, s0
    li   a1, 0          # depth = 0
    li   a2, -1         # not left nor right
    li   a3, 1          # is root
    jal  printTree

    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

max:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz s0, emptyTree
    mv   a0, s0
    jal  findMax

    lw   a1, 0(a0)      # node->value
    la   a0, _maxOutput
    call printf

    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

min:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz s0, emptyTree
    mv   a0, s0
    jal  findMin

    lw   a1, 0(a0)      # node->value
    la   a0, _minOutput
    call printf

    lw   ra, 0(sp)
    addi sp, sp, 4
    j    continue_menu

emptyTree:
    la   a0, _emptyTree
    call printf
    la   a0, _emptyTreeOps
    call printf
    j    continue_menu
