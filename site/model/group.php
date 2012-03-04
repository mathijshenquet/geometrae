<?php
class Group{
	const table = 'group';

	static function find($id){
		return Group::findBy('id', $id);
	}

	static function findBy($field, $value){
		if($stmt = DB::findBy(self::table, $field, $value)){
			$object = new Group();
			$stmt->setFetchMode(PDO::FETCH_ASSOC);
			$object->fromDB($stmt->fetch());
			return $object;
		}else{
			return false;
		}
	}

	function fromDB($array){
		$this->id 			= $array['id'];
		$this->name 		= $array['name'];
		$this->permissions 	= json_decode($array['permissions']);
	}

	function toDB(){
		return array(
			'name' 			=> $this->name,
			'permissions' 	=> json_encode($this->permissions)
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

	public $name;
	public $permissions;

	function __construct(){
	}

	function getID(){
		return $this->id;
	}
}