package flashk.utils.load
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	[Event(name="init",type="flash.events.Event")]
	
	[Event(name="complete",type="flash.events.Event")]
	
	[Event(name="progress",type="flash.events.ProgressEvent")]
	/**
	 * 和FLEX类似的二帧自加载方法，可以自行实现立即显示的Loading进度条，即使是在一个全部由代码组成的SWF中。
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-4 下午5:29:26
	 * */     
	public class RootLoaderBase extends MovieClip
	{
		/**
		 * 是否加载完成
		 */
		public var loadCompleted:Boolean = false;
		public function RootLoaderBase()
		{	
			if (this["constructor"] == RootLoaderBase)  
				throw new IllegalOperationError("RootLoaderBase 类为抽象类，不允许实例化!");
			
			this.gotoAndStop(1);
			
			root.loaderInfo.addEventListener(Event.INIT, initHandler);
		}
		
		protected function initHandler(event:Event):void
		{
			dispatchEvent(event);
			
			root.loaderInfo.removeEventListener(Event.INIT, initHandler);
			
			root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			root.loaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		
		//Complete事件失效时的备用处理
		private function enterFrameHandler(event:Event):void
		{
			if (root.loaderInfo.bytesLoaded == root.loaderInfo.bytesTotal)
				completeHandler(new Event(Event.COMPLETE));
		}
		
		protected function completeHandler(event:Event):void
		{
			if (loadCompleted)
				return;
			
			this.gotoAndStop(2);
			
			root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			root.loaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
			
			dispatchEvent(event);
			
			loadComplete();
			
			loadCompleted = true;
		}
		
		protected function progressHandler(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 获得主要SWF实例 
		 * @return 
		 * 
		 */
		protected function getMainSWF():DisplayObject
		{
			var name:String = this.loaderInfo.loaderURL.match(/[^\/]*\.swf/i)[0];
			var urlArr:Array = name.split(/\/+|\\+|\.|\?/ig);
			name = decodeURI(urlArr[urlArr.length - 2]);
			return new (getDefinitionByName(name) as Class);
		}
		
		/**
		 * 完成载入，实例化主场景时执行的方法。可以重写这个方法以显示一段进入主场景的动画。
		 * 
		 */		
		protected function loadComplete():void 
		{
			stage.addChildAt(getMainSWF(),0);
			stage.removeChild(this);
		}
	}
}


