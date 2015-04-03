extern class UploadHandler {

    public var allowedExtensions = [];
    public var sizeLimit = null;
    public var inputName = 'qqfile';
    public var chunksFolder = 'chunks';

    public var chunksCleanupProbability = 0.001; 	// Once in 1000 requests on avg
    public var chunksExpireIn = 604800; 			// One week

    public function __construct():Void;

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
    public function handleUpload(uploadDirectory:String, name:String=null) : Array;

    /**
     * Process a delete.
     * @param uploadDirectory Target directory.
     * @params string $name Overwrites the name of the file.
     */
    public function handleDelete(uploadDirectory:String, name:String=null) : Array;

}