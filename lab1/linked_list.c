#include "linked_list.h"

node *linked_list_init() {
    node *head = (node *)malloc(sizeof(node));
    head->count = 0;
    head->next = NULL;
    return head;
}

void linked_list_free(node *head) {
    node *cur = head;
    node *last;
    while (cur != NULL) {
        last = cur;
        cur = cur->next;
        free(last);
    }
}

char linked_list_string[0x10000];

char *linked_list_tostring(node *head) {
    node *cur = head->next;
    char *position;
    int length = 0;
    while (cur != NULL) {
        position = linked_list_string + length;
        length += sprintf(position, "%d", cur->value);
        cur = cur->next;
        if (cur != NULL) {
            position = linked_list_string + length;
            length += sprintf(position, "->");
        }
    }
    position = linked_list_string + length;
    length += sprintf(position, "%c", '\0');
    return linked_list_string;
}

int linked_list_size(node *head) {
    return head->count;
}

void linked_list_append(node *head, int val) {
    node *cur = head;
    node *new_node;
    while (cur->next != NULL) {
        cur = cur->next;
    }
    new_node = (node *)malloc(sizeof(node));
    new_node->value = val;
    new_node->next = NULL;
    cur->next = new_node;
    head->count++;
}

/* your implementation goes here */

void linked_list_insert(node *head, int val, int index) {
    if (index < 0 || index > head->count) {
        return;
    }
    node *new_node = (node *)malloc(sizeof(node)), *pos = head, *next;
    new_node->value = val;
    for (int i = 0; i < index; i++) {
        pos = pos->next;
    }
    next = pos->next;
    pos->next = new_node;
    new_node->next = next;
    head->count++;
}

void linked_list_delete(node *head, int index) {
    node *pos = head, *next;
    if (index < 0 || index >= head->count) {
        return;
    }
    for (int i = 0; i < index; i++) {
        pos = pos->next;
    }
    next = pos->next->next;
    free(pos->next);
    pos->next = next;
    head->count--;
}

void linked_list_remove(node *head, int val) {
    node *pos = head, *next;
    while (pos->next) {
        if (pos->next->value == val) {
            next = pos->next->next;
            free(pos->next);
            pos->next = next;
            head->count--;
            return;
        }
        pos = pos->next;
    }
}

void linked_list_remove_all(node *head, int val) {
    node *pos = head, *next;
    while (pos->next) {
        if (pos->next->value == val) {
            next = pos->next->next;
            free(pos->next);
            pos->next = next;
            head->count--;
        } else {
            pos = pos->next;
        }
    }
}

int linked_list_get(node *head, int index) {
    if (index < 0 || index >= head->count) {
        return -0x80000000;
    }
    for (int i = 0; i < index; i++) {
        head = head->next;
    }
    return head->next->value;
}

int linked_list_search(node *head, int val) {
    int index = 0;
    while (head->next) {
        if (head->next->value == val) {
            return index;
        }
        head = head->next;
        index++;
    }
    return -1;
}

node *linked_list_search_all(node *head, int val) {
    node *new_head = linked_list_init();
    node *cur = new_head;
    int index = 0;
    while (head->next) {
        if (head->next->value == val) {
            cur->next = (node *)malloc(sizeof(node));
            cur = cur->next;
            cur->value = index;
            cur->next = NULL;
        }
        head = head->next;
        index++;
    }
    return new_head;
}
