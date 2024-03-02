#include "linked_list.h"

int main(void){
    node *head = linked_list_init();
    char *string;
    printf("%d\n", linked_list_size(head));
    linked_list_append(head, 1);
    linked_list_append(head, 3);
    linked_list_append(head, 7);
    string = linked_list_tostring(head);
    puts(string);
    linked_list_append(head, 101);
    string = linked_list_tostring(head);
    puts(string);
    printf("%d\n", linked_list_size(head));
    linked_list_free(head);
    return 0;
}
