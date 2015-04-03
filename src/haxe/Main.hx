/*

So here it is, a very basic, single page web app that has various sections :
	
	1. A Password (hard coded and specific to site - mango)
	2. Photos homepage with an Add Your Photos / Videos button at the bottom
	3. Upload page with name at the top, then a drag-n-drop ui for adding photos, upload button at bottom
	4. Tags / Locations / Exif data etc done on server side

*/

package;

//import googleAnalytics.Stats;

class Main 
{
	
	static function main() 
	{
		//Stats.init('UA-27265081-3', 'testing.sempaigames.com');
        // Stats.init('UA-27265081-3', 'testing.sempaigames.com', true); /* in case you want to use SSL connections */
   
		new Mediator();
	}
	
}