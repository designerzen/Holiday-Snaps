<?php
	$fullPath = $_GET['file'];
	if ($fullPath) 
	{
		// check to see how to go locally...
		$fullPath = substr($fullPath, strpos($fullPath, "services/") + 9);
		
		$fsize = filesize($fullPath);
		$path_parts = pathinfo($fullPath);
		$ext = strtolower($path_parts["extension"]);
		switch ($ext) 
		{
			case "pdf":
				header("Content-Disposition: attachment; filename=\"".$path_parts["basename"]."\""); // use 'attachment' to force a download
				header("Content-type: application/pdf"); // add here more headers for diff. extensions
				break;
			default;
				header("Content-type: application/octet-stream");
				header("Content-Disposition: filename=\"".$path_parts["basename"]."\"");
		}
		if ($fsize) 
		{
			//checking if file size exist
			header("Content-length: $fsize");
		}
		readfile($fullPath);
		exit;
	}
?>