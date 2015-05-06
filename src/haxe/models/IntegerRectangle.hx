/*

Part of the Rectangle packing class from :
https://github.com/isBatak/RectanglePacker/blob/master/out/production/RectanglePacker/utils/IntegerRectangle.hx

*/

package models;

class IntegerRectangle
{

	public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;
    public var right:Int;
    public var bottom:Int;
    public var id:Int;

    public function new( startX :Int = 0, startY:Int = 0, startWidth:Int = 0, startHeight:Int = 0) 
	{
		x = startX;
        y = startY;
		
        width = startWidth;
        height = startHeight;
		
        right = x + width;
        bottom = y + height;
    }
}