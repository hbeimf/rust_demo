run:
	php client.php

client:
	rm -rf ./msg
	thrift -r --gen php msg.thrift
	mv ./gen-php/msg ./
	rm -rf ./gen-php

# out:
# 	thrift -out xxx -r --gen php msg.thrift 
