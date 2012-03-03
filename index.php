<?php
require './site/Framework.php';

asset_root('/');
controller_root('/');

routes(array(
	"homepage"		=> array(
		'route'		=> '/',
		'page'		=> "./pages/home.php"
	),
	"sandbox"		=> array(
		'route'  	=> '/sandbox',
		'page' 		=> "./pages/sandbox.php"
	),
	"login"			=> array(
		'route'  	=> '/login',
		'page' 		=> "./pages/login.php"
	),
	"logout"		=> array(
		'route'		=> "/logout",
		'page'		=> "./pages/logout.php"
	),
	"settings"		=> array(
		'route'		=> "/settings",
		'page'		=> "./pages/settings.php"
	),
	"dashboard"		=> array(
		'route'		=> "/dashboard",
		'page'		=> "./pages/dashboard.php"
	),
	"docs"			=> array(
		'route'  	=> "/docs/[:page]",
		'page' 		=> "./pages/docs.php"
	),
	"qnum"			=> array(
		'route'		=> '/qnum',
		'page' 		=> './pages/test_qnum.php'
	),
	"chapters"		=> array(
		'route'		=> '/chapters',
		'page'		=> "./pages/chapters.php"
	),
	"exercise"		=> array( 
		'route'		=> '/exercise',
		'page'		=> "./pages/exercise.php"
	),
	"gdl"			=> array(
		'route'		=> '/gdl',
		'page'		=> './pages/gdl.php'
	)
));

register_asset("cf", "<script type=\"text/coffeescript\" src=\"%s\"></script>");
register_asset("js", "<script type=\"text/javascript\" src=\"%s\"></script>");
register_asset("less", "<link rel=\"stylesheet/less\" type=\"text/css\" href=\"%s\" />");
register_asset("css", "<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\" />");

register_asset("inline_cf", "<script type=\"text/coffeescript\">%s</script>");
register_asset("inline_js", "<script type=\"text/javascript\">%s</script>");
register_asset("inline_css", "<style type=\"text/css\">%s</style>");

handle($_GET['geometrae_page']);
?>