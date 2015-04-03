package services;

import php.Lib;
import php.Web;
import php.FileSystem;
import haxe.Json;

class RetreiveImages
{

	public function new() 
	{
		var folder = FileSystem.readDirectory("./");
		
		for (file in folder) 
		{
            if (file != "index.php") {
                print '<BR><img src="' + file + '">'
                count++
            }
        }
	}
	
}