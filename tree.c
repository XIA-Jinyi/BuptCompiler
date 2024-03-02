#include "tree.h"
#include <stdlib.h>
#include <string.h>
#define INDENT "  "

Node new_node(const char *type, size_t line_no, const char *property, Node child, Node sibling) {
    Node retval = calloc(1, sizeof(struct Head));
    retval->line_no = line_no;
    if (type) {
        retval->type = strdup(type);
    }
    if (property) {
        retval->property = strdup(property);
    }
    if (child) {
        retval->child = child;
    }
    if (sibling) {
        retval->sibling = sibling;
    }
    return retval;
}

void print_tree(FILE *restrict stream, Tree tree, size_t indent) {
    if (!tree) {
        return;
    }
    if (!tree->type) {
        print_tree(stream, tree->sibling, indent);
        return;
    }
    for (int i = 0; i < indent; i++) {
        fprintf(stream, INDENT);
    }
    printf("%s", tree->type);
    if (tree->child) {
        fprintf(stream, " (%lu)", tree->line_no);
    }
    else if (tree->property) {
        fprintf(stream, ": %s", tree->property);
    }
    putc('\n', stream);
    print_tree(stream, tree->child, indent + 1);
    print_tree(stream, tree->sibling, indent);
}

void empty_tree(Tree tree) {
    if (!tree) {
        return;
    }
    empty_tree(tree->child);
    empty_tree(tree->sibling);
    if (tree->type) {
        free(tree->type);
    }
    if (tree->property) {
        free(tree->property);
    }
    if (tree->child) {
        free(tree->child);
    }
    if (tree->sibling) {
        free(tree->sibling);
    }
}

#ifdef TREE_C_
#include <mcheck.h>
int main(int argc, char **argv, char **env) {
    mtrace();
    Tree tree = new_node(
        "Program", 1, NULL,
        new_node(
            "ExtDefList", 1, NULL,
            new_node(
                "ExtDef", 1, NULL,
                new_node(
                    "Specifier", 1, NULL,
                    new_node(
                        "TYPE", 1, "int", NULL, NULL),
                    new_node(
                        "FunDec", 1, NULL,
                        new_node(
                            "ID", 1, "test_1_r01", NULL,
                            new_node(
                                "LP", 1, NULL, NULL, 
                                new_node(
                                    "RP", 1, NULL, NULL,
                                    new_node(
                                        "SEMI", 1, NULL, NULL, NULL
                                    )
                                ))),
                        NULL)),
                NULL),
            NULL),
        NULL);
    print_tree(stdout, tree, 0);
    empty_tree(tree);
    free(tree);
    muntrace();
    return 0;
}
#endif
