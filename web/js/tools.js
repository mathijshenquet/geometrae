$(document).ready(function() {
	$("#tools li").fadeTo(0, .5);
	
	$("#tools li").hover(function() {
		$(this).stop().fadeTo(0, 1);
	}, function() {
		$(this).stop().fadeTo(300, .5);
	})
});