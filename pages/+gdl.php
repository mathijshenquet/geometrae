<?php
asset(0, 'js',  "/web/lib/coffee-script.js");
asset(9, 'cf', "/code/Q.coffee");

$root = "/code/gdl";

asset(10, 'cf', "$root/helpers.coffee");
asset(10, 'cf', "$root/lexer.coffee");
asset(10, 'cf', "$root/parser.coffee");
asset(10, 'cf', "$root/rewriter.coffee");
asset(10, 'cf', "$root/interpreter.coffee");