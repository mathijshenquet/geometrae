<?php
parent("./pages/template.php");

set('title', 'Hoofdstukken');
asset(11, 'js', '/web/js/chapters.js');
?>

<div class="wrapper">
	<div id="books">
		<h2>De Elementen van Euclides - Boek 1</h2>
		<div class="book">
			<div class="chapter">
				<div class="info">
					<p class="title">1. <a href="#">Een gelijkzijdige driehoek</a></p>
					<p class="description">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
				</div>
				<div class="progress" title="100%"></div>
			</div>
			<div class="chapter">
				<div class="info">
					<p class="title">2. <a href="#">Een gelijkzijdige driehoek</a></p>
					<p class="description">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
				</div>
				<div class="progress" title="70%"></div>
			</div>
			<div class="chapter">
				<div class="info">
					<p class="title">3. <a href="#">Een gelijkzijdige driehoek</a></p>
					<p class="description">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
				</div>
				<div class="progress" title="32%"></div>
			</div>
		</div>
	</div>
	<div id="user_info">
		<h2>Over jou</h2>
		<p>We weten eigenlijk nog niet zoveel over jou! Vertel ons iets meer en maak je profiel compleet zodat je vrienden je makkelijker kunnen vinden!</p>
		<dl>
			<dt>Gebruikersnaam</dt>
			<dd><?php echo $_SESSION['username'] ?></dd>
			<dt>Geslacht</dt>
			<dd>Man</dd>
			<dt>Uitdagingen</dt>
			<dd>42/124</dd>
		</dl>
		<h2>Uitdagingen</h2>
		<ul>
			
		</ul>
	</div>
</div>