package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashk.core.UIConst;
	import flashk.utils.ClassFactory;
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
		
		private var _itemRender:*;
		/**
		 * 列表实例
		 */
		public var list:List;
		public var selectedHandler:Function;
		
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
		
		public var listRect:Rectangle;
		public var listSpace:int=3;
		
		
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
		
		public function ComboBox(skin:*=null, replace:Boolean=true,fields:Object=null, autoRefreshLabelField:Boolean = true,itemRender:* = null)
		{
			if (!skin)
				skin = defaultSkin;
			
			if (fields)
				this.fields = fields;
			
			this._itemRender = itemRender;
			
			super(skin, replace, autoRefreshLabelField);
			
			this.mouseChildren = true;
		}
		/** @inheritDoc*/
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			
			openButton = new Button(content[fields.openButtonField],true,true);
			
			var listSkin:DisplayObject = content[fields.listField] as DisplayObject;
			if(listSkin)
				listRect = new Rectangle(listSkin.x,listSkin.y,listSkin.width,listSkin.height);
			else
				listRect = new Rectangle(0,0,this.width,this.height);
			
			list = new List(listSkin,true,UIConst.VERTICAL,_itemRender);
			list.width = int(listRect.width);
			var rh:int = int(list.rowHeight * maxLine);
			list.height = listRect.height>rh?listRect.height:rh;
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
			if(listRect.width<this.width)
			{
				list.x = listPos.x+this.width-listRect.width;
			}else{
				list.x = listPos.x+listRect.x;
			}
			if(listRect.height>content.height)
			{
				list.y = listPos.y + ((direction == UIConst.UP) ? listRect.height-list.height: listRect.height+content.height+listSpace);
			}else{
				list.y = listPos.y + ((direction == UIConst.UP) ? -list.listHeight : content.height);
			}
			
			this.listContainer.addChild(list);
			
			if (list.vScrollBar==null&&(listData.length > maxLine || listData.length == 0))//listData有时候会莫名其妙length = 0，暂时这样处理
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
			if(selectedHandler!=null)
				selectedHandler(list.selectedData);
			this.data = list.selectedData;
			if(hideListOnClick)
				hideList();
		}
		
		private function hideList():void
		{
			if (list.parent == listContainer)
			{
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