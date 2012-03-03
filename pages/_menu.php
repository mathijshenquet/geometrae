<div id="header">
	<div class="wrapper">
		<div id="logo">
			<h1>Geometrae</h1>
		</div>
		<?php if ( isset($_SESSION['username'])) {?>
			<ul id="nav">
	            <li><a href="<?= link_to('homepage') ?>">Home</a></li>
	            <li><a href="<?= link_to('dashboard') ?>">Dashboard</a></li>
	            <li><a href="<?= link_to('sandbox') ?>">Sandbox</a></li>
	            <li><a href="<?= link_to('settings') ?>">Instellingen</a></li>
	            <li><a href="<?= link_to('logout') ?>">Log uit</a></li>
	        </ul>
        <?php } else { ?>
			<ul id="nav">
	            <li><a href="<?= link_to('homepage') ?>">Home</a></li>
	            <li><a href="<?= link_to('login') ?>">Aanmelden</a></li>
	            <li><a href="<?= link_to('sandbox') ?>">Sandbox</a></li>
	        </ul>
        <?php } ?>
	</div>
    <?php 
    	if (isset($_SESSION['username'])) { include ('./pages/userbar.php'); }
    ?>
</div>