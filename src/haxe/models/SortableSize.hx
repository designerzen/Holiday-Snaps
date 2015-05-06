/*

Part of the Rectangle packing class from :
https://github.com/isBatak/RectanglePacker/blob/master/out/production/RectanglePacker/utils/SortableSize.hx
*/
package models;

class SortableSize
{
	public var width:Int;
    public var height:Int;
    public var id:Int;
	
	public function new( startWidth:Int, startHeight:Int, uniqueId:Int) 
	{
        width = startWidth;
        height = startHeight;
        id = uniqueId;
    }
	
}