<?php
parent("./pages/template.php");

asset(11, 'js', '/web/js/login.js');
?>

<div class="wrapper vertical-align">
	<img src="web/images/bello_<?= $status ?>.png" />
	<p><?= $msg ?></p>
</div>