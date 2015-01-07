package flashk.parse
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * 图形解析
	 * 类似flash10的graphicData，将绘图操作对象化了。
	 * @author kerry
	 * 
	 */
	public class DisplayParse extends Parse
	{
		/** @inheritDoc*/
		public override function parse(target:*):void
		{
			super.parse(target);
			
			if (target is DisplayObject)
				parseDisplay(target as DisplayObject);
			if (target is DisplayObjectContainer)
				parseContainer(target as DisplayObjectContainer);
			if (target is Graphics)
				parseGraphics(target as Graphics);
			if (target is BitmapData)
				parseBitmapData(target as BitmapData);
			
			var graphics:Graphics = (target && target.hasOwnProperty("graphics"))?target["graphics"] as Graphics : null;
			if (graphics)
				parseGraphics(graphics);
		}
		
		/**
		 * 解析图形
		 * @param target
		 * 
		 */
		public function parseGraphics(target:Graphics):void
		{
			
		}
		
		/**
		 * 解析位图数据
		 * @param target
		 * 
		 */
		public function parseBitmapData(target:BitmapData):void
		{
			
		}
		
		/**
		 * 解析容器
		 * @param target
		 * 
		 */
		public function parseContainer(target:DisplayObjectContainer):void
		{
			
		}
		
		/**
		 * 解析显示对象
		 * @param target
		 * 
		 */
		public function parseDisplay(target:DisplayObject):void
		{
			
		}
		
		/**
		 * 创建Sprite
		 * 
		 * @param para
		 * @return 
		 * 
		 */
		public function createSprite():Sprite
		{
			var s:Sprite = new Sprite();
			parse(s);
			return s;
		}
		
		/**
		 * 创建Shape
		 * 
		 * @param para
		 * @return 
		 * 
		 */
		public function createShape():Shape
		{
			var s:Shape = new Shape();
			parse(s);
			return s;
		}
		
		/**
		 * 创建图形解析
		 * 
		 * @param para
		 * @return 
		 * 
		 */
		public static function create(para:Array):DisplayParse
		{
			var p:DisplayParse = new DisplayParse();
			p.children = para;
			return p;
		}
		
		/**
		 * 创建Sprite图形解析
		 * 
		 * @param para
		 * @return 
		 * 
		 */
		public static function createSprite(para:Array):Sprite
		{
			var s:Sprite = new Sprite();
			create(para).parse(s);
			return s;
		}
		
		/**
		 * 创建Shape图形解析
		 * 
		 * @param para
		 * @return 
		 * 
		 */
		public static function createShape(para:Array):Shape
		{
			var s:Shape = new Shape();
			create(para).parse(s);
			return s;
		}
	}
}