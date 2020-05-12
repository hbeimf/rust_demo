-record(request, {
	from, 
    req_cmd,
    req_data
}).

-record(reply, {
	from, 
    reply_code,
    reply_data
}).
