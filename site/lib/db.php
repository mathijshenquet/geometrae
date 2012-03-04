<?php
class DB{
	static function insert($table, $data){
		foreach ($data as $field => $value)
			$fields[] = "`$field`";

		foreach ($data as $field => $value)
			$placeholders[] = ":$field";

		$query = "INSERT INTO `$table` (".implode(', ', $fields).") VALUES (".implode(', ', $placeholders).")";

		$stmt = g('db')->prepare($query);
		foreach ($data as $key => $value)
			$stmt->bindValue(":$key", $value);
		return $stmt;
	}

	static function update($table, $id, $data){
		foreach ($data as $field => $value)
			$updates[] = "`$field` = :$field";

		$query = "UPDATE `$table` SET ".implode(', ', $updates)." WHERE `id` = :id";

		$stmt = g('db')->prepare($query);
		$stmt->bindValue(':id', $id);
		foreach ($data as $field => $value)
			$stmt->bindValue(":$field", $value);
		return $stmt;
	}

	static function findBy($table, $field, $value){
		$stmt = g('db')->prepare("SELECT * FROM `$table` WHERE `$field` = :value");
		$stmt->bindValue(':value', $value);
		$stmt->execute();

		if($stmt->rowCount() != 1)
			return false;

		return $stmt;
	}
}