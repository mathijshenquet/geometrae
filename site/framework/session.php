<?php
session_start();

class Session{
	private $user;

	function __construct(){
		if(isset($_SESSION['user_id'])){
			$this->user = User::find($_SESSION['user_id']);
		}
	}

	function set($key, $value){
		$_SESSION[$key] = $value;
	}

	function get($key){
		if(isset($_SESSION[$key])){
			return $_SESSION[$key];
		}else if(isset($this->user->$key)){
			return $this->user->$key;
		}

		throw new Exception("Unknown session value ".$key);
	}

	function attachUser($user){
		$_SESSION['user_id'] = $user->getID();
		$this->user = $user;
	}

	function getUser(){
		return $this->user;
	}
}

g('session', new Session());