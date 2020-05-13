#include "test_so.h"
int add(int a,int b)
{
    return a+b;
}

// gcc -shared ./test_so.c -o test_so.so