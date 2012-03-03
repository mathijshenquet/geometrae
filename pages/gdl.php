<?php
parent("./pages/template.php");

set('title', 'GDL Test');

asset(100, 'inline_cf', <<<INLINE

$ ->
  lexer = new GDLLexer;
  $.get '/lessons/test.gdl', (content) ->
    console.log (lexer.tokenize content).map((token) -> "#{token.value}:#{token.tag}").join(" ")

INLINE
);
?>

<?= render('./pages/_gdl_console.php') ?>

<div class="euclides sandbox">
</div>