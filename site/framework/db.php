<?php
// Set up database connection for login information //
#$con_users = mysql_connect("localhost", get('db_username'), get('db_password')) or die(mysql_error());
#mysql_select_db("geometrae_main") or die(mysql_error());

$db = null;
// new PDO(sprintf('mysql:host=%s;dbname=%s', s('db.host'), s('db.dbname')), s('db.user'), s('db.password'), array(
//     PDO::ATTR_PERSISTENT => true
// ));

g('db', $db);