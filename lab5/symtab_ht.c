#include "symtab.h"

/*
 * symbol table type, hash table (close addressing) impl
 */
#define TABLE_SIZE 0x1003
struct _node {
    entry entry;
    struct _node *next;
};
typedef struct _node *symtab[TABLE_SIZE];

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
