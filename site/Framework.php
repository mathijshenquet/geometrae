<?php
if( !defined( __DIR__ ) )define( __DIR__, dirname(__FILE__) );

require './site/lib/crypt.php';
require './site/lib/DB.php';

require './site/model/user.php';
require './site/model/group.php';

require './site/framework/core.php';

require './site/config.php';
require './site/routing.php';
require './site/asset_schemes.php';

require './site/framework/db.php';
require './site/framework/assets.php';
require './site/framework/routing.php';
require './site/framework/templating.php';
require './site/framework/session.php';

function handle($uri){
	$page = g('router')->match($uri);
	echo render($page);
}