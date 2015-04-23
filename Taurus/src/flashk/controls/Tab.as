package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import flashk.display.UIBase;
	
	
	/**
	 * 标签切换显示容器
	 * 
	 * 标签规则：子对象成为不同的View，只显示其中一个
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class Tab extends UIBase
	{
		/**
		 * 标签栏 
		 */		
		public var repeater:Repeater;
		/**
		 * 标签 单个 区域
		 */		
		public var repeaterRect:Rectangle;
		/**
		 * 标签布局 默认水平 
		 */		
		public var repeaterType:String="horizontal";
		/**
		 * 显示  区域
		 */		
		public var viewRect:Rectangle;
		/**
		 * 选择事件,参数(index:int,v:*) 
		 */		
		public var selectedHandler:Function;
		
		protected var _list:Array=[];
		protected var _selectedIndex:int = -1;
		protected var _tabList:Array;
		private var fields:Object = {tabField:"tab",viewField:"view"};
		
		public function Tab(skin:* = null,replace:Boolean = true,tabList:Array = null,type:String = null,fields:Object = null)
		{
			if(!skin)
				skin = new Sprite();
			if (fields)
				this.fields = fields;
			_tabList = tabList;
			if(type)
				repeaterType = type;
			super(skin, replace);
		}
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			
			var tabSkin:DisplayObject = skin.getChildByName(fields.tabField);
			if(tabSkin)
				repeaterRect = new Rectangle(tabSkin.x,tabSkin.y,tabSkin.width,tabSkin.height);
			
			if (tabSkin && tabSkin.parent)
				tabSkin.parent.removeChild(tabSkin);
			
			creatButton(skin);
			
			var viewSkin:DisplayObject = skin.getChildByName(fields.viewField);
			if(viewSkin)
				viewRect = new Rectangle(viewSkin.x,viewSkin.y,viewSkin.width,viewSkin.height);
			
			if (viewSkin && viewSkin.parent)
				viewSkin.parent.removeChild(viewSkin);
			
			creatView(skin);
		}
		protected function creatButton(skin:*):void
		{
			var mc:*;
			var index:uint=1;
			var btn:Button;
			while(true)
			{
				mc = skin.getChildByName(fields.tabField+index);
				if(mc==null)break;
				btn = new Button(mc);
				btn.data = index;
				if(repeater==null)
				{
					addRepeater();
				}
				repeater.addChild(btn);
				mc = null
				index++;
			}
		}
		protected function creatView(skin:*):void
		{
			if(_tabList==null)return;
			
			var len:int = _tabList.length;
			var mc:*;
			for(var i:int=0;i<len;i++)
			{
				mc = skin.getChildByName(fields.viewField+(i+1));
				_list.push(new _tabList[i](mc));
			}
		}
		/**
		 * 对象容器 
		 */
		public function get contentView():DisplayObjectContainer
		{
			return content as DisplayObjectContainer;
		}
		
		/**
		 * 选择显示的容器 
		 * @return 
		 * 
		 */
		public function get selectedView():DisplayObject
		{
			if (_selectedIndex == -1)
				return null;
			else if (_selectedIndex >= _list.length)
				return null;
			else
				return _list[_selectedIndex];
		}
		
		public function set selectedView(v:DisplayObject):void
		{
			var len:int = _list.length;
			for(var i:int=0;i<len;i++)
			{
				if (v == _list[i])
				{
					selectedIndex = i;
					return;
				}
			}
			selectedIndex = -1;
		}
		
		/**
		 * 选择的容器的索引
		 * @return 
		 * 
		 */
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedIndex(v:int):void
		{
			setSelectIndex(v);
		}
		
		public function setSelectIndex(v:int):void
		{
			if (_selectedIndex == v)
				return;
			
			if (_selectedIndex != -1 && _selectedIndex < _list.length)
			{
				var page:DisplayObject = _list[_selectedIndex];
				if(page.parent)
					page.parent.removeChild(page);
			}
			
			_selectedIndex = v;
			
			if (_selectedIndex != -1 && _selectedIndex < _list.length)
			{
				var dis:DisplayObject = _list[_selectedIndex];
				if(viewRect)
				{
					contentView.x = viewRect.x;
					contentView.y = viewRect.y;
				}
				contentView.addChild(dis);
			}
		}
		/**
		 * 生成显示
		 * @param skin
		 * 
		 */
		public function addView(skin:*):void
		{
			_list.push(skin);
		}
		/**
		 * 设置多个显示
		 * @param v 数组
		 * 
		 */		
		public function set viewData(v:*) : void
		{
			_list = v;
		}
		/**
		 * 获得显示
		 * @param v 索引
		 * @return 
		 * 
		 */		
		public function getView(v:uint):*
		{
			if (_list.length == 0||v>=_list.length)return null;
			return _list[v];
		}
		/**
		 * 清除显示容器
		 * 
		 */		
		public function removeView():void
		{
			var len:int = _list.length;
			for(var i:int=0;i<len;i++)
			{
				_list.pop().destory();
			}
		}
		/**
		 * 生成标签容器
		 * @param skin
		 * 
		 */
		public function addRepeater(skin:*=null, replace:Boolean=true, ref:*=null,type:String = null):void
		{
			if(type)
				repeaterType = type;
			
			removeRepeater();
			
			
			repeater = new Repeater(skin,replace,ref,repeaterType);
			repeater.toggleOnClick = true;
			repeater.addEventListener(Event.CHANGE,onChange);
			
			$addChildAt(repeater,0);
			if(repeaterRect)
			{
				repeater.x = repeaterRect.x;
				repeater.y = repeaterRect.y;
			}
		}
		public function addChildRepeater(skin:*,index:uint):void
		{
			if(repeater==null)
			{
				addRepeater();
			}
			var btn:Button=new Button(skin);
			btn.data=index;
			repeater.addChild(btn);
		}
		/**
		 * 删除标签容器
		 * 
		 */
		public function removeRepeater():void
		{
			if (repeater)
			{
				repeater.removeEventListener(Event.CHANGE,onChange);
				repeater.destory();
				repeater = null;
			}
		}
		private function onChange(evt:Event):void
		{
			var index:int = repeater.selectedData;
			selectedIndex = index-1;
			if(selectedHandler!=null)
				selectedHandler(index,getView(index-1));
		}
		/**
		 * 选择的数据 
		 * @return 
		 * 
		 */
		public function get selectedData():*
		{
			return repeater.selectedData;
		}
		
		public function set selectedData(v:*):void
		{
			repeater.selectedData = v;
		}
		/**
		 *  
		 * 设置多个标签 
		 * @param v 数组
		 * 
		 */		
		public override function set data(v:*) : void
		{
			if(repeater)
				repeater.data = v;
		}
		public override function destory():void
		{
			if (destoryed)
				return;
			
			removeRepeater();
			removeView();
			
			super.destory();
		}
		
	}
	
}