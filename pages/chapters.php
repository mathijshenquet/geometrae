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
		<h2>De Elementen van Euclides - Boek 2</h2>
		<div class="book">
			<div class="chapter">
				<div class="info">
					<p class="title">1. <a href="#">Een gelijkzijdige driehoek</a></p>
					<p class="description">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
				</div>
				<div class="progress" title="20%"></div>
			</div>
			<div class="chapter">
				<div class="info">
					<p class="title">2. <a href="#">Een gelijkzijdige driehoek</a></p>
					<p class="description">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
				</div>
				<div class="progress" title="0%"></div>
			</div>
			<div class="chapter">
				<div class="info">
					<p class="title">3. <a href="#">Een gelijkzijdige driehoek</a></p>
					<p class="description">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
				</div>
				<div class="progress" title="0%"></div>
			</div>
		</div>
	</div>
	<div id="user_info">
		<h2>Informatie</h2>
		<dl>
			<dt>Name</dt>
			<dd>Cas Cornelissen</dd>
			<dt>Achievements</dt>
			<dd>42</dd>
		</dl>
		<h2>Achievements</h2>
		<ul>
			
		</ul>
	</div>
</div>