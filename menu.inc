<?php
$pages = Array(
	'name' => "Do Not Press",
	'type' => "content",
	'page' => "index.php");
?>

<li><a href="<?php echo preg_replace('/.*\/plugins\/(.*)/', 'plugin.php?plugin=$1&page=index.php', dirname(__FILE__)); ?>">Do Not Press</a></li>
