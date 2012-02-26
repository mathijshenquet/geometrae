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
    body = $("body")
    
    euclides = new EuclidesApp($(".euclides"));
    makeGDLConsole(euclides)

    resizeCanvas = ->
        fullscreen = body.hasClass("fullscreen")
        
        offset = if fullscreen then 12 else 46+1+50 #TODO Beetje 'magic' hier. Beter uitlezen hoe hoog ie moet worden
        euclides.element.height (height = $(window).height() - offset)
        euclides.element.css "display", "block"

        euclides.resize()
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
</div>