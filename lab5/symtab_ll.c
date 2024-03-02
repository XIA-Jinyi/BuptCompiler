#include "symtab.h"

/*
 * symbol table type, linked list impl
 */
struct symtab {
    entry entry;
    struct symtab *next;
};

// ************************************************************
//    Your implementation goes here
// ************************************************************

symtab *symtab_init(){
    symtab *self = malloc(sizeof(symtab));
    memset(self, '\0', sizeof(symtab));
    self->next = NULL;
    return self;
}

int symtab_insert(symtab *self, char *key, VAL_T value){
    symtab *ptr = self;
    while(ptr->next != NULL){
        if(strcmp(ptr->entry.key, key) == 0)
            return 0;
        ptr = ptr->next;
    }
    symtab *node = malloc(sizeof(symtab));
    memset(node, '\0', sizeof(symtab));
    entry_init(&node->entry, key, value);
    node->next = NULL;
    ptr->next = node;
    return 1;
}

VAL_T symtab_lookup(symtab *self, char *key){
    symtab *ptr = self;
    while(ptr != NULL){
        if(strcmp(ptr->entry.key, key) == 0)
            return ptr->entry.value;
        ptr = ptr->next;
    }
    return -1;
}

int symtab_remove(symtab *self, char *key){
    symtab *ptr = self, *tmp;
    while(ptr->next != NULL) {
        if(strcmp(ptr->next->entry.key, key) == 0){
            tmp = ptr->next;
            ptr->next = ptr->next->next;
            free(tmp);
            return 1;
        }
        ptr = ptr->next;
    }
    return 0;
}
