.global insertNode
.global searchNode
.global deleteNode
.global findMax
.global findMin
.global printTree
.global preorder
.global inorder
.global postorder

.data
    .P1: .asciz "├── "
    .P2: .asciz "└── "
    fmt_int:   .asciz "%d "
    fmt_newline: .asciz "\n"

.text

createNode:
    # a1 = value to insert
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a1, 4(sp)      # save value (malloc may clobber a1)

    li   a0, 12         # malloc(12)
    call malloc

    lw   a1, 4(sp)      # restore value
    sw   a1, 0(a0)      # node->value = a1
    sw   zero, 4(a0)    # node->left  = null
    sw   zero, 8(a0)    # node->right = null

    lw   ra, 0(sp)
    addi sp, sp, 8
    jr   ra

insertNode:
    # a0 = node, a1 = value to insert
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)

    beqz a0, first_node
    lw   t0, 0(a0)      # t0 = node->val

    bge  a1, t0, right_insert
left_insert:
    lw   a0, 4(a0)
    jal  insertNode
    lw   t1, 4(sp)
    sw   a0, 4(t1)
    j    end_insert
right_insert:
    lw   a0, 8(a0)
    jal  insertNode
    lw   t1, 4(sp)
    sw   a0, 8(t1)
    j    end_insert
first_node:
    jal  createNode

end_insert:
    lw   t1, 4(sp)
    beqz t1, return_insert
    mv   a0, t1
return_insert:
    lw   ra, 0(sp)
    addi sp, sp, 8
    jr   ra

deleteNode:
    # a0 = node, a1 = value to delete
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)

    beqz a0, return_delete  # root null

    lw   t0, 0(a0)          # node->val
    blt  a1, t0, delete_left
    bgt  a1, t0, delete_right

    # found the node
    lw   t1, 4(a0)          # left
    lw   t2, 8(a0)          # right

    # case 1: leaf
    bnez t1, has_left
    bnez t2, has_right
    li   a0, 0
    j    return_delete

has_right:
    beqz t1, just_right_child
has_left:
    beqz t2, just_left_child

both_childs:
    lw   t3, 8(a0)          # t3 = right subtree
find_min:
    lw   t4, 4(t3)
    beqz t4, min_found
    mv   t3, t4
    j    find_min
min_found:
    lw   t4, 0(t3)          # t4 = successor value
    lw   t5, 4(sp)
    sw   t4, 0(t5)          # replace value with successor

    lw   a0, 8(t5)
    mv   a1, t4
    jal  deleteNode
    lw   t5, 4(sp)
    sw   a0, 8(t5)
    mv   a0, t5
    j    return_delete

just_right_child:
    mv   a0, t2
    j    return_delete

just_left_child:
    mv   a0, t1
    j    return_delete

delete_left:
    lw   a0, 4(a0)
    jal  deleteNode
    lw   t1, 4(sp)
    sw   a0, 4(t1)
    mv   a0, t1
    j    return_delete

delete_right:
    lw   a0, 8(a0)
    jal  deleteNode
    lw   t1, 4(sp)
    sw   a0, 8(t1)
    mv   a0, t1

return_delete:
    lw   ra, 0(sp)
    addi sp, sp, 8
    jr   ra

searchNode:
    # a0 = root, a1 = value to search
    # returns: a0 = node address or 0
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz a0, return_search
    lw   t0, 0(a0)
    beq  a1, t0, return_search

    bgt  a1, t0, search_right
search_left:
    lw   a0, 4(a0)
    j    search_next
search_right:
    lw   a0, 8(a0)
search_next:
    jal  searchNode
return_search:
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

findMax:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz a0, end_findMax
    lw   t0, 8(a0)
    beqz t0, end_findMax

    mv   a0, t0
    jal  findMax
end_findMax:
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

findMin:
    addi sp, sp, -4
    sw   ra, 0(sp)

    beqz a0, end_findMin
    lw   t0, 4(a0)
    beqz t0, end_findMin

    mv   a0, t0
    jal  findMin
end_findMin:
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

print_node:
    # a0 = node address
    beqz a0, return_print_node

    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)

    lw   a1, 0(a0)      # a1 = node->value
    la   a0, fmt_int
    call printf         # printf("%d ", value)

    lw   a0, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 8

return_print_node:
    jr   ra

printTree:
    # a0=node, a1=depth, a2=left/right, a3=isRoot
    addi sp, sp, -12
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)

    beqz a0, printTree_ret
    beqz a3, not_root

    jal  print_node
    la   a0, fmt_newline
    call printf
    j    printTree_nextNodes

not_root:
    mv   t0, a0
    li   t2, 0
    mv   t3, a1

print_spaces:
    beq  t2, t3, end_print_spaces
    li   a0, 32
    call putchar
    li   a0, 32
    call putchar
    li   a0, 32
    call putchar
    addi t2, t2, 1
    j    print_spaces
end_print_spaces:

    bnez a2, print_P2
print_P1:
    la   a0, .P1
    call printf
    j    post_Ps
print_P2:
    la   a0, .P2
    call printf

post_Ps:
    mv   a0, t0
    jal  print_node
    la   a0, fmt_newline
    call printf

printTree_nextNodes:
    lw   a0, 4(sp)
    lw   a1, 8(sp)
    addi a1, a1, 1
    li   a2, 0
    li   a3, 0
    lw   a0, 4(a0)      # node->left
    jal  printTree

    lw   a0, 4(sp)
    lw   a1, 8(sp)
    addi a1, a1, 1
    li   a2, 1
    li   a3, 0
    lw   a0, 8(a0)      # node->right
    jal  printTree

printTree_ret:
    lw   ra, 0(sp)
    lw   a0, 4(sp)
    lw   a1, 8(sp)
    addi sp, sp, 12
    jr   ra

preorder:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)

    beqz a0, return_pre
    jal  print_node

    lw   a0, 4(sp)
    lw   a0, 4(a0)
    jal  preorder

    lw   a0, 4(sp)
    lw   a0, 8(a0)
    jal  preorder

return_pre:
    lw   ra, 0(sp)
    lw   a0, 4(sp)
    addi sp, sp, 8
    jr   ra

inorder:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)

    beqz a0, return_in

    lw   a0, 4(sp)
    lw   a0, 4(a0)
    jal  inorder

    lw   a0, 4(sp)
    jal  print_node

    lw   a0, 4(sp)
    lw   a0, 8(a0)
    jal  inorder

return_in:
    lw   ra, 0(sp)
    lw   a0, 4(sp)
    addi sp, sp, 8
    jr   ra

postorder:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   a0, 4(sp)

    beqz a0, return_post

    lw   a0, 4(sp)
    lw   a0, 4(a0)
    jal  postorder

    lw   a0, 4(sp)
    lw   a0, 8(a0)
    jal  postorder

    lw   a0, 4(sp)
    jal  print_node

return_post:
    lw   ra, 0(sp)
    lw   a0, 4(sp)
    addi sp, sp, 8
    jr   ra
