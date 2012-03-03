$(document).ready(function() {
	$(".progress").each(function() {
		$(this).css("background-position", -(100-$(this).attr("title").split("%")[0]) + "px");
	});
});