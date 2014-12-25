package flashk.events
{
	import flash.display.InteractiveObject;
	import flash.events.Event;

	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-7-4 下午4:52:24
	 * */     
	public class ItemClickEvent extends Event
	{
		public static const ITEM_CLICK:String = "item_click";
		
		public var data:*;
		
		public var relatedObject:InteractiveObject;
		
		public function ItemClickEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:ItemClickEvent = new ItemClickEvent(type,bubbles,cancelable);
			evt.data = this.data;
			evt.relatedObject = this.relatedObject;
			return evt;
		}
	}
}