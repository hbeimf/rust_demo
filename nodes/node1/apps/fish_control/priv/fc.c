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
	// char * pp = "hello world!";
	// write_log("/erlang/log/nif_log.txt", pp, strlen(pp)); 

	return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
}

// extern "C" bool CreateFishControl(const char* filepath, int tableid);
// fc:create_fish_control("/erlang/create_fish_control_call.txt", 1).
static ERL_NIF_TERM create_fish_control(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{

	char filePath[4096];
	int tableId;

	if(!enif_get_string(env, argv[0], filePath, sizeof(filePath), ERL_NIF_LATIN1))
	{
		return enif_make_badarg(env);
	}

	// // log 参数 1日志 
	// write_log("/erlang/log/create_fish_control_filePath.txt", filePath, strlen(filePath)); 

	if(!enif_get_int(env, argv[1], &tableId))
		return enif_make_badarg(env);

	// // log 参数2日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/create_fish_control_tableId.txt", str1, strlen(str1)); 

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(char *, int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "CreateFishControl");

	int result = (*fptr)(filePath, tableId);

	// // log 返回结果记录日志 ==========================
	// char str2[25];
	// sprintf(str2,"%d",result);
	// write_log("/erlang/log/create_fish_control_result.txt", str2, strlen(str2)); 

	res = enif_make_int(env, result);
	return res;

}

//保存数据到文件
// extern "C" void SaveToFile(int tableid);
// fc:save_to_file(1).
static ERL_NIF_TERM save_to_file(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	// // log 参数1日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/save_to_file_tableId.txt", str1, strlen(str1)); 

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SaveToFile");

	(*fptr)(tableId);
	return res;
}

//保存数据到文件，并退出
// extern "C" void SaveAndRelease(int tableid);
// fc:save_and_release(1).
static ERL_NIF_TERM save_and_release(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	// // log 参数1日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/save_and_release_tableId.txt", str1, strlen(str1)); 

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SaveAndRelease");

	(*fptr)(tableId);

	return res;
}


//是否打中鱼的判定，who为玩家位置0-3，bulletCoin为子弹倍数，fishCoin为鱼的倍数
//真钱版bulletCoin=炮的倍数*10000 如：0.01块钱的炮 bulletCoin=0.01*10000
// extern "C" bool CatchFish(int tableid, int who,int bulletCoin,int fishCoin);
// fc:catch_fish(1, 2, 3, 4).
static ERL_NIF_TERM catch_fish(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int who;
	int bulletCoin;
	int fishCoin;

	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	// // log 参数1日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/save_and_release_tableId.txt", str1, strlen(str1)); 


	if(!enif_get_int(env, argv[1], &who))
		return enif_make_badarg(env);

	// // log 参数2日志 ==========================
	// char str2[25];
	// sprintf(str2,"%d",who);
	// write_log("/erlang/log/save_and_release_who.txt", str2, strlen(str2)); 

	if(!enif_get_int(env, argv[2], &bulletCoin))
		return enif_make_badarg(env);

	// // log 参数3日志 ==========================
	// char str3[25];
	// sprintf(str3,"%d", bulletCoin);
	// write_log("/erlang/log/save_and_release_bulletCoin.txt", str3, strlen(str3)); 

	if(!enif_get_int(env, argv[3], &fishCoin))
		return enif_make_badarg(env);

	// // log 参数4日志 ==========================
	// char str4[25];
	// sprintf(str4,"%d", fishCoin);
	// write_log("/erlang/log/save_and_release_fishCoin.txt", str4, strlen(str4)); 


	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int, int, int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "CatchFish");

	// int result = (*fptr)(filePath, tableId);
	int result = (*fptr)(tableId, who, bulletCoin, fishCoin);

	// // log 返回日志 ==========================
	// char str5[25];
	// sprintf(str5,"%d", result);
	// write_log("/erlang/log/save_and_release_result.txt", str5, strlen(str5)); 

	res = enif_make_int(env, result);
	return res;
}

