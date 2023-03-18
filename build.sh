#!/bin/sh
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

cobc -O0 -Wall -Wextra --verbose -fbinary-size=1-2-4-8 -debug -g -x -fstatic-call -std=mvs -static -A -fsanitize=undefined -fnumeric-pointer \
    program.cbl api.cbl curl.cbl wsws.cbl glue.c \
    -o program \
    -ljson-c -lcurl -lwebsockets -lubsan || exit

valgrind ./program
