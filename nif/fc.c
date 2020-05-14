#include <dlfcn.h>

#include "erl_nif.h"

static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
}

// // test_so_func
// static ERL_NIF_TERM add(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
// {
// 	int a;
// 	int b;
// 	if(!enif_get_int(env, argv[0], &a))
// 		return enif_make_badarg(env);

// 	if(!enif_get_int(env, argv[1], &b))
// 		return enif_make_badarg(env);

// 	ERL_NIF_TERM res = enif_make_int(env, 0);

// 	void* handle;
// 	typedef int (*FPTR)(int,int);

// 	handle = dlopen("./test_so.so", 1);
// 	FPTR fptr = (FPTR)dlsym(handle, "add");

// 	int result = (*fptr)(a,b);

// 	res = enif_make_int(env, result);
// 	return res;

// }


// // % =====================================
// // % bool
// // create_fish_control(_FilePath_Char, _TableId_Int) ->
// // 	"NIF library not loaded".
// static ERL_NIF_TERM create_fish_control(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
// {
// 	int filePath;
// 	int tableId;
// 	if(!enif_get_string(env, argv[0], &filePath))
// 		return enif_make_badarg(env);

// 	if(!enif_get_int(env, argv[1], &tableId))
// 		return enif_make_badarg(env);

// 	ERL_NIF_TERM res = enif_make_int(env, 0);

// 	void* handle;
// 	typedef int (*FPTR)(char *, int);

// 	handle = dlopen("./fishcontrol.so", 1);
// 	FPTR fptr = (FPTR)dlsym(handle, "CreateFishControl");

// 	int result = (*fptr)(filePath, tableId);

// 	res = enif_make_int(env, result);
// 	return res;

// }


// % void
// save_to_file(_TableId_Int) -> 
// 	"NIF library not loaded".
static ERL_NIF_TERM save_to_file(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SaveToFile");

	// int result = (*fptr)(filePath, tableId);
	(*fptr)(tableId);

	// res = enif_make_int(env, result);
	return res;
}


// % void
// save_and_release(_TableId_Int) -> 
// 	"NIF library not loaded".
static ERL_NIF_TERM save_and_release(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SaveAndRelease");

	// int result = (*fptr)(filePath, tableId);
	(*fptr)(tableId);

	// res = enif_make_int(env, result);
	return res;
}


// % bool
// catch_fish(_TableId_Int, _Who_Int, _BulletCoin_Int, _FishCoin_Int) ->
// 	 "NIF library not loaded".
static ERL_NIF_TERM catch_fish(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int who;
	int bulletCoin;
	int fishCoin;

	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[1], &who))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[2], &bulletCoin))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[3], &fishCoin))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int, int, int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "CatchFish");

	// int result = (*fptr)(filePath, tableId);
	int result = (*fptr)(tableId, who, bulletCoin, fishCoin);

	// res = enif_make_int(env, result);
	return res;
}

// % bool
// set_difficulty(_TableId_Int, _Level_Int, _Fif_Int) -> 
// 	"NIF library not loaded".
static ERL_NIF_TERM set_difficulty(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int level;
	int dif;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[1], &level))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[2], &dif))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int, int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SetDifficulty");

	// int result = (*fptr)(filePath, tableId);
	int result = (*fptr)(tableId, level, dif);

	// res = enif_make_int(env, result);
	return res;
}

// % bool
// set_place_type(_TableId_Int, _Pt_Int) -> 
// 	"NIF library not loaded".
// //设置场地类型(起伏)0：小起伏，1：中等起伏，2：大起伏
// extern "C" bool SetPlaceType(int tableid, int pt);
static ERL_NIF_TERM set_place_type(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int pt;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[1], &pt))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SetPlaceType");

	// int result = (*fptr)(filePath, tableId);
	int result = (*fptr)(tableId, pt);

	// res = enif_make_int(env, result);
	return res;
}

// % bool
// chou_fang(_TableId_Int, _CoinNum_Int) -> 
// 	"NIF library not loaded".
// //抽放接口，coinNum为人民币，大于0表示放水coinNum元，小于0表示抽水
// extern "C" bool ChouFang(int tableid, int coinNum);
static ERL_NIF_TERM chou_fang(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int coinNum;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	if(!enif_get_int(env, argv[1], &coinNum))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "ChouFang");

	// int result = (*fptr)(filePath, tableId);
	int result = (*fptr)(tableId, coinNum);

	// res = enif_make_int(env, result);
	return res;
}
// //测试用，获取内部数据，用于显示
// extern "C" const char* GetInnerData(int tableid);
// % char
// get_inner_data(_TableId_Int) -> 
// 	"NIF library not loaded".

static ErlNifFunc nif_funcs[] =
{
	{"hello", 0, hello},
	// { "add" ,  2, add},
	// {"create_fish_control", 2, create_fish_control}
	{"save_to_file", 1, save_to_file},
	{"save_and_release", 1, save_and_release},
	{"catch_fish", 4, catch_fish},
	{"set_difficulty", 3, set_difficulty},
	{"set_place_type", 2, set_place_type},
	{"chou_fang", 2, chou_fang}
};

ERL_NIF_INIT(fc, nif_funcs,NULL,NULL,NULL,NULL)

// gcc -fPIC -shared -o fc.so fc.c -I /usr/local/erlang_18.3/lib/erlang/usr/include