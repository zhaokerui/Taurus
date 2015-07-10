package flashk.layout
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashk.utils.Geom;

	/**
	 * 边框数据对象
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-7-5 下午4:55:36
	 * */     
	public class Padding
	{
		public var left:Number;
		public var right:Number;
		public var top:Number;
		public var bottom:Number;
		
		public function Padding(left:Number = NaN,top:Number = NaN,right:Number = NaN,bottom:Number = NaN)
		{
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
		}
		
		/**
		 * 根据属性更正矩形大小
		 * 
		 * @param rect	需要更正的矩形
		 * @param parent	父矩形
		 * 
		 */
		public function adjectRect(rect:*,parent:*):void
		{
			parent = Geom.getRect(parent,parent);
			
			if (!isNaN(left))
				rect.x = int(parent.x + left);
			
			if (!isNaN(top))
				rect.y = int(parent.y + top);
			
			if (!isNaN(right))
				rect.width = int(parent.right - right - rect.x);
			
			if (!isNaN(bottom))
				rect.height = int(parent.bottom - bottom - rect.y);		
		}
		
		/**
		 * 根据更正两个同级矩形的大小
		 * 
		 * @param rect	需要更正的矩形
		 * @param rect2	源矩形
		 * 
		 */
		public function adjectRectBetween(rect:*,rect2:*):void
		{
			if (!isNaN(left))
				rect.x = int(rect2.x + left);
			
			if (!isNaN(top))
				rect.y = int(rect2.y + top);
			
			if (!isNaN(right))
				rect.width = int(rect2.x + rect2.width - right - rect.x);
			
			if (!isNaN(bottom))
				rect.height = int(rect2.y + rect2.height - bottom - rect.y);
			
			//处理注册点问题
			var dis:DisplayObject = rect as DisplayObject
			if (dis)
			{
				var pRect:Rectangle = Geom.getRect(dis);
				dis.x -= int(pRect.x - dis.x);
				dis.y -= int(pRect.y - dis.y);
			}
		}
		
		/**
		 * 取反
		 * @return 
		 * 
		 */
		public function invent():Padding
		{
			return new Padding(-left,-top,-right,-bottom)
		}
		
		/**
		 * 复制 
		 * @return 
		 * 
		 */
		public function clone():Padding
		{
			return new Padding(left,top,right,bottom)
		}
	}
}