package services;

import php.Lib;
import php.Web;
import haxe.Json;

extern class UploadHandler
{
    public var allowedExtensions:Array<String>;
    public var sizeLimit:Dynamic;
    public var inputName:String;
    public var chunksFolder:String;

    public var chunksCleanupProbability:Float; 	// Once in 1000 requests on avg
    public var chunksExpireIn:Int; 			// One week

	public function new():Void;
	
    /**
     * Get the original filename
     */
    public function getName():String;

    /**
     * Get the name of the uploaded file
     */
    public function getUploadName():String;

    public function combineChunks(uploadDirectory:String) : Void;

    /**
     * Process the upload.
     * @param uploadDirectory Target directory.
     * @param name Overwrites the name of the file.
     */
    public function handleUpload(uploadDirectory:String, name:String=null) : Dynamic;

    /**
     * Process a delete.
     * @param uploadDirectory Target directory.
     * @params string $name Overwrites the name of the file.
     */
    public function handleDelete(uploadDirectory:String, name:String = null) : Dynamic;
}

class UploadService
{
	static function main()
	{
        var params = Web.getParams();
		new UploadService();
    }
	
	public function new() 
	{
		// import php file
    	untyped __call__("import", "handler.php");
		
		var uploader:UploadHandler = new UploadHandler();

		// Specify the list of valid extensions, ex. array("jpeg", "xml", "bmp")
		uploader.allowedExtensions = []; // all files types allowed by default

		// Specify max file size in bytes.
		uploader.sizeLimit = 10 * 1024 * 1024; // default is 10 MiB

		// Specify the input name set in the javascript.
		uploader.inputName = "qqfile"; // matches Fine Uploader's default inputName value by default

		// If you want to use the chunking/resume feature, specify the folder to temporarily save parts.
		uploader.chunksFolder = "chunks";

		
		// Get the Request Type from the Server...
		trace('Beyatch!');
	}
	
}

/*
method = _SERVER.getset("REQUEST_METHOD");

if (method == "POST") 
{
    php.Web.setHeader("Content-Type: text/plain");

    // Assumes you have a chunking.success.endpoint set to point here with a query parameter of "done".
    // For example: /myserver/handlers/endpoint.php?done
    if (isset(php.Web.getParams().get("done")))
	{
        result = uploader.combineChunks("files");
    } else {
        // Handles upload requests
		// Call handleUpload() with the name of the folder, relative to PHP's getcwd()
        result = uploader.handleUpload("files");

        // To return a name used for uploaded file you can use the following line.
        result.set("uploadName") = uploader.getUploadName();
    }

    echo StringTools.jsonEncode(result);
	
} else if (method == "DELETE") {
	
	// for delete file requests
    result = uploader.handleDelete("files");
    echo StringTools.jsonEncode(result);
	
} else {
	
    php.Web.setHeader("HTTP/1.0 405 Method Not Allowed");
}*/
