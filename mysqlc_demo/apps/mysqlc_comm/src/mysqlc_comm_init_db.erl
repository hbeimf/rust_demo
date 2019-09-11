% mysqlc_comm_init_db.erl
-module(mysqlc_comm_init_db).
-compile(export_all).


% 初始化数据库，表
init_db(PoolConfig) ->
	% create_db(PoolConfig),
	% create_table(PoolConfig),
	
	ok.




table_list() -> 
	[table_test(), table_ci_sessions()].

table_test() ->
	<<"CREATE TABLE IF NOT EXISTS test ("
                  "  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,"
                  "  bl BLOB,"
                  "  tx TEXT NOT NULL," %% No default value
                  "  f FLOAT,"
                  "  d DOUBLE,"
                  "  dc DECIMAL(5,3),"
                  "  y YEAR,"
                  "  ti TIME,"
                  "  ts TIMESTAMP,"
                  "  da DATE,"
                  "  c CHAR(2)"
                  ") ENGINE=InnoDB">>.


table_ci_sessions() ->
	<<"CREATE TABLE IF NOT EXISTS `ci_sessions` (" 
	   " `session_id` VARCHAR(40) NOT NULL DEFAULT '0', "
	   " `peopleid` INT(11) NOT NULL, "
	   " `ip_address` VARCHAR(16) NOT NULL DEFAULT '0', "
	   " `user_agent` VARCHAR(50) NOT NULL, "
	   " `last_activity` INT(10) UNSIGNED NOT NULL DEFAULT '0', "
	   " `LEFT` INT(11) NOT NULL, "
	   " `name` VARCHAR(25) NOT NULL, "
	   " `status` TINYINT(4) NOT NULL DEFAULT '0' "
	") ENGINE=InnoDB DEFAULT CHARSET=utf8">>.

create_table(#{
            database := Database
	} = PoolConfig) ->


	Pid = connect_db(PoolConfig),	
	Database1 = glib:to_binary(Database),

	ok = mysql:query(Pid, <<"USE ", Database1/binary>>),

	TableList = table_list(),
	lists:foreach(fun(CreateTable) -> 
		mysql:query(Pid, CreateTable)
	end, TableList),

	close_db_conn(Pid),

	ok.


% mysqlc_comm_init_db:create_db(PoolConfig).
create_db(#{
            	database := Database
	} = PoolConfig) ->

	Pid = connect_db(PoolConfig),	
	Database1 = glib:to_binary(Database),
	ok = mysql:query(Pid, <<"CREATE DATABASE IF NOT EXISTS ", Database1/binary>>),

	close_db_conn(Pid),
	ok.

connect_db(#{
	host := Host, 
             port := Port, 
             user := User, 
             password := Password
	} = _PoolConfig) ->
    {ok, Pid} = mysql:start_link([{host, Host}, {port, glib:to_integer(Port)}, {user, User}, {password, Password},
                                  {log_warnings, false}]),
    Pid.

close_db_conn(Pid) ->
	mysql:stop(Pid).