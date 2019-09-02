<?php
include 'vendor/autoload.php';

use Thrift\Protocol\TBinaryProtocol;
use Thrift\Transport\TBufferedTransport;
use Thrift\Transport\TSocket;

require_once dirname(__FILE__) . '/msg/MsgService.php';
require_once dirname(__FILE__) . '/msg/Types.php';

class ThriftClient {
	function CetDatabaseConfig($pool_id) {
		$msg = new \msg\DatabaseConfigReq(['pool_id' => $pool_id]);
		return $this->client->CetDatabaseConfig($msg);
	}

	function Select($pool_id, $sql) {
		$msg = new \msg\SelectReq(['pool_id' => $pool_id, 'sql' => $sql]);
		return $this->client->Select($msg);
	}

	function QuerySql($pool_id, $sql) {
		$msg = new \msg\QueryReq(['pool_id' => $pool_id, 'sql' => $sql]);
		return $this->client->QuerySql($msg);
	}

	function __construct() {
		$socket = new TSocket($this->_host, $this->_port);
		$this->transport = new TBufferedTransport($socket, 1024, 1024);
		$protocol = new TBinaryProtocol($this->transport);
		$this->client = new \msg\MsgServiceClient($protocol);
		$this->transport->open();
	}
	function __destruct() {
		$this->transport->close();
	}
	public $transport = null;
	public $client = null;
	private $_host = "localhost";
	private $_port = 9090;
}

$client = new ThriftClient();
$pool_id = 1;
$sql = "INSERT INTO `test` (`tx`) VALUES ('2')";
$r = $client->QuerySql($pool_id, $sql);
print_r($r);

$select = "select * from test order by id desc limit 3";
$r = $client->Select($pool_id, $select);
print_r($r);

echo "code: " . $r->code . "\n";
echo "msg: " . $r->msg . "\n";
echo "result: " . $r->result . "\n";

print_r(json_decode($r->result, true));

$config = $client->CetDatabaseConfig($pool_id);
print_r($config);

?>