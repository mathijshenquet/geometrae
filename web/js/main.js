$(function() {
	$("#logo").click(function() {
		window.location = "./";
	});
	$(".vertical-align").each(function() {
		$(this).css("margin-top",  ((($("#contentwrap").height()-(50+11+46))/2)-$(this).height())-50 + "px");
	})
})
