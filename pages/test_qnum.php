<?php
parent("./pages/template.php");

set('title', 'Test qNum');

render('./pages/+qNum.php');

asset(100, 'inline_cf', <<<'INLINE'

qnum = new qNum.Pool

distance = (a, b) -> (qnum.execute "\\((#{b.x} - #{a.x})^2 + (#{b.y} - #{a.y})^2)")._
	
###
a = \\2 + \\3 == \\(5 + 2 * \\6)
b = 1 + \\2 == \\(3 + 2 * \\2)
###

console.log show distance {x: 34, y: 53}, {x: 3, y: 4}

INLINE
);
?>