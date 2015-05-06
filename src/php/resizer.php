<?php
/**
// Quick tester
if ( isset( $_GET['file'] ) )
{
	$fullPath = $_GET['file'];
	$img = smart_resize_image( $fullPath, null, 150, 150 );
	var_dump( $img );
}

	
	* easy image resize function
	* @param  $file - file name to resize
	* @param  $string - The image data, as a string
	* @param  $width - new image width
	* @param  $height - new image height
	* @param  $output - name of the new file (include path if needed)
	* @param  $delete_original - if true the original image will be deleted
	* @param  $use_linux_commands - if set to true will use "rm" to delete the image, if false will use PHP unlink
	* @param  $quality - enter 1-100 (100 is best quality) default is 100
	* @return array (success:true, width:1, height:1 )
	*/
	
	function smart_resize_image(	
		$file,
		$string             = null,
		$width              = 0, 
		$height             = 0, 
		$output             = 'file.jpg', 
		$delete_original    = false, 
		$use_linux_commands = false,
		$quality 			= 100
  	){
		// We want to output the following Object :
		$export = array("success" => false, "width" => null, "height" => null );
	
		if ( $height <= 0 && $width <= 0 ) return $export;
		if ( $file === null && $string === null ) return $export;

		# Setting defaults and meta
		$info                         = $file !== null ? getimagesize($file) : getimagesizefromstring($string);
		$image                        = '';
		$final_width                  = 0;
		$final_height                 = 0;
		list($width_old, $height_old) = $info;
		$cropHeight = $cropWidth = 0;

		# Calculating proportionality
		if      ($width  == 0)  $factor = $height/$height_old;
		elseif  ($height == 0)  $factor = $width/$width_old;
		else                    $factor = min( $width / $width_old, $height / $height_old );

		$final_width  = round( $width_old * $factor );
		$final_height = round( $height_old * $factor );
	   
		# Loading image to memory according to type
		// @ denotes IGNORE ERRORS for corrupt files
		switch ( $info[2] ) 
		{
			case IMAGETYPE_JPEG:  $file !== null ? $image = @imagecreatefromjpeg($file) : $image = imagecreatefromstring($string);  break;
			case IMAGETYPE_GIF:   $file !== null ? $image = @imagecreatefromgif($file)  : $image = imagecreatefromstring($string);  break;
			case IMAGETYPE_PNG:   $file !== null ? $image = @imagecreatefrompng($file)  : $image = imagecreatefromstring($string);  break;
			// another fail
			default: return $export;
		}
		
		# store output
		$export['width'] = $final_width;
		$export['height'] = $final_height;
		
		// check to see if image is valid...
		if (!$image)
		{
			return $export;
		}
		
		
		# This is the resizing/resampling/transparency-preserving magic
		$image_resized = imagecreatetruecolor( $final_width, $final_height );
		
		if ( ($info[2] == IMAGETYPE_GIF) || ($info[2] == IMAGETYPE_PNG) ) 
		{
			$transparency = imagecolortransparent($image);
			$palletsize = imagecolorstotal($image);

			if ($transparency >= 0 && $transparency < $palletsize) 
			{
				$transparent_color  = imagecolorsforindex($image, $transparency);
				$transparency       = imagecolorallocate($image_resized, $transparent_color['red'], $transparent_color['green'], $transparent_color['blue']);
				imagefill($image_resized, 0, 0, $transparency);
				imagecolortransparent($image_resized, $transparency);
			
			} elseif ($info[2] == IMAGETYPE_PNG) {
			
				imagealphablending($image_resized, false);
				$color = imagecolorallocatealpha($image_resized, 0, 0, 0, 127);
				imagefill($image_resized, 0, 0, $color);
				imagesavealpha($image_resized, true);
			}
		}
		
		@imagecopyresampled( $image_resized, $image, 0, 0, $cropWidth, $cropHeight, $final_width, $final_height, $width_old - 2 * $cropWidth, $height_old - 2 * $cropHeight);
		
		# Taking care of original, if needed
		if ( $delete_original ) 
		{
			if ( $use_linux_commands ) exec('rm '.$file);
			else @unlink($file);
		}

		$export['success'] = true;

		/*
		# Preparing a method of providing result
		switch ( strtolower($output) )
		{
			case 'browser':
				$mime = image_type_to_mime_type($info[2]);
				header("Content-type: $mime");
				$output = NULL;
				break;
				
			case 'file':
				$output = $file;
				break;
				
			case 'return':
				return $image_resized;
				break;
				
			default:
				break;
		}
		*/
		
		# Writing image according to type to the output destination and image quality
		switch ( $info[2] ) 
		{
			case IMAGETYPE_GIF:   
				imagegif($image_resized, $output);    
				break;
				
			case IMAGETYPE_JPEG:  
				imagejpeg($image_resized, $output, $quality);   
				break;
				
			case IMAGETYPE_PNG:
				$quality = 9 - (int)((0.9*$quality)/10.0);
				imagepng($image_resized, $output, $quality);
				break;
				
			default: 
				// One last failure in trying to write
				$export['success'] = false;
		}
		
		return $export;
	}
?>