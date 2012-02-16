<?php
parent("./pages/template.php");

set('title', 'Sandbox');

render('./pages/+eplane.php');

asset(-1, 'css', '/web/css/sandbox.css');

asset(0,  'js', '/web/lib/coffee-script.js');
asset(1,  'js', '/web/lib/jquery.easing.js');
asset(1,  'js', '/web/lib/jquery.scrollTo-min.js');

asset(100, 'inline_cf', <<<INLINE

$ ->
    canvas = $(".euclides canvas.app")
    wrap = $(".euclides")
    body = $("body")
    
    euclides = new EuclidesApp(canvas);
    makeGDLConsole(euclides)

    resizeCanvas = ->
        fullscreen = body.hasClass("fullscreen")
        
        offset = if fullscreen then 12 else 138 #TODO Beetje 'magic hier'. Beter uitlezen hoe hoog ie moet worden
        wrap.height $(window).height() - offset
        wrap.css "display", "block"
        
        canvas[0].width = wrap.width()
        canvas[0].height = wrap.height()
        
        canvas.show()
        
        euclides.draw()
        
        $.scrollTo('44px', 0, {easing:'easeOutQuint'}) if fullscreen
        
    $(document).jkey 'f', ->
        if body.hasClass "fullscreen"
            body.removeClass "fullscreen"
        else
            body.addClass "fullscreen"
        resizeCanvas()
    
    resizeCanvas()
    euclides.centerBox()
    $(window).resize resizeCanvas

INLINE
);
?>

<?= render('./pages/_gdl_console.php') ?>

<div class="euclides sandbox">
	<canvas class="app">You really need to update your browser...</canvas>
</div>
