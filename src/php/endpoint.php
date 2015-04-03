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

// Include the upload handler class
require_once "handler.php";

$uploader = new UploadHandler();

// Specify the list of valid extensions, ex. array("jpeg", "xml", "bmp")
$uploader->allowedExtensions = array(); // all files types allowed by default

// Specify max file size in bytes.
$uploader->sizeLimit = 10 * 1024 * 1024; // default is 10 MiB

// Specify the input name set in the javascript.
$uploader->inputName = "qqfile"; // matches Fine Uploader's default inputName value by default

// If you want to use the chunking/resume feature, specify the folder to temporarily save parts.
$uploader->chunksFolder = "chunks";

$method = $_SERVER["REQUEST_METHOD"];
if ($method == "POST") 
{
    header("Content-Type: text/plain");

    // Assumes you have a chunking.success.endpoint set to point here with a query parameter of "done".
    // For example: /myserver/handlers/endpoint.php?done
    if (isset($_GET["done"])) 
	{
        $result = $uploader->combineChunks("files");
		
	} else {
        // Handles upload requests
		// Call handleUpload() with the name of the folder, relative to PHP's getcwd()
        $result = $uploader->handleUpload("files");
		
        // To return a name used for uploaded file you can use the following line.
        $result["uploadName"] = $uploader->getUploadName();
    }

	// create thumnbail?
	//indicate which file to resize (can be any type jpg/png/gif/etc...)
	$url = $result["uuid"] . '/' . $result["uploadName"];
	//indicate the path and name for the new resized file
	$resizedFile = $result["uuid"] . '/_' . $result["uploadName"];

	/**
	//require_once "metadata.php";
	require_once "resizer.php";
	
	
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
	 
	smart_resize_image($url , null, 1024 , SET_YOUR_HIGHT , true , $resizedFile , false , false ,100 );
	 */
	
	list($width, $height, $type, $attr) = getimagesize( "files/" . $url);
	
	$output = '{';
	$output .= '"url":' . '"' . $url . '"';
	$output .= ',';	
	
	$output .= '"width":' . '"' . $width . '"';
	$output .= ',';	
	
	$output .= '"height":' . '"' . $height . '"';
	$output .= '},';
	/*

		Result like this -

		Width: 200
		Height: 100
		Type: 2
		Attribute: width='200' height='100'

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
	// get EXIF data...
	
	// append json to data file
	if (!file_put_contents("images.json", $output, FILE_APPEND))
	{
		// failure
		// echo 'unable to save to file';
	}
	echo json_encode($result);
	
} else if ($method == "DELETE") {

	// for delete file requests

    $result = $uploader->handleDelete("files");
    echo json_encode($result);
	
} else {

	// Called directly without correct arguments...
    header("HTTP/1.0 405 Method Not Allowed");
}

?>
