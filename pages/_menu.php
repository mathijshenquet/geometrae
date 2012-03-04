<div id="header">
	<div class="wrapper">
		<div id="logo">
			<h1>Geometrae</h1>
		</div>
		<?php if (g('session')->getUser()): ?>
		<ul id="nav">
            <li><a href="<?= link_to('homepage') ?>">Home</a></li>
            <li><a href="<?= link_to('dashboard') ?>">Dashboard</a></li>
            <li><a href="<?= link_to('sandbox') ?>">Sandbox</a></li>
            <li><a href="<?= link_to('settings') ?>">Instellingen</a></li>
            <li><a href="<?= link_to('logout') ?>">Log uit</a></li>
        </ul>
        <?php else: ?>
		<ul id="nav">
            <li><a href="<?= link_to('homepage') ?>">Home</a></li>
            <li><a href="<?= link_to('dashboard') ?>">Dashboard</a></li>
            <li><a href="<?= link_to('sandbox') ?>">Sandbox</a></li>
            <li><a href="<?= link_to('login') ?>">Aanmelden</a></li>
        </ul>
        <?php endif; ?>
	</div>
    <?php //if (g('session')->getUser()) echo render('./pages/userbar.php'); ?>
</div>