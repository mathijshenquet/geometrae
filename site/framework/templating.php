<?php
function parent($parent=null){
	static $parents = array();
	
	if($parent === null){
		return array_pop($parents);
	}else{
		array_push($parents, $parent);
	}
}

function content($content=null){
	static $contents = array();
	
	if($content === null){
		return array_pop($contents);
	}else{
		array_push($contents, $content);
	}
}

function render($page, $scope=array()){
	foreach ($scope as $key => $value){
		$$key = $value;
	}

	while ($page != false) {
		ob_start();
		parent(false);
		include $page;
		$page = parent();
		content(ob_get_clean());
	}
	
	return content();
}

/**
 * Asset helpers
 */

function asset($lvl, $type, $href){
	g('assets')->add($lvl, $type, $href);
}

function render_assets_until($n){
	g('assets')->render(true, $n);
}

function render_assets_from($n){
	g('assets')->render($n, true);
}

function render_assets($low=true, $high=true){
	g('assets')->render($low, $high);
}

function render_assets_range($low, $high){
	g('assets')->render($low, $high);
}

/**
 *	Router helpers
 */

function link_to($name, $params=array()){
	return g('router')->link_to($name, $params);
}

/**
 * Template variables
 */

function set($key, $value){
	$template_vars = g('template_vars');
	$prev = get($key);
	$template_vars[$key] = sprintf($value, $prev);
}
	
function get($key, $default=""){
	$template_vars = g('template_vars');
	$value = $default;
	if(has($key)){
		$value = $template_vars[$key];
	}
	return $value;
}

function has($key){
	$template_vars = g('template_vars');
	return isset($template_vars[$key]);
}

g('template_vars', array());