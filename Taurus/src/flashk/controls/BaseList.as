package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flashk.core.UIConst;
	import flashk.display.UIBase;
	import flashk.events.ItemClickEvent;
	import flashk.utils.ClassFactory;

	public class BaseList extends ScrollPanel
	{
		public static var defaultItemRender:ClassFactory = new ClassFactory(Button,{autoSize:"left",autoRefreshLabelField:true},[null,true,true]);
		
		/**
		 * 类型 
		 */
		public var type:String = UIConst.VERTICAL;
		/**
		 * 点击选择
		 */
		public var toggleOnClick:Boolean = true;
		/**
		 * 当前显示出的对象
		 */
		protected var contents:Array=[];
		
		protected var _itemRender:*;
		protected var _selectedData:*;
		
		/**
		 * 单个格子的矩形
		 */
		protected var _contentRect:Rectangle;
		/**
		 * 相对与scrollRectContainer的限定范围的矩形，为空则是scrollRect的值
		 */		
		public var viewRect:Rectangle;
		/**
		 * 选择事件 
		 */		
		public var selectedHandler:Function;
		
		private var listFields:Object = {renderField:"render",vScrollBarField:"vScrollBar",hScrollBarField:"hScrollBar"};
		
		public function BaseList(skin:*=null,replace:Boolean = true,type:String = UIConst.VERTICAL,itemRender:* = null,fields:Object = null)
		{
			_data = [];	
			if (!fields)
				fields = listFields;
			
			this.type = type;
			
			if (!itemRender)
				itemRender = defaultItemRender;
			
			this.itemRender = itemRender;
			
			if (!skin)
				skin = new Sprite();
			
			super(skin,replace,NaN,NaN,fields);
			addEventListener(MouseEvent.CLICK,clickHandler);
		}
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			var renderField:String = fields[renderField];
			if(renderField)
			{
				var viewSkin:DisplayObject = content[renderField] as DisplayObject;
				if(viewSkin)
					viewRect = new Rectangle(viewSkin.x,viewSkin.y,viewSkin.width,viewSkin.height);
			}
		}
		/**
		 * 对象容器 
		 */
		public function get contentPane():DisplayObjectContainer
		{
			return content as DisplayObjectContainer;
		}
		/**
		 * 点击事件 
		 * @param event
		 * 
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			if (event.target == this)
				return;
			
			var o:DisplayObject = event.target as DisplayObject;
			while (o && o.parent != contentPane)
				o = o.parent;
			
			if (itemRender.isClass(o))
			{
				if (toggleOnClick)
					selectedItem = o;
				var e:ItemClickEvent = new ItemClickEvent(ItemClickEvent.ITEM_CLICK);
				e.data = (o as UIBase).data;
				e.relatedObject = o as InteractiveObject;
				dispatchEvent(e);
			}
		}
		/**
		 * 设置ItemRender
		 * @param v
		 * 
		 */
		public function set itemRender(ref:*):void
		{
			if (ref is Class)
				_itemRender = new ClassFactory(ref);
			else 
				_itemRender = ref;
			
			clear();
			
			if(_itemRender)
			{
				var s:DisplayObject = _itemRender.newInstance();
				contentRect = s.getRect(s);
			}
		}
		
		public function get itemRender():*
		{
			return _itemRender;
		}
		public function clear():void
		{
			var len:uint=contents.length;
			for(var i:uint=0;i<len;i++)
			{
				contentPane.removeChild(contents.pop());
			}
		}
		/**
		 * 单个格子的矩形
		 * @return 
		 * 
		 */
		public function get contentRect():Rectangle
		{
			return _contentRect;
		}
		
		public function set contentRect(v:Rectangle):void
		{
			_contentRect = v;
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
			var oldSelectedItem:DisplayObject = selectedItem;
			if (oldSelectedItem && oldSelectedItem is UIBase)
				(oldSelectedItem as UIBase).selected = false;
			
			_selectedData = v;
			
			var item:DisplayObject = selectedItem;
			oldSelectedItem = item;
			
			if (item && item is UIBase)
				(item as UIBase).selected = true;
			
			if(selectedHandler==null)
				dispatchEvent(new Event(Event.CHANGE));
			else
				selectedHandler();
		}
		/**
		 * 选择的数据项
		 * @return 
		 * 
		 */
		public function get selectedIndex():int
		{
			return data.indexOf(_selectedData);
		}
		
		public function set selectedIndex(v:int):void
		{
			selectedData = data[v];
		}
		/**
		 * 选择的元素 
		 * @return 
		 * 
		 */
		public function get selectedItem():DisplayObject
		{
			return contents[selectedIndex];
		}
		
		public function set selectedItem(v:DisplayObject):void
		{
			selectedData = (v as UIBase).data;
		}
		/** @inheritDoc*/
		public override function set data(v:*) : void
		{
			var item:DisplayObject;
			for each(var d:* in v)
			{				
				item = itemRender.newInstance();
				item.y = contents.length * contentRect.height;
				if(item is UIBase)
					(item as UIBase).data = d;
				contents.push(item);
				contentPane.addChild(item);
			}
			super.data = v;
			refresh();
		}
		/** @inheritDoc*/
		protected override function updateSize() : void
		{
			super.updateSize();
			refresh();
		}
		/**
		 * 刷新元素的内容 
		 * 
		 */
		public function refresh(index:int=-1):void
		{
			if(index==-1)
			{
				index=0;
			}
			var len:uint=contents.length;
			for(var i:uint=index;i<len;i++)
			{
				contents[i].y = i * contentRect.height;
			}
		}	
		/**
		 * 由数据获得元素 
		 * @param v
		 * @return 
		 * 
		 */
		public function getRender(v:*):DisplayObject
		{
			var index:uint;
			if(v is int)
			{
				index = v;
			}else{
				index = data ? data.indexOf(v) : -1;
			}
			if (index == -1)
				return null;
			return contents[index];
		}
		/**
		 * 由元素获得数据 
		 * @param item
		 * @return 
		 * 
		 */
		public function getDataFromRender(item:DisplayObject):*
		{
			var index:uint = item.y / contentRect.height;
			return data[index];
		}
		/**
		 * 数据设置位置 
		 * @param v
		 * @param index
		 * @param isRefresh
		 */		
		public function setDataIndex(v:*,index:int,isRefresh:Boolean=true):void
		{
			var d:int = data.indexOf(v);
			if(d>=0)
				setItemIndexAt(d,index);
		}
		/**
		 * 对象设置位置  
		 * @param item
		 * @param index
		 * @param isRefresh
		 */		
		public function setItemIndex(item:DisplayObject,index:int,isRefresh:Boolean=true):void
		{
			var v:uint = item.y / contentRect.height;
			setItemIndexAt(v,index);
		}	
		/**
		 * 显示对象位置设置位置  
		 * @param index1 显示对象位置
		 * @param index2 插入位置
		 * @param isRefresh
		 */		
		public function setItemIndexAt(index1:int,index2:int,isRefresh:Boolean=true):void
		{
			var item:DisplayObject=contents[index1];
			contents.splice(index1,1);
			contents.splice(index2,0,item);
			var v:* = data[index1];
			data.splice(index1,1);
			data.splice(index2,0,v);
//			contentPane.addChildAt(item,index2);
			if(isRefresh)
				refresh();
		}	
		/**
		 * 根据数据交换位置   
		 * 交换两个指定子对象的 Z 轴顺序（从前到后顺序）。 
		 * @param v1
		 * @param v2
		 * @return 
		 * 
		 */	
		public function swapData(v1:*,v2:*):void
		{
			var index1:uint = data.indexOf(v1);
			var index2:uint = data.indexOf(v2);
			swapItemAt(index1,index2);
		}
		/**
		 * 根据对象交换位置   
		 * 交换两个指定子对象的 Z 轴顺序（从前到后顺序）。 
		 * @param item1
		 * @param item2
		 * @return 
		 * 
		 */		
		public function swapItem(item1:DisplayObject,item2:DisplayObject):void
		{
			var index1:uint = item1.y / contentRect.height;
			var index2:uint = item2.y / contentRect.height;
			swapItemAt(index1,index2);
		}
		/**
		 * 根据索引交换位置   
		 * 交换两个指定子对象的 Z 轴顺序（从前到后顺序）。 
		 * @param index1
		 * @param index2
		 * @return 
		 * 
		 */		
		public function swapItemAt(index1:int,index2:int):void
		{
			var item:DisplayObject=contents[index1];
			contents[index1] = contents[index2];
			contents[index2] = item;
			var v:* = data[index1];
			data[index1] = data[index2];
			data[index2] = v;
			contentPane.swapChildrenAt(index1,index2);
		}
		/**
		 * 添加数据或对象 
		 * @param v
		 * 
		 */		
		public function addItem(v:*,index:int=-1):void
		{
			var item:DisplayObject;
			var vd:*;
			if(itemRender.isClass(v))
			{
				item = v;
				item.y = contents.length * contentRect.height;
				if(item is UIBase)
					vd = (item as UIBase).data;
			}else{
				item = itemRender.newInstance();
				item.y = contents.length * contentRect.height;
				vd = v;
				if(item is UIBase)
					(item as UIBase).data = v;
			}
			contentPane.addChild(item);
			if(index==-1)
			{
				(_data as Array).push(vd);
				contents.push(item);
			}else{
				(_data as Array).splice(index,0,vd);
				contents.splice(index,0,item);
				refresh(index);
			}
			
		}
		/**
		 * 根据对象移除 
		 * @param item
		 * 
		 */		
		public function removeItem(item:DisplayObject):void
		{
			var index:uint = item.y / contentRect.height;
			removeData(index);
		}
		/**
		 * 根据数据移除 
		 * @param index
		 * 
		 */	
		public function removeData(v:*):void
		{
			var index:uint;
			if(v is int)
			{
				index = v;
			}else{
				index = data.indexOf(v);
				if(index<0)return;
			}
			var item:DisplayObject=contents[index];
			if(item.parent)
				item.parent.removeChild(item);
			data.splice(index,1);
			contents.splice(index,1);
			refresh(index);
			updateThumb();
		}
		/**
		 * 移除全部 
		 * 
		 */		
		public function removeAll():void
		{
			var len:uint=contents.length;
			var item:DisplayObject;
			for(var i:uint=0;i<len;i++)
			{
				item = contents.pop();
				if(item.parent)
					item.parent.removeChild(item);
				if (item && item is UIBase)
					(item as UIBase).destory();
			}
			_data=[];
			updateThumb();
		}
		private function updateThumb():void
		{
			if(type == UIConst.VERTICAL)
			{
				if(vScrollBar!=null)
					vScrollBar.updateThumb();
			}else if(type == UIConst.HORIZONTAL)
			{
				if(hScrollBar!=null)
					hScrollBar.updateThumb();
			}
		}
		/**
		 * 插入排序
		 * @param fun
		 * @param start 排序开始位置
		 * @param end 排序结束位置
		 * 
		 */		
		public function getInsertionSortData(fun:Function,start:uint=0,end:uint=0):void
		{
			var len:uint=data.length-end;
			var temp:*;
			for(var i:uint = 1+start; i < len; i++)  
			{  
				temp= data[i];  
				for(var j:uint = i; (j > start) &&fun(data[j - 1],temp); j--)  
					setItemIndexAt(j,j-1,false);
				setDataIndex(temp,j,false);
			}
			refresh(start);
		}
		/**
		 * 插入排序
		 * @param fun
		 * @param start 排序开始位置
		 * @param end 排序结束位置
		 * 
		 */		
		public function getInsertionSortItem(fun:Function,start:uint=0,end:uint=0):void
		{
			var len:uint=contents.length-end;
			var temp:*;
			for(var i:uint = 1+start; i < len; i++)  
			{  
				temp= contents[i];  
				for(var j:uint = i; (j > start) &&fun(contents[j - 1],temp); j--)  
					setItemIndexAt(j,j-1,false);
				setItemIndex(temp,j,false);
			}
			refresh(start);
		}	
		/**
		 * 排序 
		 * @param fun
		 * @param index
		 */		
		public function getSortData(fun:Function,v:*):void
		{
			var index:uint;
			if(v is int)
			{
				index = v;
			}else{
				index = data.indexOf(v);
			}
			var len:int = data.length;  
			var j:uint=0;
			for(var i:int=0;i<len;i++)
			{
				if(fun(data[i],data[index])) 
				{  
					break;
				}  
				j++;
			} 
			if(j!=index)
			{
				setItemIndexAt(index,j);
			}
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			
			removeEventListener(MouseEvent.CLICK,clickHandler);
			
			super.destory();
		}
	}
}