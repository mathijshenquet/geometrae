<?php
parent("./pages/template.php");

set('title', 'Aanmelden');
asset(11, 'js', '/web/js/login.js');
?>
<?php if ( isset($_SESSION['username'])) { ?>
	<div class="wrapper vertical-align">
		<img src="web/images/bello_ouch.png" />
		<p>Je bent al ingelogd als <strong><?= $_SESSION['username'] ?></strong>, slimmerd.<br />Maar, als je wilt <a href="logout">uitloggen</a> kan dat natuurlijk altijd.</p>
	</div>
<?php } else { ?>
	<?php if ( isset($_POST['login']) ) { 
		mysql_select_db("geometrae_main") or die(mysql_error());
		$result = mysql_query("SELECT * FROM users WHERE username = '" . mysql_real_escape_string($_POST['login_username']) . "'");
		$row = mysql_fetch_array( $result );
		if ( $row != "" ) {
			if ( hash('sha256', get('hash').$_POST['login_password']) == $row['password'] ) {
				$_SESSION['username'] = $_POST['login_username'];
				$_SESSION['password'] = $_POST['login_password'];
				header("Location: dashboard");
			} else {
				$img = 'ouch';
				$msg = 'De gebruikersnaam-wachtwoord combinatie is incorrect.<br />Ben je misschien je <a href="recoverpassword">wachtwoord vergeten</a>? Je kunt het ook <a href="login">opnieuw proberen</a>.';
			};
		} else {
			$img = 'ouch';
			$msg = 'We konden helaas geen account met deze gebruikersnaam vinden.<br />Wil je je gratis <a href="login">aanmelden</a> voor een account? Je kunt het ook <a href="login">opnieuw proberen</a>.';
		} 
		?>
		<div class="wrapper vertical-align">
			<img src="web/images/bello_<?= $img ?>.png" />
			<p><?= $msg ?></p>
		</div>
	<?php } else if ( isset($_POST['register']) ) {
		mysql_select_db("geometrae_main") or die(mysql_error());
		
		$img = 'gelukt';
		$msg = 'Er is een email naar <strong>' . $_POST["signup_email"] . '</strong> gestuurd met een activatielink.<br />Klik <a href="login">hier</a> om terug te gaan, of ga naar de <a href="./">homepage</a>.';
		$allok = true;
		
		$result = mysql_query("SELECT * FROM users WHERE email = '" . mysql_real_escape_string($_POST['signup_email']) . "'");
		$row = mysql_fetch_array( $result );
		if ( $row != "" ) {
			// TODO: Extra email address validation
			$allok = false;
			$img = 'ouch';
			$msg = 'Het emailadres dat je hebt opgegeven is al in gebruik.<br />Ben je misschien je <a href="passwordrecovery">wachtwoord kwijt</a> of wil je <a href="login">registreren</a> met een ander emailadres?';
		}
	
		$result = mysql_query("SELECT * FROM users WHERE username = '" . mysql_real_escape_string($_POST['signup_username']) . "'");
		$row = mysql_fetch_array( $result );
		if ( $row != "" ) {
			$allok = false;
			$img = 'ouch';
			$msg = 'De gebruikersnaam die je hebt opgegeven is al in gebruik.<br />Ben je misschien je <a href="passwordrecovery">wachtwoord kwijt</a> of wil je <a href="login">registreren</a> met een andere gebruikersnaam?';
		}
	
		// If everything is correct after the 2nd check, add user to database //
		if ( $allok ) {
			// TODO: Sent E-mail with activation link
			mysql_select_db("geometrae_main") or die(mysql_error());
			mysql_query("INSERT INTO users (username, password, email) VALUES ('" . mysql_real_escape_string ($_POST['signup_username']) . "', '" . hash('sha256', get('hash').mysql_real_escape_string($_POST['signup_password'])) . "', '" . mysql_real_escape_string($_POST['signup_email']) . "')");
		}
		?>
		<div class="wrapper vertical-align">
			<img src="web/images/bello_<?= $img ?>.png" />
			<p><?= $msg ?></p>
		</div>
	<?php } else { ?>
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
	<?php } ?>
<?php } ?>