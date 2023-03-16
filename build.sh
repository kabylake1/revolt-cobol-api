#!/bin/sh
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

cobc -Wall -Wextra -g -x -fstatic-call -static \
    program.cbl api.cbl glue.c \
    -o program \
    -ljson-c -lcurl || exit

valgrind ./program
