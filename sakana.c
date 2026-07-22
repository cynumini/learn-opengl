#include "sakana.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

void skn_unreachable(const char *file, int line) {
    fprintf(stderr, "%s:%d: unreachable\n", file, line);
    abort();
}

char *skn_read_file_alloc(const char *filename) {
    FILE *file = fopen(filename, "r");
    assert(file != NULL);
    assert(fseek(file, 0, SEEK_END) == 0);
    size_t size = ftell(file);
    rewind(file);
    char *buffer = malloc(size + 1);
    assert(fread(buffer, 1, size, file) == size);
    fclose(file);
    buffer[size] = 0;
    return buffer;
}
