<!doctype html>
<meta charset="utf-8">
<title><?= get('title') ?></title>


<?php if(strpos($_SERVER['HTTP_USER_AGENT'],'iPad')): ?>
	<meta name="author" content="<?= get("author") ?>">
	<meta name="viewport" content="width = device-width, initial-scale = 1, user-scalable = no">
	<link rel="stylesheet" media="screen and (orientation: portrait)"  href="/web/css/ipad_portrait.css">
	<link rel="stylesheet" media="screen and (orientation: landscape)" href="/web/css/ipad_landscape.css">
<?php endif; ?>

<?= render_assets_until(0) ?>

<!--[if lt IE 9]>
<script type="text/javascript" src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->

<?= content() ?>

<?= render_assets_from(0) ?>