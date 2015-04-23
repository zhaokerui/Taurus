package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashk.display.IBase;
	import flashk.display.UIBase;
	import flashk.events.ItemClickEvent;
	import flashk.layout.LinearLayout;
	import flashk.layout.Padding;
	import flashk.utils.ClassFactory;
	
	[Event(name="change",type="flash.events.CHANGE")]
	[Event(name="item_click",type="flashk.events.ItemClickEvent")]
	/**
	 * 根据data复制对象排列的容器，或者不同对象排列的容器
	 * 
	 * 标签规则：这个对象并没有背景，skin将作为ItemRender的skin存在
	 * 
	 * @author kerry
	 * 
	 */
	public class Repeater extends Panel
	{
		public var ref:ClassFactory;
		
		public var hideNullItem:Boolean;
		public var renderSkin:ClassFactory;
		
		/**
		 * 是否点击选中
		 */
		public var toggleOnClick:Boolean;
		/**
		 * 是否显示文字 
		 */		
		public var autoLabelField:Boolean=false;
		public var separateTextField:Boolean=false;
		public var textPadding:Padding=null;
		
		private var _selectedData:*;
		private var _labelField:String;
		public var selectedHandler:Function;
		
		public function Repeater(skin:*=null, replace:Boolean=true, ref:*=null,type:String = "horizontal")
		{
			super(skin, replace);
			
			setContent(new Sprite());//重新设置Content，避免冲突
			setLayout(new LinearLayout());
			this.type = type;
			
			if (skin is DisplayObject)
				skin = skin["constructor"];
			
			if (skin is Class)
				this.renderSkin = new ClassFactory(skin)
			else if (skin is ClassFactory)
				this.renderSkin = skin as ClassFactory;
			
			if (ref is Class)
				this.ref = new ClassFactory(ref)
			else if (ref is ClassFactory)
				this.ref = ref as ClassFactory;
			
			this.contentPane.addEventListener(MouseEvent.CLICK,clickHandler);
			this.data = [];
			
			addEventListener(ItemClickEvent.ITEM_CLICK,itemClickHandler);
			
		}
		
		/**
		 * 线性布局 
		 * @return 
		 * 
		 */
		public function get linearLayout():LinearLayout
		{
			return layout as LinearLayout;
		}
		
		/**
		 * 布局方向 
		 * @return 
		 * 
		 */
		public function get type():String
		{
			return (layout as LinearLayout).type;
		}
		
		public function set type(v:String):void
		{
			(layout as LinearLayout).type = v;
		}
		
		/**
		 * 子对象渲染器 
		 * @return 
		 * 
		 */
		public function get itemRender():*
		{
			return ref;
		}
		
		public function set itemRender(v:*):void
		{
			if (v is Class)
				v = new ClassFactory(v);
			
			this.ref = v;
			//			render();
		}
		
		/**
		 * 刷新全部 
		 * 
		 */
		public function render():void
		{
			if (ref && renderSkin)
			{
				if (ref.params)
					ref.params[0] = renderSkin;
				else
					ref.params = [renderSkin];
				if(autoLabelField)
				{
					ref.params[1] = true;
					ref.params[2] = true;
					ref.params[3] = separateTextField;
					ref.params[4] = textPadding;
				}
			}
			
			var i:int;
			for (i = contentPane.numChildren - 1;i >= 0;i--)
			{
				var display:DisplayObject = contentPane.getChildAt(i);
				if (display is IBase)
					(display as IBase).destory();
				else
					contentPane.removeChild(display);
			}
			if (data && ref)
			{
				for (i = 0;i < data.length;i++)
				{
					if (data[i] != null || !hideNullItem)
					{	
						var obj:UIBase = ref.newInstance() as UIBase;
						contentPane.addChild(obj);
						if (obj is Button && _labelField)
							(obj as Button).labelField = _labelField;
						obj.data = data[i];
						obj.owner = self;
						obj.selected = obj.data && obj.data == selectedData;
					}
				}
			}
			layout.vaildLayout();
		}
		
		/**
		 * 单独刷新某个物体 
		 * @param i
		 * 
		 */
		public function renderItem(i:int):void
		{
			if (i < contentPane.numChildren)
			{
				var obj:UIBase = getChildAt(i) as UIBase;
				if (obj)
					obj.data = data[i];
			}
		}
		
		/**
		 * 单独刷新某个数据
		 * @param i
		 * 
		 */
		public function renderData(v:*):void
		{
			var index:int = data.indexOf(v);
			if (index != -1)
				renderItem(index)
		}
		
		/**
		 * 由数据获得对象
		 * @param v
		 * 
		 */
		public function getRender(v:*):DisplayObject
		{
			var index:int = data.indexOf(v);
			if (index != -1)
				return getChildAt(index)
			else
				return null;
		}
		
		/** @inheritDoc*/
		public override function set data(v:*) : void
		{
			super.data = v;
			render();
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			
			ref = null;
			renderSkin = null;
			
			for (var i:int = 0; i < contentPane.numChildren;i++)
			{
				if (contentPane.getChildAt(i) is IBase)
					(contentPane.getChildAt(i) as IBase).destory();
			}
			contentPane.removeEventListener(MouseEvent.CLICK,clickHandler);
			
			super.destory();
		}
		
		/**
		 * 点击事件 
		 * @param event
		 * 
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			if (event.target == contentPane)
				return;
			
			var o:DisplayObject = event.target as DisplayObject;
			while (o && o.parent != contentPane)
				o = o.parent;
			
			var e:ItemClickEvent;
			if(ref&&ref.isClass(o))
			{
				e = new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
				e.data = (o as UIBase).data;
				e.relatedObject = o as InteractiveObject;
				dispatchEvent(e);
			}else{
				if(o is UIBase)
				{
					e = new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
					e.data = (o as UIBase).data;
					e.relatedObject = o as InteractiveObject;
					dispatchEvent(e);
				}else{
					if(data&&data.length==contentPane.numChildren)
					{
						var d:*;
						for (var i:int = 0;i < contentPane.numChildren;i++)
						{
							if (o.name==contentPane.getChildAt(i).name)
							{
								d = data[i];
								break;
							}
						}
						if(selectedHandler==null)
						{
							e = new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
							e.data = d;
							e.relatedObject = o as InteractiveObject;
							dispatchEvent(e);
						}else{
							selectedHandler(d);
						}
					}
				}
			}
		}
		
		/**
		 * 按钮条的label字段
		 * @return 
		 * 
		 */
		public function get labelField():String
		{
			return _labelField;
		}
		
		public function set labelField(v:String):void
		{
			_labelField = v;
			for (var i:int = 0;i < contentPane.numChildren;i++)
			{
				var obj:Button = contentPane.getChildAt(i) as Button;
				if (obj)
				{
					obj.labelField = labelField;
					obj.data = obj.data;
				}
			}
		}
		
		/**
		 * 按钮点击事件
		 * @param event
		 * 
		 */
		protected function itemClickHandler(event:ItemClickEvent):void
		{
			if (toggleOnClick && event.data)
				selectedData = event.data;
		}
		
		/**
		 * 选择的索引 
		 * @return 
		 * 
		 */
		public function get selectedIndex():int
		{
			return data.indexOf(selectedData);
		}
		
		public function set selectedIndex(v:int):void
		{
			if (v == -1)
				selectedData = null;
			else
				selectedData = data[v];
		}
		
		/**
		 * 选择的数据 
		 * @return 
		 * 
		 */
		public function get selectedData():*
		{
			return _selectedData;
		}
		
		public function set selectedData(v:*):void
		{
			if (_selectedData == v)
				return;
			
			_selectedData = v;
			for (var i:int = 0;i < contentPane.numChildren;i++)
			{
				var item:UIBase = contentPane.getChildAt(i) as UIBase;
				if (item)
				{
					item.selected = v && item.data == v; 
				}
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 选择的按钮
		 * @return 
		 * 
		 */
		public function get selectedChild():DisplayObject
		{
			return contentPane.getChildAt(selectedIndex);
		}
		
		public function set selectedChild(v:DisplayObject):void
		{
			selectedIndex = contentPane.getChildIndex(v);
		}
	}
}