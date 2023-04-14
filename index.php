<?php
if (php_sapi_name() == 'cli-server') {
    /* route static assets and return false */
}


require './site/Framework.php';
handle($_GET['geometrae_page']);
?>