#include "symtab.h"

/*
 * symbol table type, binary tree impl
 */
struct symtab {
    entry entry;
    struct symtab *left, *right;
};

// ************************************************************
//    Your implementation goes here
// ************************************************************

symtab *symtab_init(){

}

int symtab_insert(symtab *self, char *key, VAL_T value){

}

VAL_T symtab_lookup(symtab *self, char *key){

}

int symtab_remove(symtab *self, char *key){

}
