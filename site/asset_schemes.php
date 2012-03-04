<?php
$config = &g('config');

$config['asset_schemes'] = array(
	"cf" 	=> "<script type=\"text/coffeescript\" src=\"%s\"></script>",
	"js"	=> "<script type=\"text/javascript\" src=\"%s\"></script>",
	"less"	=> "<link rel=\"stylesheet/less\" type=\"text/css\" href=\"%s\" />",
	"css"	=> "<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\" />",

	"inline_cf"		=> "<script type=\"text/coffeescript\">%s</script>",
	"inline_js"		=> "<script type=\"text/javascript\">%s</script>",
	"inline_css"	=> "<style type=\"text/css\">%s</style>"
);