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

        ERL_NIF_TERM res = enif_make_list(env, 0);

        int r;
        r = a + b;
        res = enif_make_list_cell(env, enif_make_int(env, r), res);
        return res;

        // else
        // {
        //         int i;
        //         ERL_NIF_TERM res = enif_make_list(env, 0);
        //         for(i = 2; i < n; ++i)
        //         {
        //                 if(isPrime(i))
        //                         res = enif_make_list_cell(env, enif_make_int(env, i), res);
        //         }
        //         return res;
        // }
}

static ErlNifFunc nif_funcs[] =
{
	{"hello", 0, hello},
	{"add", 2, add}
};

ERL_NIF_INIT(nif_fun, nif_funcs,NULL,NULL,NULL,NULL)

// gcc -fPIC -shared -o nif_fun.so nif_fun.c -I /usr/local/erlang_18.3/lib/erlang/usr/include