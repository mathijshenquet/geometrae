<?php
// router.php
if (preg_match('/\.(?:png|jpg|jpeg|gif|js|coffee|css|less)$/', $_SERVER["REQUEST_URI"])) {
    return false;    // serve the requested resource as-is.
} else { 
    require './site/Framework.php';
    handle($_SERVER["REQUEST_URI"]);
}
?>