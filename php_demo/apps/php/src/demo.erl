% demo.erl
-module(demo).
-compile(export_all).

test() ->
    % ?assertEqual(0, ephp:main(["test/code/test_empty.php"])).
    Root = glib:root_dir(),
    PhpFile = lists:concat([Root, "php_code/test.php"]),
    ephp:main([PhpFile]),
    ok.