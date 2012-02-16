<?php
parent("./pages/template.php");

set('title', 'Aanmelden');
asset(11, 'js', '/web/js/login.js');
?>

<div class="wrapper">
	<div id="loginorsignup">
		<div id="login">
			<h2>Log in</h2>
			<h3>Gebruikersnaam</h3>
			<input type="text" value="Gebruikersnaam"></input>
			<h3>Wachtwoord</h3>
			<input type="password" value="Wachtwoord"></input>
			<input type="submit" id="login_submit" class="button" value="Inloggen"></input>
		</div>
		<div id="register">
			<h2>Meld je aan</h2>
			<h3>Gebruikersnaam</h3>
			<input type="text" value="Gebruikersnaam"></input>
			<h3>Wachtwoord</h3>
			<input type="password" value="Wachtwoord"></input>
			<h3>E-mailadres</h3>
			<input type="text" value="E-mailadres"></input>
			<input type="submit" id="login_submit" class="button" value="Maak mijn account"></input>
		</div>
	</div>
</div>
