<?php
parent("./pages/template.php");

set('title', 'Aanmelden');
asset(11, 'js', '/web/js/login.js');
?>

<div class="wrapper">
	<div id="loginorsignup">
		<form id="login" method="post" action="checklogin.php">
			<legend>Log in</legend>
			<label for="username">Gebruikersnaam</label>
			<input type="text" name="username" value="Gebruikersnaam"></input>
			<label for="password">Wachtwoord</label>
			<input type="password" name="password" value="Wachtwoord"></input>
			<input type="submit" id="login_submit" class="button" value="Inloggen"></input>
		</form>
		<form id="register" method="post" action="createacount.php">
			<legend>Meld je aan</legend>
			<label for="username">Gebruikersnaam</label>
			<input type="text" name="username" value="Gebruikersnaam"></input>
			<label for="password">Wachtwoord</label>
			<input type="password" name="password" value="Wachtwoord"></input>
			<label for="email">E-mailadres</label>
			<input type="text" name="email" value="E-mailadres"></input>
			<input type="submit" id="login_submit" class="button" value="Maak mijn account"></input>
		</form>
	</div>
</div>
