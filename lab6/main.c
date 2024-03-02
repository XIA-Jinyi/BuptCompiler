#include <stdio.h>
#include <stdlib.h>
#include "json.h"

int main() {
    // Create a JSON object
    JsonValue json;
    json.type = JSON_OBJECT;
    json.value.object.size = 0;
    json.value.object.capacity = 10;
    // Allocate memory for members
    json.value.object.members = malloc(sizeof(JsonObjectMember) * json.value.object.capacity);
    // Add a member of type string
    json.value.object.members[json.value.object.size].key = "Name";
    json.value.object.members[json.value.object.size].value = malloc(sizeof(JsonValue));
    json.value.object.members[json.value.object.size].value->type = JSON_STRING;
    json.value.object.members[json.value.object.size].value->value.string = "Jinyi Xia";
    json.value.object.size++;
    // Add a member of type integer
    json.value.object.members[json.value.object.size].key = "Student ID";
    json.value.object.members[json.value.object.size].value = malloc(sizeof(JsonValue));
    json.value.object.members[json.value.object.size].value->type = JSON_INTEGER;
    json.value.object.members[json.value.object.size].value->value.integer = 2021212057;
    json.value.object.size++;
    // Add another member of type integer
    json.value.object.members[json.value.object.size].key = "Class";
    json.value.object.members[json.value.object.size].value = malloc(sizeof(JsonValue));
    json.value.object.members[json.value.object.size].value->type = JSON_INTEGER;
    json.value.object.members[json.value.object.size].value->value.integer = 2021211802;
    json.value.object.size++;
    // Print the JSON object
    json_print(json);
    puts("");
    return 0;
}
