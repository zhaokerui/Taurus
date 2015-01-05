package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flashk.core.UIConst;
	import flashk.utils.Geom;
	
	import taurus.skin.ComboBoxSkin;
	

	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-5 下午10:57:34
	 * */     
	public class ComboBox extends Button
	{
		public static var defaultSkin:* = ComboBoxSkin;
		
		public var fields:Object = {listField:"list",openButtonField:"openButton"};
		
		/**
		 * 列表实例
		 */
		public var list:List;
		
		/**
		 * 展开按钮
		 */
		public var openButton:Button;
		
		/**
		 * 列表属性
		 */
		public var listData:Array;
		
		private var _direction:String = UIConst.DOWN;
		
		/**
		 * 承载List的容器
		 */
		public var listContainer:DisplayObjectContainer;
		
		
		/**
		 * 点击选择
		 */
		public var hideListOnClick:Boolean = true;
		
		private var _maxLine:int = 6;
		
		/**
		 * 弹出下拉框的方向（"up","down"）
		 */
		public function get direction():String
		{
			return _direction;
		}
		
		public function set direction(value:String):void
		{
			_direction = value;
		}
		
		/**
		 * 最大显示List条目
		 * @return 
		 * 
		 */
		public function get maxLine():int
		{
			return _maxLine;
		}
		
		public function set maxLine(v:int):void
		{
			_maxLine = v;
			if (list)
				list.height = list.rowHeight * maxLine;
		}
		
		public function ComboBox(skin:*=null, replace:Boolean=true,fields:Object=null, autoRefreshLabelField:Boolean = true)
		{
			if (!skin)
				skin = defaultSkin;
			
			if (fields)
				this.fields = fields;
			
			super(skin, replace, autoRefreshLabelField);
			
			this.mouseChildren = true;
		}
		/** @inheritDoc*/
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			
			var listField:String = fields.listField;
			var openButtonField:String = fields.openButtonField;
			
			openButton = new Button(content[openButtonField],true,true);
			
			list = new List(content[listField],true,UIConst.VERTICAL);
			list.width = int(this.width);
			list.height = int(list.rowHeight * maxLine);
			if (list.parent)
				list.parent.removeChild(list);
		}
		/** @inheritDoc*/
		protected override function mouseDownHandler(event:MouseEvent) : void
		{
			super.mouseDownHandler(event);
			
			if (list.parent)
			{
				hideList();
				return;
			}
			if(listData==null)
				return;
			var listPos:Point = Geom.localToContent(new Point(),this,listContainer)
			list.data = listData;
			list.addEventListener(Event.CHANGE,listChangeHandler);
			list.x = listPos.x;
			list.y = listPos.y + ((direction == UIConst.UP) ? -list.height : content.height);
			
			this.listContainer.addChild(list);
			
			if (listData.length > maxLine || listData.length == 0)//listData有时候会莫名其妙length = 0，暂时这样处理
				list.addVScrollBar();
			
		}
		/** @inheritDoc*/
		protected override function init():void
		{
			super.init();
			
			if (!this.listContainer)
				this.listContainer = this.root as DisplayObjectContainer;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN,stageMouseDownHandler);
		}
		
		private function stageMouseDownHandler(event:Event):void
		{
			var s:DisplayObject = event.target as DisplayObject;
			while (s.parent && s.parent != s.stage)
			{
				if (s == list || (list && s == list.vScrollBar) || s == this)
					return;
				s = s.parent;
			}
			
			hideList();
		}
		
		private function listChangeHandler(event:Event):void
		{
			this.data = list.selectedData;
			if(hideListOnClick)
				hideList();
		}
		
		private function hideList():void
		{
			if (list.parent == listContainer)
			{
				list.removeVScrollBar();
				this.listContainer.removeChild(list);
			}
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_DOWN,stageMouseDownHandler);
			
			super.destory();
			
			if (list)
			{
				list.removeEventListener(Event.CHANGE,listChangeHandler);
				list.destory();
			}
		}
	}
}