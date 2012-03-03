<?php
parent("./pages/template.php");

render('./pages/+eplane.php');

asset(100, 'inline_cf', <<<INLINE

$ ->
    canvas = $(".app")
    euclides = new EuclidesApp(canvas)
    euclides.selectTool("interact")
    euclides.toggleHide("toolbar")

    {x, y} = euclides.toCanvasCoords({x: 85, y: 125})
    a = new FreePoint(x, y, euclides)

    {x, y} = euclides.toCanvasCoords({x: 135, y: 55})
    b = new FreePoint(x, y, euclides)

    c1 = new Circle a, b
    c2 = new Circle b, a

    i1 = new DependentPoint c1, c2, 0
    i2 = new DependentPoint c1, c2, 1

    l1 = new Line(a, b)
    l2 = new Line(i1, i2)
    l3 = new Line(a, i1)
    l4 = new Line(a, i2)
    l5 = new Line(b, i1)
    l6 = new Line(b, i2)

    euclides.attach [a, b, c1, c2, i1, i2, l1, l2, l3, l4, l5, l6]

    {x, y} = euclides.toCanvasCoords({x: 600-135, y: 125})
    a = new FreePoint(x, y, euclides)

    {x, y} = euclides.toCanvasCoords({x: 600-85, y: 55})
    b = new FreePoint(x, y, euclides)

    c = new Circle(a, b)
    l = new Line(a, b)

    euclides.attach [a, b, c, l]

    {x, y} = euclides.toCanvasCoords({x: 300-75, y: 230})
    a = new FreePoint(x, y, euclides)

    {x, y} = euclides.toCanvasCoords({x: 300+50, y: 185})
    b = new FreePoint(x, y, euclides)

    c1 = new Circle(a, b)
    c2 = new Circle(b, a)
    i = new DependentPoint(c1, c2, 1)

    l1 = new Line(a, b)
    l2 = new Line(a, i)
    l3 = new Line(i, b)

    c1.hidden = c2.hidden = c1.helper = c2.helper = true

    euclides.attach [a, b, i, l1, l2, l3, c1, c2]

INLINE
);
?>

<div id="preview">
	<div class="wrapper">
		<div id="preview_text">
			<h2>Geometrae is online!</h2>
			<p>Geometrae is eindelijk online! Via deze website leer je om te gaan met geometrie zoals de oude meesters dat deden. Het is interactief, het is leuk en zeker ook sociaal.</p>
			<a href="login" class="button">Begin met Geometrae!</a>
		</div>
		<div class="app preview"></div>
	</div>
	<div id="blackbar"></div>
</div>
<div id="news">
	<div class="wrapper">
		<p>Meld je nu gratis aan voor Geometrae, en duik vandaag nog in de wondere wereld van de geometrie! Iedereen kan het &eacute;n het is gratis, dus waarom zou je het niet proberen?</p>
		<div id="social_icons">
			<a href="#facebook"><img src="web/images/social_facebook.png" alt="Facebook" /></a>
			<a href="#twitter"><img src="web/images/social_twitter.png" alt="Twitter" /></a>
			<a href="#github"><img src="web/images/social_github.png" alt="Github" /></a>
			<a href="#email"><img src="web/images/social_email.png" alt="Email" /></a>
		</div>
	</div>
</div>
<div id="content">
	<div class="wrapper">
		<div class="inforow">
			<div class="infobox">
				<h3 id="title_learnbest">Leer van de beste</h3>
				<p>De lessen van Geometrae zijn gebaseerd op Euclides, de grondlegger van de geometrie!</p>
			</div>
			<div class="infobox">
				<h3 id="title_playandlearn">Spelen en leren tegelijk</h3>
				<p>Door de speelse opbouw en het hoge tempo hoeft geometrie echt niet saai te zijn!</p>
			</div>
			<div class="infobox">
				<h3 id="title_achievements">Uitdagingen</h3>
				<p>Voor de volleerde wiskundige zijn er verschillende uitdagingen voor nog meer geometrie.</p>
			</div>
		</div>
		<div class="inforow">
			<div class="infobox">
				<h3 id="title_highestscore">Construeer</h3>
				<p>Door de intuitieve interface was het construeren van geometrische vormen nog nooit zo makkelijk.</p>
			</div>
			<div class="infobox">
				<h3 id="title_start">Automatiseer</h3>
				<p>Met onze simpele programmeertaal kunnen ingewikkelde constructies worden gemaakt.</p>
			</div>
			<div class="infobox">
				<h3 id="title_beatfriends">Hou je score bij en versla je vrienden</h3>
				<p>Geometrae houdt alle vorderingen, van lessen tot uitdagingen, voor je bij.</p>
			</div>
		</div>
	</div>
</div>