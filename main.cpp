#include "parser.h"
#include <cstdlib>
#include <cstring>

int main(int argc, char **argv) {
    if (argc != 2) {
        exit(1);
    }
    FILE *fin = fopen(argv[1], "rb"), *fout = NULL, *ferr = NULL;
    if (!fin) {
        exit(1);
    }
    size_t len = strlen(argv[1]);
    if (!strcmp(argv[1] + len - 4, ".bpl")) {
        strcpy(argv[1] + len - 3, "out");
        fout = fopen(argv[1], "wb");
        ferr = fopen(argv[1], "wb");
    }
    if (!fout) {
        exit(1);
    }
    int retval = parse(fin, fout, fout);
    if (fin) {
        fclose(fin);
    }
    if (fout) {
        fclose(fout);
    }
    if (ferr) {
        fclose(ferr);
    }
    return retval;
}