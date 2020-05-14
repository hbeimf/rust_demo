all:
	gcc -shared ./test_so.c -o test_so.so
	gcc -fPIC -shared -o nif_fun.so nif_fun.c -I /usr/local/erlang_18.3/lib/erlang/usr/include
	
fc:
	rm -rf ./fc.so
	gcc -fPIC -shared -o fc.so fc.c -I /usr/local/erlang_18.3/lib/erlang/usr/include

push: 
	git add .
	git commit -m 'pu'
	git push

# // gcc -fPIC -shared -o fc.so fc.c -I /usr/local/erlang_18.3/lib/erlang/usr/include
# // https://blog.csdn.net/vihbc/article/details/20390599
# // https://github.com/basho/eleveldb/blob/3585ada6fd3c63ac006be6255e400b401dee872c/c_src/eleveldb.cc
# // 672line