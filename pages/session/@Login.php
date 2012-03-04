<?php
if ( g('session')->getUser() ):
	echo render('./pages/msg.php', array(
		'status' => 'fout', 
		'msg' 	 => 'Je bent al ingelogd als <strong>'. g("session")->get('username') . '</strong>, slimmerd.<br />Maar, als je wilt <a href="logout">uitloggen</a> kan dat natuurlijk altijd.'
	));
elseif ( isset($_POST['login']) ): 
	$user = User::findBy('username', $_POST['login_username']);

	if(!$user){
		echo render('./pages/msg.php', array(
			'status' => 'fout',
			'msg' 	 => 'We konden helaas geen account met deze gebruikersnaam vinden.<br />Wil je je gratis <a href="'.link_to('login').'">aanmelden</a> voor een account? Je kunt het ook <a href="'.link_to('login').'">opnieuw proberen</a>.'
		));
	}else if(!$user->checkPassword($_POST['login_password'])){
		echo render('./pages/msg.php', array(
			'status' => 'fout',
			'msg' 	 => 'De gebruikersnaam-wachtwoord combinatie is incorrect.<br />Ben je misschien je <a href="'.link_to('password_recovery').'">wachtwoord vergeten</a>? Je kunt het ook <a href="'.link_to('login').'">opnieuw proberen</a>.'
		));
	}else{
		g('session')->attachUser($user);
		echo render('./pages/msg.php', array(
			'status' => 'gelukt',
			'msg' 	 => 'Je bent ingelogd.'
		));
	}
elseif ( isset($_POST['register']) ):
	if(User::findBy('email', $_POST['signup_email'])){
		// TODO: Extra email address validation
		$success = false;
		echo render('./pages/msg.php', array(
			'status' => 'fout',
			'msg' => 'Het emailadres dat je hebt opgegeven is al in gebruik.<br />Ben je misschien je <a href="'.link_to('password_recovery').'">wachtwoord kwijt</a> of wil je <a href="'.link_to('login').'">registreren</a> met een ander emailadres?'
		));
	}else if(User::findBy('username', $_POST['signup_username'])){
		$success = false;
		echo render('./pages/msg.php', array(
			'status' => 'fout',
			'msg' => 'De gebruikersnaam die je hebt opgegeven is al in gebruik.<br />Ben je misschien je <a href="'.link_to('password_recovery').'">wachtwoord kwijt</a> of wil je <a href="'.link_to('login').'">registreren</a> met een andere gebruikersnaam?'
		));
	}else{
		$user = new User();
		$user->username = $_POST['signup_username'];
		$user->email    = $_POST['signup_email'];
		$user->encryptPassword($_POST['signup_password']);
		$user->group = Group::findBy('name', 'user');
		$user->persist();
		g('session')->attachUser($user);

		echo render('./pages/msg.php', array(
			'status' => 'gelukt',
			'msg' 	 => 'Er is een email naar <strong>' . $user->email . '</strong> gestuurd met een activatielink.<br />Klik <a href="'.link_to(get('session').get('return_page', 'homepage')).'">hier</a> om terug te gaan.'
		));
	}
else:
	echo render('./pages/session/signup.php');
endif;