package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import flashk.display.UIBase;
	import flashk.utils.Geom;

	/**
	 * 重写了width,height使得scale保持为1的显示对象，大部分组件类的基类
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-6 下午2:30:51
	 * */     
	public class NoScale extends UIBase
	{
		private var _height:Number;
		private var _width:Number;
		
		/**
		 * 是否接受皮肤的大小 
		 */
		public var enabledAutoSize:Boolean = true;
		
		public function NoScale(skin:*=null,replace:Boolean=true)
		{
			super(skin,replace);
			this.sizeCall.frame = false;
		}
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			
			if (enabledAutoSize)
				autoSize();
		}
		
		/**
		 * 根据内容调整大小
		 * 
		 */
		public function autoSize():void
		{
			if (content)
			{
				_width = content.width;
				_height = content.height;
			}
		}
		public override function get width():Number
		{
			return _width ? _width : super.width;
		}
		
		public override function set width(v:Number):void
		{
			if (_width == v)
				return;
			
			_width = v;
			invalidateSize();
		}
		public override function get height():Number
		{
			return _height ? _height : super.height;
		}
		
		public override function set height(v:Number):void
		{
			if (_height == v)
				return;
			
			_height = v;
			invalidateSize();
		}
		
		/**
		 * 是否已经手动设置过大小
		 * @return 
		 * 
		 */
		public function get sized():Boolean
		{
			return _height || _width;
		}
		
		public override function setSize(width:Number, height:Number, noEvent:Boolean=false) : void
		{
			if (_width == width && _height == height)
				return;
			
			_width = width;
			_height = height;
			
			vaildSize(noEvent);
		}
		
		public override function getRect(targetCoordinateSpace:DisplayObject):Rectangle
		{
			if (sized)
				return Geom.localRectToContent(new Rectangle(0,0,width,height),this,targetCoordinateSpace);
			else
				return super.getRect(targetCoordinateSpace)
		}
		override protected function updateSize():void
		{
			super.updateSize();
			updateDisplayList();
		}  
	}
}