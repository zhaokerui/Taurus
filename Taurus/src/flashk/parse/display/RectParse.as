package flashk.parse.display
{
	import flash.display.Graphics;
	
	import flashk.parse.graphics.GraphicsRect;
	import flashk.parse.graphics.IGraphicsFill;
	import flashk.parse.graphics.IGraphicsLineStyle;
	
	/**
	 * 方框 
	 * @author kerry
	 * 
	 */
	public class RectParse extends ShapeParse
	{
		public var rect:GraphicsRect;
		
		public function RectParse(rect:GraphicsRect, line:IGraphicsLineStyle=null, fill:IGraphicsFill=null,grid9:Grid9Parse=null,reset:Boolean = false)
		{
			super(null, line, fill, grid9, reset);
			
			this.rect = rect;
		}
		/** @inheritDoc*/
		protected override function parseBaseShape(target:Graphics) : void
		{
			super.parseBaseShape(target);
			
			if (rect)
				rect.parseGraphics(target);	
		}
	}
}