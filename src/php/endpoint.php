<?php

/**
 * PHP Server-Side Example for Fine Uploader (traditional endpoint handler).
 * Maintained by Widen Enterprises.
 *
 * This example:
 *  - handles chunked and non-chunked requests
 *  - supports the concurrent chunking feature
 *  - assumes all upload requests are multipart encoded
 *  - supports the delete file feature
 *
 * Follow these steps to get up and running with Fine Uploader in a PHP environment:
 *
 * 1. Setup your client-side code, as documented on http://docs.fineuploader.com.
 *
 * 2. Copy this file and handler.php to your server.
 *
 * 3. Ensure your php.ini file contains appropriate values for
 *    max_input_time, upload_max_filesize and post_max_size.
 *
 * 4. Ensure your "chunks" and "files" folders exist and are writable.
 *    "chunks" is only needed if you have enabled the chunking feature client-side.
 *
 * 5. If you have chunking enabled in Fine Uploader, you MUST set a value for the `chunking.success.endpoint` option.
 *    This will be called by Fine Uploader when all chunks for a file have been successfully uploaded, triggering the
 *    PHP server to combine all parts into one file. This is particularly useful for the concurrent chunking feature,
 *    but is now required in all cases if you are making use of this PHP example.
 */

$userName = $_GET['user'];

define("MAXIMUM_WIDTH", 480);
define("MAXIMUM_HEIGHT", 480);
 
// Include the upload handler class
require_once "handler.php";

$uploader = new UploadHandler();

// Specify the list of valid extensions, ex. array("jpeg", "xml", "bmp")
$uploader->allowedExtensions = array( "jpeg","jpg","tiff","bmp","png","svg", "gif", "mp4", "flv"); // all files types allowed by default

// Specify max file size in bytes.
$uploader->sizeLimit = 1073741824;	// 1 Gib!
// 10 * 1024 * 1024; // default is 10 MiB

// Specify the input name set in the javascript.
$uploader->inputName = "qqfile"; // matches Fine Uploader's default inputName value by default

// If you want to use the chunking/resume feature, specify the folder to temporarily save parts.
$uploader->chunksFolder = "chunks";

