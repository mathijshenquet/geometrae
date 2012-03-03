$(document).ready(function() {
	$("input").each(function() {
		$(this).attr("alt", $(this).attr("value"));
	});
	
	$("input[type=text], input[type=password]").focus(function() {
		if ( $(this).attr("alt") == $(this).val() ) {
			$(this).attr("value", "");
		}
	});
	$("input[type=text], input[type=password]").blur(function() {
		if ( $(this).attr("value") == "" ) {
			$(this).attr("value", $(this).attr("alt"));
			$(this).removeClass("filled");
		} else {
			$(this).attr("value", $(this).val());
			$(this).addClass("filled");
		}
	});
	
	$("#login input").focus(function() {
		$("#login").fadeTo(0,1);
		$("#register").fadeTo(250,.5);
	});
	$("#register input").focus(function() {
		$("#register").fadeTo(0,1);
		$("#login").fadeTo(250,.5);
	});
});