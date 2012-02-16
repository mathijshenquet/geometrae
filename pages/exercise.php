<?php
parent("./pages/template.php");

set('title', 'Exercise');

render('./pages/+eplane.php');

asset(-1, 'css', '/web/css/exercise.css');

asset(0,  'js', '/web/lib/coffee-script.js');
asset(1,  'js', '/web/lib/jquery.easing.js');
asset(1,  'js', '/web/lib/jquery.scrollTo-min.js');

asset(100, 'inline_cf', <<<'INLINE'

$ ->
    $canvas = $(".euclides canvas.app")
    $wrap = $(".euclides")
    $body = $("body")
    
    euclides = new EuclidesApp($canvas);

    resizeCanvas = ->
        fullscreen = $body.hasClass("fullscreen")
        
        offset = if fullscreen then 12 else 138 #TODO Beetje 'magic hier'. Beter uitlezen hoe hoog ie moet worden
        $wrap.height $(window).height() - offset
        $wrap.width 700
        $wrap.css "display", "block"
        
        $canvas[0].width = 700;
        $canvas[0].height = $wrap.height()
        
        $canvas.show()
        
        euclides.draw()
        
        $.scrollTo('44px', 0, {easing:'easeOutQuint'}) if fullscreen
        
    $(document).jkey 'f', ->
        if $body.hasClass "fullscreen"
            $body.removeClass "fullscreen"
        else
            $body.addClass "fullscreen"
        resizeCanvas()
    
    resizeCanvas()
    $(window).resize resizeCanvas

INLINE
);
?>
<div class="wrapper" style="overflow: none;">
    <div class="description">
        <h2>1. Gelijkzijdige driehoek</h2>
		<p>Nunc auctor eros at purus dapibus ullamcorper. Sed ultricies eleifend erat vel ultrices. Integer pretium vehicula mi, in luctus sapien tempor ac. Nulla facilisi. Aenean at nisl nec velit imperdiet blandit a quis erat. Donec id luctus tellus. Etiam porta dolor ut nisl suscipit feugiat. Nullam eget mi lorem. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.</p>
		<div class="button small" id="next">Volgende <span class="quo">&raquo;</span></div>
		<div class="button small" id="prev"><span class="quo">&laquo;</span> Vorige</div>
    	<div class="button small" id="hints">Hints</div>
	</div>
    <div class="euclides exercise">
        <canvas class="app">You really need to update your browser...</canvas>
    </div>
</div>