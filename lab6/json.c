#include "json.h"
#include <stdio.h>

void json_print(JsonValue json) {
    switch (json.type) {
        case JSON_NULL:
            printf("null");
            break;
        case JSON_BOOLEAN:
            printf(json.value.boolean ? "true" : "false");
            break;
        case JSON_INTEGER:
            printf("%lld", json.value.integer);
            break;
        case JSON_NUMBER:
            printf("%g", json.value.number);
            break;
        case JSON_STRING:
            printf("\"%s\"", json.value.string);
            break;
        case JSON_ARRAY:
            printf("[");
            for (size_t i = 0; i < json.value.array.size; i++) {
                if (i > 0) {
                    printf(", ");
                }
                json_print(json.value.array.values[i]);
            }
            printf("]");
            break;
        case JSON_OBJECT:
            printf("{");
            for (size_t i = 0; i < json.value.object.size; i++) {
                if (i > 0) {
                    printf(", ");
                }
                printf("\"%s\": ", json.value.object.members[i].key);
                json_print(*json.value.object.members[i].value);
            }
            printf("}");
            break;
        default:
            break;
    }
}