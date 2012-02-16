<?php
render('./pages/+gdl.php');

asset(0, 'js',  '/web/lib/coffee-script.js');
asset(100, 'js',  '/web/lib/less.js');
asset(1, 'js',  '/web/lib/jquery.easing.js');

//asset(1, 'js',  '/web/codemirror/lib/codemirror.js');
//asset(2, 'js',  '/web/codemirror/mode/ruby/ruby.js');
//asset(1, 'css', '/web/codemirror/lib/codemirror.css');

asset(1, 'js',	'/web/Console/jquery.console.js');
asset(-1, 'less','/web/Console/style.less');
asset(2, 'cf',  '/web/Console/helper.coffee');

asset(20, 'cf',  '/web/js/gdl_console.coffee');
asset(-1, 'css', '/web/css/gdl_console.css');
?>

<div id="gdl_console"></div>
<div id="gdl_console_button"></div>
