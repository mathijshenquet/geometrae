<?php
class Site{
	private static $instance;
	
	public $router;
	public $assets;
	public $variables;
	
	public function __construct(){
		$this->router = new Router;
		$this->assets = new Assets;
		$this->variables = new Variables;
	}
	
	static function get(){
		if (!isset(self::$instance)) {
            self::$instance = new Site();
        }
		return self::$instance;
	}
}

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

function render($page){
	while ($page != false) {
		ob_start();
		parent(false);
		include $page;
		$page = parent();
		content(ob_get_clean());
	}
	
	return content();
}

function handle($uri){
	$page = Site::get()->router->match($uri);
	echo render($page);
}

/**
 * Vars
 */

function set($key, $value){
	Site::get()->variables->set($key, $value);
}

function get($key, $default=""){
	return Site::get()->variables->get($key, $default);
}

function has($key){
	return Site::get()->variables->has($key);
}
 
class Variables{
	private $hash;
	
	public function __construct(){
		$this->hash = array();
	}
	
	public function set($key, $value){
		$prev = $this->get($key);
		$this->hash[$key] = sprintf($value, $prev);
	}
	
	public function get($key, $default=""){
		$value = $default;
		if($this->has($key)){
			$value = $this->hash[$key];
		}
		return $value;
	}
	
	public function has($key){
		return isset($this->hash[$key]);
	}
}

/*
 * The assets
 */

function asset_root($root){
	Site::get()->assets->set_root($root);
}
 
function register_asset($type, $format){
	Site::get()->assets->register_type($type, $format);
}

function asset($lvl, $type, $href){
	Site::get()->assets->add($lvl, $type, $href);
}

function render_assets_until($n){
	Site::get()->assets->render(true, $n);
}

function render_assets_from($n){
	Site::get()->assets->render($n, true);
}

function render_assets(){
	Site::get()->assets->render(true, true);
}

function render_assets_range($low, $high){
	Site::get()->assets->render($low, $high);
}

class Assets{
	private $assets;
	private $types;
	private $root;
	
	function __construct(){
		$this->assets = array();
		$this->types = array();
		$this->root = ".";
	}
	
	function set_root($root){
		$this->root = $root;
	}
	
	function register_type($type, $format){
		$this->types[$type] = $format;
	}
	
	function add($lvl, $type, $href){
		if(!isset($this->assets[$lvl])){
			$this->assets[$lvl] = array();
		}
		if(!isset($this->assets[$lvl][$type])){
			$this->assets[$lvl][$type] = array();
		}
		
		$this->assets[$lvl][$type][] = $href;
	}
	
	function render($low, $high){
		ksort($this->assets);
		
		$rendered = array();
		
		foreach ($this->assets as $lvl => $asset_lvl){
			//Render de asset alleen als het asset_lvl binnen de aangegeven range valt.
			if(!(($low === true or $low <= $lvl) && ($high === true or $lvl < $high))){ #TODO Misschien herschrijven om die !(...) weg te halen
				continue; //Ander skip hem maar
			}
			
			foreach ($asset_lvl as $type => $assets)
				foreach ($assets as $asset){
					if(isset($rendered[$asset])){
						continue;
					}
					$rendered[$asset] = true;
					
					$relative_url = preg_match("#^/#", $asset) == 1;
					
					if ($relative_url) {
						$url = sprintf("%s%s", $this->root, trim($asset, "/"));
					}else{
						$url = $asset;
					}
					
					echo sprintf($this->types[$type], $url) . "\n";
				}
		}
	}
}

/*
 * The Routing 
 */

function controller_root($root){
	Site::get()->router->set_root($root);
} 

function link_to($name, $params=array()){
	return Site::get()->router->link_to($name, $params);
} 

function route($name, $route, $page){
	Site::get()->router->add($name, $route, $page);
}

function routes($routes){
	foreach ($routes as $name => $ar) {
		Site::get()->router->add($name, $ar['route'], $ar['page']);
	}
}

class Router{
	private $matches;
	private $pages;
	private $generators;
	
	private $root;
	
	function __construct(){
		$this->matches = array();
		$this->targets = array();
		$this->root = ".";
	}
	
	function set_root($root){
		$this->root = $root;
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