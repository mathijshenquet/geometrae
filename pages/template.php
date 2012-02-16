<?php
parent("./pages/base.php");

asset(-1, 'css', '/web/css/main.css');
asset(0, 'js', 'http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js');

if(has('title')) set('title', '%s - Geometrae');
else 			 set('title', 'Geometrae');

set('author', "Cas Cornelissen, Mathijs Henquet")
?>

<div id="contentwrap">
	<?= render('./pages/_menu.php') ?>
	
	<div id="header_border"></div>
	
	<?php if(has('flash')): ?>
	<div class="message">
		<div class="wrapper">
			<p><?= get('flash') ?></p>
		</div>
	</div>
	<?php endif; ?>
		
	<?= content() ?>
		
	<div class="push"></div>
</div>

<?php if(get('show_footer', true)): ?>
<div id="footer">
	<div class="wrapper">
		<p>Alle rechten voorbehouden &copy; 2011 - <?php echo date('Y') ?></p>
		<p><a href="#">Mathijs Henquet</a> <span class="amp">&amp;</span> <a href="#">Cas Cornelissen</a></p>
	</div>
</div>
<?php endif; ?>
