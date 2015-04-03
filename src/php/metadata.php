<?php

/**
 * Do not use or reference this directly from your client-side code.
 * Instead, this should be required via the endpoint.php or endpoint-cors.php
 * file(s).
 */

class MetaDataHandler {

    function __construct() {
	
    }

	public function getMetaData($coordinate, $hemisphere)
	{
		$exif = exif_read_data($filename);
		$latitude = gps($exif["GPSLatitude"], $exif['GPSLatitudeRef']);
		$longitude = gps($exif["GPSLongitude"], $exif['GPSLongitudeRef']);
		
		$exif[latitude] = $latitude;
		$exif[longitude] = $longitude;
		
		return $exif;
	}
	
	protected function gps($coordinate, $hemisphere)
	{
		for ($i = 0; $i < 3; $i++)
		{
			$part = explode('/', $coordinate[$i]);
			if (count($part) == 1) {
				$coordinate[$i] = $part[0];
			} else if (count($part) == 2) {
				$coordinate[$i] = floatval($part[0])/floatval($part[1]);
			} else {
				$coordinate[$i] = 0;
			}
		}
		list($degrees, $minutes, $seconds) = $coordinate;
		$sign = ($hemisphere == 'W' || $hemisphere == 'S') ? -1 : 1;
		
		return $sign * ($degrees + $minutes/60 + $seconds/3600);
	}

}