<?php

$postMax = ini_get('post_max_size');
$upload_max_filesize = ini_get('upload_max_filesize');

echo "post_max_size:" . $postMax . " upload_max_filesize:" . $upload_max_filesize;

// Standard way of checking the settings of this server
phpinfo();
?>