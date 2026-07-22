#ifndef SAKANA_H
#define SAKANA_H

typedef unsigned int uint;

#define SKN_UNUSED(variable) ((void)variable)
#define UNUSED SKN_UNUSED

void skn_unreachable(const char *file, int line);
#define SKN_UNREACHABLE() skn_unreachable(__FILE__, __LINE__);
#define UNREACHABLE SKN_UNREACHABLE

char *skn_read_file_alloc(const char *filename);
#define read_file_alloc skn_read_file_alloc

#endif // SAKANA_H
