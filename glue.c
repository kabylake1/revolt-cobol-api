#include<stddef.h>
#include<stdio.h>
#include<stdlib.h>
static size_t pos_p = 0;
void cob_output_refill(void) {
    pos_p = 0;
}
size_t cob_output_fill_glue(const char *restrict a_src, size_t size, size_t nmemb, char *restrict a_dest) {
    size_t i;
    for(i = 0; i < size * nmemb; ++i)
        a_dest[i + pos_p] = a_src[i];
    pos_p += size * nmemb;
    return size * nmemb;
}
void cob_verify_c_str(const char *s, int len) {
    printf("STRING: \"%s\" @ %p, LEN=%i\n", s, s, len);
    for(; *s != '\0'; ++s, --len);
    printf("STRING: \"%s\" @ %p, LEN=%i\n", s, s, len);
    if(len <= 1) abort();
}
