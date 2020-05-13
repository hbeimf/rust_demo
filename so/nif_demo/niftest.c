#include "erl_nif.h"

static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
}

static ErlNifFunc nif_funcs[] =
{
	{"hello", 0, hello}
};

ERL_NIF_INIT(niftest, nif_funcs,NULL,NULL,NULL,NULL)

// https://blog.csdn.net/wqtn22/article/details/84254874
// gcc -fPIC -shared -o niftest.so niftest.c -I $ERL_ROOT/usr/include/
// /usr/local/erlang_18.3/lib/erlang/usr/include
// gcc -fPIC -shared -o niftest.so niftest.c -I /usr/local/erlang_18.3/lib/erlang/usr/include