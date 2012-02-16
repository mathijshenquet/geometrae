$(document).ready(function() {
	$(".progress").each(function() {
		console.log($(this).attr("title").split("%")[0])
		$(this).css("background-position", -(100-$(this).attr("title").split("%")[0]) + "px");
	});
});