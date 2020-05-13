#include "test_so.h"
int test_so_func(int a,int b)
{
    return a*b;
}

// gcc -shared ./test_so.c -o test_so.so