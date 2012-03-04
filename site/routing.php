<?php
$config = &g('config');

$config['routing'] = array(
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
		'page' 		=> "./pages/session/@Login.php"
	),
	"logout"		=> array(
		'route'		=> "/logout",
		'page'		=> "./pages/session/logout.php"
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
	),
	"password_recovery" => array(
		'route'		=> '/lost-password',
		'page'		=> './pages/404.php'
	)
);