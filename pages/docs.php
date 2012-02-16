<?php
$page = $_REQUEST['page'];

parent("./pages/template.php");
set('title', 'Docs');
require_once __DIR__.'/../site/markdown.php';

$file = __DIR__.'/../docs/'.$page.'.md';

if(!file_exists($file))
	$file = __DIR__.'/../docs/404.md';

ob_start();
require $file;
$md = ob_get_clean();

$md = preg_replace_callback("`\(@(.*?)\)`", function($matches){ return "(".link_to('docs', array('page' => $matches[1])).")"; }, $md)

?>

<div class="wrapper">
	<?= Markdown($md) ?>
</div>