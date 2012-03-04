<?php
/*
 * The assets
 */

class Assets{
	private $assets;
	private $schemes;
	private $root;
	
	function __construct(){
		$this->root = s('server.asset_root', '.');
		$this->schemes = s('asset_schemes');

		$this->assets = array();
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
					
					echo sprintf($this->schemes[$type], $url) . "\n";
				}
		}
	}
}

g('assets', new Assets());