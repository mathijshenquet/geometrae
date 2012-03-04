<?php
parent("./pages/template.php");

set('title', 'Aanmelden');
asset(11, 'js', '/web/js/login.js');
?>

<div class="wrapper">
	<div id="loginorsignup">
		<form id="login" method="post">
			<legend>Log in</legend>
			<label for="login_username">Gebruikersnaam</label>
			<input type="text" name="login_username" value="Gebruikersnaam"></input>
			<label for="login_password">Wachtwoord</label>
			<input type="password" name="login_password" value="Wachtwoord"></input>
			<input type="submit" name="login" id="login_submit" class="button" value="Inloggen"></input>
		</form>
		<form id="register" method="post">
			<legend>Meld je aan</legend>
			<label for="signup_username">Gebruikersnaam</label>
			<input type="text" name="signup_username" value="Gebruikersnaam"></input>
			<label for="signup_password">Wachtwoord</label>
			<input type="password" name="signup_password" value="Wachtwoord"></input>
			<label for="signup_email">E-mailadres</label>
			<input type="text" name="signup_email" value="E-mailadres"></input>
			<input type="submit" name="register" id="login_submit" class="button" value="Registreren"></input>
		</form>
	</div>
</div>