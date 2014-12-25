package flashk.events
{
	import flash.events.Event;
	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-8 下午4:09:51
	 * */     
	public class ActionEvent extends Event
	{
		/**
		 * 指令事件
		 */
		public static const ACTION:String = "action";
		
		/**
		 * 指令
		 */
		public var action:String;
		
		/**
		 * 参数
		 */
		public var parameters:Array;
		
		public function ActionEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone() : Event
		{
			var evt:ActionEvent = new ActionEvent(type,bubbles,cancelable);
			evt.action = this.action;
			evt.parameters = this.parameters;
			return evt;
		}
	}
}

