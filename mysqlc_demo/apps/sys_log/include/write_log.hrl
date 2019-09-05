-define(WRITE_JSON(LogFile, Json), sys_log:write_json(?MODULE, ?LINE, LogFile, Json)).
-define(WRITE_LOG(LogFile, Json), sys_log:write_line(?MODULE, ?LINE, LogFile, Json)).

