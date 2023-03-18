#define COB_KEYWORD_INLINE __inline
#include<stddef.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdint.h>
#include<libwebsockets.h>
#include<gmp.h>
#include<libcob.h>
#define STATIC_ASSERT(expr) static int a[(expr) ? 1 : -1]
STATIC_ASSERT(sizeof(int) == sizeof(uint32_t));
STATIC_ASSERT(sizeof(void *) == sizeof(uint64_t));
STATIC_ASSERT(sizeof(size_t) == sizeof(uint64_t));
STATIC_ASSERT(sizeof(long) == sizeof(uint64_t));
STATIC_ASSERT(sizeof(long long) == sizeof(uint64_t));
STATIC_ASSERT(sizeof(size_t) == sizeof(void *));
static size_t pos_p = 0;
void cob_output_refill(void) { pos_p = 0; }
size_t cob_output_fill_glue(const char a_src[const restrict], size_t size, size_t nmemb, char a_dest[const restrict]) {
    unsigned int i;
    for(i = 0; i < size * nmemb; ++i) a_dest[i + pos_p] = a_src[i];
    pos_p += size * nmemb;
    return size * nmemb;
}
void cob_verify_c_str(const char s[restrict], int len) {
    printf("Verify: \"%s\" @ %p, LEN=%i\n", s, s, len);
    for(; *s != '\0'; ++s, --len);
    printf("Twice: \"%s\" @ %p, LEN=%i\n", s, s, len);
    if(len <= 1) abort();
}
int cob_print(const char s[const restrict]) {
    return printf("%s", s ? s : "(null)")?0:1;
}
