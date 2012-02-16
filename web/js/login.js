$(document).ready(function() {
	$("input").each(function() {
		$(this).attr("name", $(this).attr("value"));
	});
	
	$("input[type=text], input[type=password]").focus(function() {
		if ( $(this).attr("name") == $(this).val() ) {
			$(this).attr("value", "");
		}
	});
	$("input[type=text], input[type=password]").blur(function() {
		if ( $(this).attr("value") == "" ) {
			$(this).attr("value", $(this).attr("name"));
			$(this).removeClass("filled");
		} else {
			$(this).attr("value", $(this).val());
			$(this).addClass("filled");
		}
	});
});