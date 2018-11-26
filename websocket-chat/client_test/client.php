<?php

// csrf

// https://www.jianshu.com/p/2988ba405b3b?from=timeline&isappinstalled=0
class Test {
	private $_token = '';

	function run() {
		$this->adminLoginByName();
		// $this->hello();
		$this->refresh();
	}

	// http -f GET localhost:8088/auth/hello "Authorization:Bearer xxxxxxxxx"  "Content-Type: application/json"
	function hello() {
		// $url = 'localhost:8088/auth/auth/hello';
		$url = 'localhost:8088/api/admin/hello';

		$header = [];
		$header[] = "Content-Type: application/json";
		$header[] = "Authorization: Bearer " . $this->_token;

		$post_data = [];
		$res = $this->request_get_header($url, $header);

		// print_r($res);
		$arr = json_decode($res, true);
		print_r($arr);

	}

	function refresh() {
		$url = 'localhost:8088/api/admin/refresh_token';

		$header = [];
		$header[] = "Content-Type: application/json";
		$header[] = "Authorization: Bearer " . $this->_token;

		$post_data = [];
		$res = $this->request_get_header($url, $header);

		// print_r($res);
		$arr = json_decode($res, true);
		print_r($arr);

	}

	function adminLoginByName() {
		$url = 'localhost:8088/login';
		// username=admin password=admin
		$post_data['username'] = 'test';
		$post_data['password'] = 'test';

		$res = $this->request_post($url, $post_data);
		// print_r($res);
		$arr = json_decode($res, true);
		print_r($arr);

		$this->_token = $arr['token'];
	}

	function request_get_header($url = '', $header = []) {
		$postUrl = $url;
		$ch = curl_init(); //初始化curl
		curl_setopt($ch, CURLOPT_URL, $postUrl); //抓取指定网页
		curl_setopt($ch, CURLOPT_HEADER, 0); //设置header
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); //要求结果为字符串且输出到屏幕上
		// curl_setopt($ch, CURLOPT_POST, 1); //post提交方式

		curl_setopt($ch, CURLOPT_HTTPHEADER, $header);

		$data = curl_exec($ch); //运行curl
		curl_close($ch);

		return $data;
	}

	//https://www.cnblogs.com/ps-blog/p/6732448.html
	function request_post_header_and_data($url = '', $post_data = array(), $header = []) {
		if (empty($url) || empty($post_data)) {
			return false;
		}

		$o = "";
		foreach ($post_data as $k => $v) {
			$o .= "$k=" . urlencode($v) . "&";
		}
		$post_data = substr($o, 0, -1);

		$postUrl = $url;
		$curlPost = $post_data;
		$ch = curl_init(); //初始化curl
		curl_setopt($ch, CURLOPT_URL, $postUrl); //抓取指定网页
		curl_setopt($ch, CURLOPT_HEADER, 0); //设置header
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); //要求结果为字符串且输出到屏幕上
		curl_setopt($ch, CURLOPT_POST, 1); //post提交方式

		if (!empty($curlPost)) {
			curl_setopt($ch, CURLOPT_POSTFIELDS, $curlPost);
		}

		curl_setopt($ch, CURLOPT_HTTPHEADER, $header);

		$data = curl_exec($ch); //运行curl
		curl_close($ch);

		return $data;
	}

	//https://www.cnblogs.com/ps-blog/p/6732448.html
	function request_post($url = '', $post_data = array()) {
		if (empty($url) || empty($post_data)) {
			return false;
		}

		$o = "";
		foreach ($post_data as $k => $v) {
			$o .= "$k=" . urlencode($v) . "&";
		}
		$post_data = substr($o, 0, -1);

		$postUrl = $url;
		$curlPost = $post_data;
		$ch = curl_init(); //初始化curl
		curl_setopt($ch, CURLOPT_URL, $postUrl); //抓取指定网页
		curl_setopt($ch, CURLOPT_HEADER, 0); //设置header
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); //要求结果为字符串且输出到屏幕上
		curl_setopt($ch, CURLOPT_POST, 1); //post提交方式
		curl_setopt($ch, CURLOPT_POSTFIELDS, $curlPost);
		$data = curl_exec($ch); //运行curl
		curl_close($ch);

		return $data;
	}

}

$obj = new Test();
$obj->run();

?>