package flashk.parse.graphics
{
	import flash.display.Graphics;
	
	import flashk.parse.DisplayParse;
	
	public class GraphicsEndFill extends DisplayParse
	{
		/** @inheritDoc*/
		public override function parseGraphics(target:Graphics) : void
		{
			super.parseGraphics(target);
			target.endFill();
		}
	}
}