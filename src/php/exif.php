<?php
$fullPath = $_GET['file'];

var_dump(  $fullPath );

require_once "metadata.php";

$meta = new MetaDataHandler();
$exif = $meta->getMetaData( $fullPath );
//$result["lat"] = $exif["latitude"];
//$result["long"] = $exif["longitude"];
if (array_key_exists('latitude', $exif))
{
	var_dump(  $exif['latitude'] );
}else {
	var_dump(  $exif );
}
?>