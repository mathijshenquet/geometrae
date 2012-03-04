<?php
/**
 * Global registration and settings
 */

function s($str, $default=null){
	$path = explode(".", $str);

	$cursor = g('config');
	foreach($path as $part){
		if(!isset($cursor[$part])){
			if(is_null($default)){
				#print_r($part);
				throw new Exception("Cannot access setting ".$str);
			}
			return $default;
		}
		$cursor = $cursor[$part];
	}
	return $cursor;
}

function &g($key, $value=null){
	static $values = array();

	if(!is_null($value)){
		if(isset($values[$key])){
			throw new Exception("Cannot re-set g('assets')lobal value `".$key."'");
		}

		$values[$key] = $value;
	}

	return $values[$key];
}

g('config', array('~'), true);