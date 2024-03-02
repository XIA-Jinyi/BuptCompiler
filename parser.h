#ifndef PARSER_H_
#define PARSER_H_

#ifdef __cplusplus
#include <cstdio>
extern "C" {
#else
#include <stdio.h>
#endif

int parse(FILE *fin, FILE *fout, FILE *ferr);

#ifdef __cplusplus
}
#endif

#endif