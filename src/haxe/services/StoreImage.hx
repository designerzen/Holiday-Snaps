/*

The uploader class talks directly to this php script that determines where to save stuff.

This class is also responsible for reading the EXIF data

*/

package services;

import php.Lib;
import php.Web;

class StoreImage
{

	public function new() 
	{
		// returns a NativeArray with values [1,2,3]
		var imagePath = '';
		
		var exif_ifd0 = untyped __call__("read_exif_data", imagePath ,'IFD0', 0 ); 
		var exif_exif = untyped __call__("read_exif_data", imagePath ,'EXIF', 0 ); 

		lon = getGps( exif_exif["GPSLongitude"], exif_exif['GPSLongitudeRef'] );
		lat = getGps( exif_exif["GPSLatitude"], exif_exif['GPSLatitudeRef'] );
	}
	 
	// Convert this image into a tumbnail
	public function createThumbnail():Void
	{
		
	}
	/*
	function gps(coordinate, hemisphere) 
	{
		for (i = 0; i < 3; i++)
		{
			part = explode('/', coordinate[i]);
			if (count(part) == 1) 
			{
				coordinate[i] = part[0];
			} else if (count(part) == 2) {
				coordinate[i] = floatval(part[0])/floatval(part[1]);
			} else {
				coordinate[i] = 0;
			}
		}
		list(degrees, minutes, seconds) = coordinate;
		sign = (hemisphere == 'W' || hemisphere == 'S') ? -1 : 1;
		return sign * (degrees + minutes/60 + seconds/3600);
	}
	*/
	
	public function getGps(exifCoord, hemi) : Void 
	{
		var degrees = exifCoord.length > 0 ? gps2Num(exifCoord[0]) : 0;
		var minutes = exifCoord.length > 1 ? gps2Num(exifCoord[1]) : 0;
		var seconds = exifCoord.length > 2 ? gps2Num(exifCoord[2]) : 0;

		var flip = (hemi == 'W' or hemi == 'S') ? -1 : 1;

		return flip * (degrees + minutes / 60 + seconds / 3600);
	}

	
	function gps2Num(coordPart) : Float 
	{
		parts = coordPart.split('/');
		
		if (parts.length <= 0) return 0;
		if (parts.length == 1) return parts[0];

		return floatval(parts[0]) / floatval(parts[1]);
	}

	function reorient(): Void
	{
		var orientation = exif['Orientation'];
		if ( orientation ) 
		{
			switch( orientation ) 
			{
				case 8:
					image = imagerotate(image,90,0);.
				case 3:
					image = imagerotate(image,180,0);
				case 6:
					image = imagerotate(image,-90,0);
			}
		}else if ( exif['IFD0']['Orientation'] ) {
			switch(ort)
			{
				case 1: // nothing
				
				case 2: // horizontal flip
					image->flipImage(public,1);
								   
				case 3: // 180 rotate left
					image->rotateImage(public,180);
						   
				case 4: // vertical flip
					image->flipImage(public,2);
					   
				case 5: // vertical flip + 90 rotate right
					image->flipImage(public, 2);
					image->rotateImage(public, -90);
					   
				case 6: // 90 rotate right
					image->rotateImage(public, -90);
					   
				case 7: // horizontal flip + 90 rotate right
					image->flipImage(public,1);   
					image->rotateImage(public, -90);
					   
				case 8:    // 90 rotate left
					image->rotateImage(public, 90);
				
			}
		}
	}
	
	
}