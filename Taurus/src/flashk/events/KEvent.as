package flashk.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-4 下午3:49:18
	 * */       
	public class KEvent extends Event
	{
		/**
		 * 更新事件
		 */
		public static const UPDATE_COMPLETE:String = "update_complete";
		
		/**
		 * 创建完毕
		 */
		public static const CREATE_COMPLETE:String = "create_complete";
		
		/**
		 * 显示事件（可中断）
		 */
		public static const SHOW:String = "show";
		
		/**
		 * 隐藏事件（可中断）
		 */
		public static const HIDE:String = "hide";
		
		/**
		 * 数据变化
		 */
		public static const DATA_CHANGE:String = "data_change";
		public static const RESIZE:String = "resize";
		/**
		 * 子对象大小变化
		 */
		public static const CHILD_RESIZE:String = "child_resize"
		
		public static const REMOVE:String = "remove";
		public static const MOVE:String = "move";
		/**
		 * 缩放前的大小
		 */
		public var old:Point;
		/**
		 * 缩放后新的大小
		 */
		public var now:Point;
		/**
		 * 变化大小的子对象
		 */
		public var child:DisplayObject;
		/**
		 * 执行destory方法时触发的事件（可中断，若是直接被removeChild，即使触发了这个事件也无法中断了）
		 */
		
		public function KEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:KEvent = new KEvent(type,bubbles,cancelable);
			evt.old = this.old;
			evt.now = this.now;
			evt.child = this.child;
			return evt;
		}
	}
}