//设置难度，level为档位0-3，dif为难度0-4
// extern "C" bool SetDifficulty(int tableid, int level, int dif);
// fc:set_difficulty(1, 2,3).
static ERL_NIF_TERM set_difficulty(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int level;
	int dif;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	// // log 参数1日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/set_difficulty_tableId.txt", str1, strlen(str1)); 


	if(!enif_get_int(env, argv[1], &level))
		return enif_make_badarg(env);

	// // log 参数2日志 ==========================
	// char str2[25];
	// sprintf(str2,"%d",level);
	// write_log("/erlang/log/set_difficulty_level.txt", str2, strlen(str2)); 


	if(!enif_get_int(env, argv[2], &dif))
		return enif_make_badarg(env);

	// // log 参数3日志 ==========================
	// char str3[25];
	// sprintf(str3,"%d",dif);
	// write_log("/erlang/log/set_difficulty_dif.txt", str3, strlen(str3)); 

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int, int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SetDifficulty");

	int result = (*fptr)(tableId, level, dif);

	// // log 返回日志 ==========================
	// char str5[25];
	// sprintf(str5,"%d", result);
	// write_log("/erlang/log/set_difficulty_result.txt", str5, strlen(str5)); 

	res = enif_make_int(env, result);
	return res;
}

// //设置场地类型(起伏)0：小起伏，1：中等起伏，2：大起伏
// extern "C" bool SetPlaceType(int tableid, int pt);
// fc:set_place_type(1, 2).
static ERL_NIF_TERM set_place_type(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int pt;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	// // log 参数1日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/set_place_type_tableId.txt", str1, strlen(str1)); 


	if(!enif_get_int(env, argv[1], &pt))
		return enif_make_badarg(env);

	// // log 参数2日志 ==========================
	// char str2[25];
	// sprintf(str2,"%d", pt);
	// write_log("/erlang/log/set_place_type_pt.txt", str2, strlen(str2)); 

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "SetPlaceType");

	int result = (*fptr)(tableId, pt);

	// // log 反回结果日志 ==========================
	// char str3[25];
	// sprintf(str3,"%d", result);
	// write_log("/erlang/log/set_place_type_result.txt", str3, strlen(str3)); 

	res = enif_make_int(env, result);
	return res;
}

// //抽放接口，coinNum为人民币，大于0表示放水coinNum元，小于0表示抽水
// extern "C" bool ChouFang(int tableid, int coinNum);
// fc:chou_fang(1, 2).
static ERL_NIF_TERM chou_fang(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	int coinNum;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	// // log 参数1日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/chou_fang_tableId.txt", str1, strlen(str1)); 

	if(!enif_get_int(env, argv[1], &coinNum))
		return enif_make_badarg(env);

	// // log 参数2日志 ==========================
	// char str2[25];
	// sprintf(str2,"%d",coinNum);
	// write_log("/erlang/log/chou_fang_coinNum.txt", str2, strlen(str2)); 

	ERL_NIF_TERM res = enif_make_int(env, 0);

	void* handle;
	typedef int (*FPTR)(int, int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "ChouFang");

	// int result = (*fptr)(filePath, tableId);
	int result = (*fptr)(tableId, coinNum);

	// // log 反回结果日志 ==========================
	// char str3[25];
	// sprintf(str3,"%d",result);
	// write_log("/erlang/log/chou_fang_result.txt", str3, strlen(str3)); 

	res = enif_make_int(env, result);
	return res;
}

//测试用，获取内部数据，用于显示
// extern "C" const char* GetInnerData(int tableid);
// fc:get_inner_data(1).
static ERL_NIF_TERM get_inner_data(ErlNifEnv *env, int argc, ERL_NIF_TERM argv[])
{
	int tableId;
	
	if(!enif_get_int(env, argv[0], &tableId))
		return enif_make_badarg(env);

	// // log 参数1日志 ==========================
	// char str1[25];
	// sprintf(str1,"%d",tableId);
	// write_log("/erlang/log/get_inner_data_tableId.txt", str1, strlen(str1)); 

	void* handle;
	typedef char* (*FPTR)(int);

	handle = dlopen("/lib/fishcontrol.so", 1);
	FPTR fptr = (FPTR)dlsym(handle, "GetInnerData");

	char* result = (*fptr)(tableId);

	// // log 返回结果日志 ==========================
	// write_log("/erlang/log/get_inner_data_result.txt", result, strlen(result)); 

	ERL_NIF_TERM res = enif_make_string(env, result, ERL_NIF_LATIN1);
	return res;
}
static ErlNifFunc nif_funcs[] =
{
	{"hello", 0, hello},
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

