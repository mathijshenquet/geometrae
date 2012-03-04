<?php
$page = $_REQUEST['page'];

parent("./pages/template.php");
set('title', 'Docs');
require_once __DIR__.'/../site/lib/markdown.php';

$file = __DIR__.'/../docs/'.$page.'.md';

if(!file_exists($file))
	$file = __DIR__.'/../docs/404.md';

ob_start();
require $file;
$md = ob_get_clean();

function f($matches){ return "(".link_to('docs', array('page' => $matches[1])).")"; }

$md = preg_replace_callback("`\(@(.*?)\)`", 'f', $md);

?>

<div class="wrapper">
	<?= Markdown($md) ?>
</div>