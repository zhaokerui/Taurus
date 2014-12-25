package flashk.display
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-20 下午6:25:07
	 * */ 
	public interface IBase
	{
		
		/**
		 * 是否激活
		 * @param v
		 * 
		 */
		function set enabled(v:Boolean):void
		function get enabled():Boolean;
		
		/**
		 * 是否暂停
		 * @param v
		 * 
		 */
		function set paused(v:Boolean):void
		function get paused():Boolean;
		
		/**
		 * 拥有者
		 * @param v
		 * 
		 */
		function set owner(v:DisplayObject):void
		function get owner():DisplayObject;
		
		/**
		 * 是否激活时基
		 * @param v
		 * 
		 */
		function set enabledTick(v:Boolean):void
		function get enabledTick():Boolean;
		
		/**
		 * 当前坐标
		 * 
		 */
		function get position():Point
		
		/**
		 * 当前旧坐标
		 * 
		 */
		function get oldPosition():Point
		/**
		 * 销毁方法
		 * 
		 */
		function destory():void
		
		
		/**
		 * 在之后更新大小
		 */
		function invalidateSize():void
		/**
		 * 在之后更新坐标
		 */
		function invalidatePosition():void		
		/**
		 * 在之后更新显示
		 */
		function invalidateDisplayList():void
		
		
		/**
		 * 更新大小并发事件 
		 */
		function vaildSize(noEvent:Boolean = false):void
		/**
		 * 更新坐标并发事件
		 */
		function vaildPosition(noEvent:Boolean = false):void
		/**
		 * 更新显示并发事件 
		 */
		function vaildDisplayList(noEvent:Boolean = false):void
	}
}