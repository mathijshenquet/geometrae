<?php
parent("./pages/template.php");

render('./pages/+eplane.php');

asset(100, 'inline_cf', <<<INLINE

$ ->
    canvas = $(".app")
    euclides = new EuclidesApp(canvas)

INLINE
);
?>

<div id="preview">
	<div class="wrapper">
		<div id="preview_text">
			<h1>Leer geometrie</h1>
			<p>Geometrae is de makkelijkste manier om geometrie te doen, en leren. Het is interactief, leuk en je kan het met vrienden doen.</p>
		</div>
		<canvas class="app preview" width="600" height="400">You really need to update your browser...</canvas>
	</div>
	<div id="blackbar"></div>
</div>
<div id="news">
	<div class="wrapper">
		<p>Meld je nu gratis aan voor Geometrae, en begin vandaag nog met de eerste geometrie lessen!</p>
		<a href="<?= link_to("login") ?>" class="button" id="button_signup">Begin met Geometrae!</a>
	</div>
</div>
<div id="content">
	<div class="wrapper">
		<div class="inforow">
			<div class="infobox">
				<h3 id="title_learnbest">Leer van de beste</h3>
				<p>De lessen van Geometrae zijn gebaseerd op de boeken van Euclides van Alexandrië, de grondlegger van de geometrie!</p>
			</div>
			<div class="infobox">
				<h3 id="title_playandlearn">Spelen en leren tegelijk</h3>
				<p>Door de speelse opbouw, en het hoge tempo is geometrie leren niet langer iets dat saai hoeft te zijn.</p>
			</div>
			<div class="infobox">
				<h3 id="title_achievements">Uitdagingen</h3>
				<p>Voor de voleerde wiskundige zijn er verschillende uitdagingen voor nog meer geometrie.</p>
			</div>
		</div>
		<div class="inforow">
			<div class="infobox">
				<h3 id="title_highestscore">Construeer</h3>
				<p>Door de intuitieve interface is het construeren van geometrische vormen nog nooit zo makkelijk geweest.</p>
			</div>
			<div class="infobox">
				<h3 id="title_start">Automatiseer</h3>
				<p>Met de ingebouwde programmeer taal GDL, kunnen makkelijk ingewikkelde constructies worden gemaakt of geverifeerd.</p>
			</div>
			<div class="infobox">
				<h3 id="title_beatfriends">Hou je score bij, en versla je vrienden</h3>
				<p>Geometrae houdt alle vorderingen, van lessen tot uitdagingen, voor je bij.</p>
			</div>
		</div>
	</div>
</div>
