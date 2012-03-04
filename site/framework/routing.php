<?php
/*
 * The Routing 
 */

class Router{
	private $matches;
	private $pages;
	private $generators;
	
	private $root;
	
	function __construct(){
		$this->matches 		= array();
		$this->targets 		= array();
		$this->generators 	= array();

		$this->root = s('server.router_root', '.');
		$routes = s('routing');
		foreach ($routes as $name => $route){
			$this->add($name, $route['route'], $route['page']);
		}
	}
	
	function link_to($name, $params){
		if(!isset($this->generators[$name])){
			trigger_error("Error: Non existant route");
		}
		
		$uri = $this->generators[$name];
		
		foreach($params as $key => $value){
			$uri = str_replace("[:".$key."]", $value, $uri);
		}
		
		return sprintf("%s%s", $this->root, trim($uri, '/'));
	}
	
	function add($name, $route, $page){	
		$this->matches[$name]    = $this->compile_matcher($route);
		$this->generators[$name] = $this->compile_generator($route);
		$this->pages[$name]		 = $page;
	}
	
	function match($uri){
		if(substr($uri, -1)=='/' && $uri != '/'){
			header('HTTP/1.1 301 Moved Permanently');
	  		header('Location: /'.trim($uri,'/'));
			exit();
	  	}
		
		$uri = "/".trim($uri, "/");

		foreach($this->matches as $page => $match){
			if(preg_match($match, $uri, $params)){
				foreach($params as $p => $value)
					if(!is_numeric($p))
						$_REQUEST[$p] = $value;

				return $this->pages[$page];
			}
		}
		
		return './pages/404.php';
	}
	
	//Compiles a route string to a regular expression
	function compile_matcher($route) {
	    if (preg_match_all('`(/|\.|)\[([^:\]]*+)(?::([^:\]]*+))?\](\?|)`', $route, $matches, PREG_SET_ORDER)) {
	        $match_types = array(
	            'i'  => '[0-9]++',
	            'a'  => '[0-9A-Za-z]++',
	            'h'  => '[0-9A-Fa-f]++',
	            '*'  => '.+?',
	            '**' => '.++',
	            ''   => '[^/]++'
	        );
	        foreach ($matches as $match) {
	            list($block, $pre, $type, $param, $optional) = $match;
	
	            if (isset($match_types[$type])) {
	                $type = $match_types[$type];
	            }
	            if ($pre === '.') {
	                $pre = '\.';
	            }
	            //Older versions of PCRE require the 'P' in (?P<named>)
	            $pattern = '(?:'
	                     . ($pre !== '' ? $pre : null)
	                     . '('
	                     . ($param !== '' ? "?P<$param>" : null)
	                     . $type
	                     . '))'
	                     . ($optional !== '' ? '?' : null);
	
	            $route = str_replace($block, $pattern, $route);
	        }
	    }
	    return "`^$route$`";
	}

	function compile_generator($route) {
		return preg_replace("`\[.*?:`", "[:", $route);
	}
}

g('router', new Router());