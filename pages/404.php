<?php
header('HTTP/1.0 404 Not Found');

parent("./pages/template.php");
?>
<div class="wrapper vertical-align">
	<img class="error" src="./web/images/bello_404.png" "404 not found" />
	<p>Het spijt ons heel erg, wij treuren met je mee :'(</p>
	<p>Misschien is het het beste voor ons allemaal dat je deze pagina met rust laat.<br /> Ga naar de <a href="./">homepage</a>, de <a href="sandbox">zandbak</a> of neem <a href="contact">contact</a> met ons op!</p>
</div>