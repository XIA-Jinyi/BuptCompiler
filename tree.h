#ifndef TREE_H_
#define TREE_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdio.h>

typedef struct Head {
    char *type;
    size_t line_no;
    char *property;
    struct Head *child, *sibling;
} *Node, *Tree;

Node new_node(const char *type, size_t line_no, const char *property, Node child, Node sibling);
void print_tree(FILE *restrict stream, Tree tree, size_t indent);
void empty_tree(Tree tree);

#ifdef __cplusplus
}
#endif

#endif
