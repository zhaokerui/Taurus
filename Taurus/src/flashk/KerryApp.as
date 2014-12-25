package flashk
{
	import flash.geom.Rectangle;
	
	import flashk.core.PopupManager;
	import flashk.core.RootManager;
	import flashk.display.KSprite;
	import flashk.display.UIBase;
	import flashk.utils.Debug;
	
	/**
	 * UI部分的默认文档类。此类并不是必须的。
	 * @author kerry
	 * 
	 */
	public class KerryApp extends KSprite
	{
		public var application:UIBase;
		public var popupLayer:UIBase;
		
		public override function get width():Number
		{
			return stage.stageWidth;
		}
		
		public override function get height():Number
		{
			return stage.stageHeight;
		}
		
		public override function set width(v:Number):void
		{
			Debug.error("不允许设置宽度");
		}
		
		public override function set height(v:Number):void
		{
			Debug.error("不允许设置高度");
		}
		
		public function get bounds():Rectangle
		{
			return new Rectangle(0,0,width,height)
		}
		
		protected override function init():void
		{
			super.init();
			
			this.application = new UIBase();
			addChild(this.application);
			
			this.popupLayer = new UIBase();
			addChild(this.popupLayer);
			
			
			RootManager.register(this);
			PopupManager.instance.register(application,popupLayer);	
		}
	}
}