$method = $_SERVER["REQUEST_METHOD"];
if ($method == "POST") 
{
    header("Content-Type: text/plain");

	//var_dump( $_POST);
	/*
		["qqpartindex"]=>
		string(1) "0"
		["qqpartbyteoffset"]=>
		string(1) "0"
		["qqchunksize"]=>
		string(6) "209855"
		["qqtotalparts"]=>
		string(1) "1"
		["qqtotalfilesize"]=>
		string(6) "209855"
		["qqfilename"]=>
		string(6) "oz.jpg"
		["qquuid"]=>
		string(36) "f73e24bf-eb6c-4662-ae33-895c447c1a9c"
	*/
    // Assumes you have a chunking.success.endpoint set to point here with a query parameter of "done".
    // For example: /myserver/handlers/endpoint.php?done
    if (isset($_GET["done"])) 
	{
        $result = $uploader->combineChunks("files");
		
	} else {
       
		// Handles upload requests
		// Call handleUpload() with the name of the folder, relative to PHP's getcwd()
        $result = $uploader->handleUpload("files");
    }
	
	$result["uploadName"] = $uploader->getUploadName();
	
	// This was just a section so let us just return what we know at this stage
	if ($result["chunk"] == true )
	{
		// To return a name used for uploaded file you can use the following line.
        echo json_encode($result);
		
	}else {
		
		$outputDir =  "files/" . $result["uuid"] . '/';
		
		$url =  $outputDir . $result["uploadName"];

		list($width, $height, $type, $attr) = getimagesize( $url);
		
		$result["type"] = $type;
		$result["width"] = $width;
		$result["height"] = $height;
		
		/*
			Result like this -
			
			Width: 200
			Height: 100
			Type: 2
			Attribute: width = '200' height = '100'
			
			Type of image consider like -
			
			1 = GIF
			2 = JPG
			3 = PNG
			4 = SWF
			5 = PSD
			6 = BMP
			7 = TIFF(intel byte order)
			8 = TIFF(motorola byte order)
			9 = JPC
			10 = JP2
			11 = JPX
			12 = JB2
			13 = SWC
			14 = IFF
			15 = WBMP
			16 = XBM
		*/

		switch ($type) 
		{
			// Jpeg
			case 2:
			// TIFF
			case 7:
			case 8:
			
				// get EXIF data...
				require_once "metadata.php";
				
				$meta = new MetaDataHandler();
				$gps = $meta->getMetaData( $url );
				
				if (array_key_exists('latitude', $gps) && array_key_exists('longitude', $gps) )
				{
					$result["lat"] = $gps["latitude"];
					$result["long"] = $gps["longitude"];
				}
			
				break;
				
			// Video files...
			case NULL:
				$result["type"] = $type = 20;
				// lame I know...
				$result["width"] = 960;
				$result["height"] = 540;
				break;
				
			default:	
		}

		// Now resize any image that is simply TOO large
		if (( $type < 20 ) && (( $width > MAXIMUM_WIDTH ) || ($height > MAXIMUM_HEIGHT ) ))
		{
			// image was simply TOO big!
			
			/*
			success : true, 
			uuid : 33b0e913-a531-4294-8378-67b13a855c9d, 
			uploadName : largemelissaleewilliams.jpg
			
			 * easy image resize function
			 * @param $file - file name to resize
			 * @param $string - The image data as a string, default is null
			 * @param $width - new image width
			 * @param $height - new image height
			 * @param $proportional - keep image proportional, default is no
			 * @param $output - name of the new file (include path if needed)
			 * @param $delete_original - if true the original image will be deleted
			 * @param $use_linux_commands - if set to true will use "rm" to delete the image, if false will use PHP unlink
			 * @param $quality - enter 1-100 (100 is best quality) default is 100
			 * @return boolean|resource
			 */
			
			require_once "resizer.php";
			
			// indicate which file to resize (can be any type jpg/png/gif/etc...)
			// indicate the path and name for the new resized file
			$resizedFile = $outputDir . '_' . $result["uploadName"];
			
			// create thumbnail
			$scaled = smart_resize_image($url , null, MAXIMUM_WIDTH , MAXIMUM_HEIGHT , $resizedFile , false , false ,100 );
			
			if ($scaled['success'])
			{
				$result["resized"] = true;
				$result["width"] = $scaled['width'];
				$result["height"] = $scaled['height'];
				//$result["originalWidth"] = $scaled['width'];
				//$result["originalHeight"] = $scaled['height'];
				$result["uploadName"] = '_' . $result["uploadName"];
			}else {
				// Resize failed and now we have to use the giant one ;(
				$result["resized"] = false;
			}
			
		}else {
			// Too small to resize
			$result["resized"] = false;
		}
		
		$result["user"] = $userName;
		
		$output = json_encode($result);
		
		// Save to JSON file if upload was successful otherwise don't
		if ( isset($result['success']) && !!$result['success'] )
		{
			// append json to data file if success = true!
			$saved = !!file_put_contents("images.json", $output . ',', FILE_APPEND);
			/*
			if (!$saved)
			{
				// failure
				// echo 'unable to save to file';
			}
			*/
			// save individual in csae of bad shit happenin down the line...
			$saved = !!file_put_contents( $outputDir . "item.json", $output);
			/*
			if (!$saved)
			{
				// failure
				// echo 'unable to save to file';
			}
			*/
		}
		
		echo $output;
	}
	// End
}
/*
else if ($method == "DELETE") {

	// for delete file requests
    $result = $uploader->handleDelete("files");
    echo json_encode($result);
	
} 
*/
else {

	// Called directly without correct arguments...
    header("HTTP/1.0 405 Method Not Allowed");
}

?>