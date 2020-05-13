-module(prime).
-export([load/0, findPrime/1]).
 
load() ->
        erlang:load_nif("./cprime", 0).
 
findPrime(N) ->
        io:format("this function is not defined!~n").
% ————————————————
% 版权声明：本文为CSDN博主「keyeagle」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
% 原文链接：https://blog.csdn.net/keyeagle/java/article/details/7009208