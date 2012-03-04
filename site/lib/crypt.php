<?php
function _mthq_crypt($value, $salt, $times=10000){
	for($i=0; $i<$times; $i++){
		$value = hash('sha512', $value.$salt);
	}

	return $salt."$".$value;
}