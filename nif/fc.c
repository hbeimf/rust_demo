#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <dlfcn.h>

#include "erl_nif.h"

void write_log(char *filename, char *buf, int len) 
{
	FILE *out;

	if((out = fopen(filename,"wb")) == NULL){
		return;
	}

	fwrite(buf,sizeof(char),len,out);
	fclose(out);
}

static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	char * pp = "hello world!";
	write_log("/erlang/log/nif_log.txt", pp, strlen(pp)); 

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


// extern "C" bool CreateFishControl(const char* filepath, int tableid);
// fc:create_fish_control("/erlang/create_fish_control_call.txt", 1).
static ERL_NIF_TERM create_fish_control(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{

	char filePath[4096];
	int tableId;

	if(!enif_get_string(env, argv[0], filePath, sizeof(filePath), ERL_NIF_LATIN1))
	{
		return enif_make_badarg(env);
	}   // if

	// log 参数 1日志 
	write_log("/erlang/log/create_fish_control_filePath.txt", filePath, strlen(filePath)); 

	if(!enif_get_int(env, argv[1], &tableId))
		return enif_make_badarg(env);

	// log 参数2日志 ==========================
	char str1[25];
	sprintf(str1,"%d",tableId);
	write_log("/erlang/log/create_fish_control_tableId.txt", str1, strlen(str1)); 

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(char *, int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "CreateFishControl");

	int result = (*fptr)(filePath, tableId);

	// log 返回结果记录日志 ==========================
	char str2[25];
	sprintf(str2,"%d",result);
	write_log("/erlang/log/create_fish_control_result.txt", str2, strlen(str2)); 

	res = enif_make_int(env, result);
	return res;

}


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
static ERL_NIF_TERM get_inner_data(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef char* (*FPTR)(int);

	handle = dlopen("./fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "GetInnerData");

	// int result = (*fptr)(filePath, tableId);
	char* result = (*fptr)(tableId);

	// res = enif_make_int(env, result);
	return res;
}
static ErlNifFunc nif_funcs[] =
{
	{"hello", 0, hello},
	// { "add" ,  2, add},
	{"create_fish_control", 2, create_fish_control},
	{"save_to_file", 1, save_to_file},
	{"save_and_release", 1, save_and_release},
	{"catch_fish", 4, catch_fish},
	{"set_difficulty", 3, set_difficulty},
	{"set_place_type", 2, set_place_type},
	{"chou_fang", 2, chou_fang},
	{"get_inner_data", 1, get_inner_data}
};

ERL_NIF_INIT(fc, nif_funcs,NULL,NULL,NULL,NULL)

// gcc -fPIC -shared -o fc.so fc.c -I /usr/local/erlang_18.3/lib/erlang/usr/include
// https://blog.csdn.net/vihbc/article/details/20390599
// https://github.com/basho/eleveldb/blob/3585ada6fd3c63ac006be6255e400b401dee872c/c_src/eleveldb.cc
// 672line