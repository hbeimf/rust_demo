#include <dlfcn.h>

#include "erl_nif.h"

static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
}

// test_so_func
static ERL_NIF_TERM add(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int a;
	int b;
	if(!enif_get_int(env, argv[0], &a))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[1], &b))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int,int);

	handle = dlopen("./test_so.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "add");

	int result = (*fptr)(a,b);

	res = enif_make_int(env, result);
	return res;

}

static ErlNifFunc nif_funcs[] =
{
	{"hello", 0, hello},
	{ "add" ,  2, add}
};

ERL_NIF_INIT(nif_fun, nif_funcs,NULL,NULL,NULL,NULL)
