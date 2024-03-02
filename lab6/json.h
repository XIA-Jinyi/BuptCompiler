#ifndef JSON_H_
#define JSON_H_

#ifdef __cplusplus
#include <cstddef>
extern "C" {
#else
#include <stddef.h>
#endif

typedef enum {
    JSON_NULL,
    JSON_BOOLEAN,
    JSON_INTEGER,
    JSON_NUMBER,
    JSON_STRING,
    JSON_ARRAY,
    JSON_OBJECT
} JsonType;

typedef struct JsonValue JsonValue;

typedef struct {
    size_t size;
    size_t capacity;
    JsonValue *values;
} JsonArray;

typedef struct {
    char *key;
    JsonValue *value;
} JsonObjectMember;

typedef struct {
    size_t size;
    size_t capacity;
    JsonObjectMember *members;
} JsonObject;

typedef union {
    int boolean;
    long long integer;
    double number;
    char *string;
    JsonArray array;
    JsonObject object;
} JsonUnion;

struct JsonValue {
    JsonType type;
    JsonUnion value;
};

void json_print(JsonValue json);

#ifdef __cplusplus
}
#endif

#endif