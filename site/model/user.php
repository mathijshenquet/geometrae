<?php
class User{
	const table = "users";

	static function find($id){
		return User::findBy('id', $id);
	}

	static function findBy($field, $value){
		if($stmt = DB::findBy(self::table, $field, $value)){
			$object = new User();
			$stmt->setFetchMode( PDO::FETCH_ASSOC);
			$object->fromDB($stmt->fetch());
			return $object;
		}else{
			return false;
		}
	}

	function fromDB($array){
		$this->id 			= $array['id'];
		$this->username 	= $array['username'];
		$this->password 	= $array['password'];
		$this->email 		= $array['email'];
		$this->group 		= Group::find($array['group_id']);
		$this->permissions	= $this->group->permissions;
	}

	function toDB(){
		return array(
			'username' 	=> $this->username,
			'password' 	=> $this->password,
			'email' 	=> $this->email,
			'group_id' 	=> $this->group ? $this->group->getID() : null
		);
	}

	function persist(){
		if (!$this->id):
			$stmt = DB::insert(self::table, $this->toDB());
			$stmt->execute();
			$this->id = g('db')->lastInsertId();
		else:
			$stmt = DB::update(self::table, $this->id, $this->toDB());
			$stmt->execute();
		endif;
	}

	private $id;

	public $username;
	public $password;
	public $email;
	public $group;

	private $permissions;

	function __constructor(){
	}

	function getID(){
		return $this->id;
	}

	function is($prop){
		return in_array($prop, $this->permissions, true) or in_array($prop, self::$default);
	}

	function encryptPassword($raw){
		$this->password = _mthq_crypt($raw, s('db.salt'));
	}

	function checkPassword($raw){
		return $this->password == _mthq_crypt($raw, s('db.salt'));
	}
}