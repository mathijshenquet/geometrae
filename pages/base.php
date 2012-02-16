<!doctype html>
<meta charset="utf-8">
<title><?= get('title') ?></title>
<meta name="author" content="<?= get("author") ?>">

<?= render_assets_until(0) ?>

<!--[if lt IE 9]>
<script type="text/javascript" src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->

<?= content() ?>

<?= render_assets_from(0) ?>