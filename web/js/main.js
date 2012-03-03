$(function() {
	$("#logo").click(function() {
		window.location = "./";
	});

	if(navigator.userAgent.match(/iPad/i) != null){
		$('body').addClass("ipad")
	}
})
