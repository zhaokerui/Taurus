package flashk.controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashk.display.UIBase;
	import flashk.events.ItemClickEvent;
	import flashk.utils.ClassFactory;

	public class BaseList extends ScrollPanel
	{
		/**
		 * 点击选择
		 */
		public var toggleOnClick:Boolean = true;
		/**
		 * 选择事件 
		 */		
		public var selectedHandler:Function;
		/**
		 * 当前显示出的对象
		 */
		protected var contents:Array=[];
		protected var _itemRender:*;
		protected var _selectedData:*;
		
		public function BaseList(skin:*=null,replace:Boolean = true,width:Number = NaN,height:Number = NaN,fields:Object = null)
		{
			if (!skin)
				skin = new Sprite();
			super(skin,replace,width,height,fields);
		}
		/**
		 * 对象容器 
		 */
		public function get contentPane():DisplayObjectContainer
		{
			return content as DisplayObjectContainer;
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
		/** @inheritDoc*/
		public override function set data(v:*) : void
		{
			var item:DisplayObject;
			for each(var d:* in v)
			{				
				item = itemRender.newInstance();
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
		
		override protected function updatePosition() : void
		{
			super.updatePosition();
			refresh();
		}
		
		override protected function updateDisplayList():void
		{
			super.updateDisplayList();
			refresh();
		}
		/**
		 * 刷新元素的内容 
		 * 
		 */
		public function refresh():void
		{
			var len:uint=contents.length;
			var hlen:uint=0;
			for(var i:uint=0;i<len;i++)
			{
				contents[i].y = hlen;
				hlen += uint(contents[i].height);
			}
		}	
		
		/**
		 * 总条数 
		 * @return 
		 * 
		 */
		public function get length():int
		{
			return contents.length;
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
		}
		public function get itemRender():*
		{
			return _itemRender;
		}
		/**
		 * 添加数据或对象  
		 * @param item
		 * @param index
		 * 
		 */		
		public function addItem(item:DisplayObject,index:int=-1):void
		{
			var item:DisplayObject;
			var vd:* = null;
			if(item is UIBase)
				vd = (item as UIBase).data;
			contentPane.addChild(item);
			if(index==-1)
			{
				if(_data!=null)
					(_data as Array).push(vd);
				contents.push(item);
			}else{
				if(_data!=null)
					(_data as Array).splice(index,0,vd);
				contents.splice(index,0,item);
			}
			refresh();
			
		}
		/**
		 * 根据对象移除 
		 * @param item  添加equals方法
		 * 
		 */		
		public function removeItem(item:DisplayObject):void
		{
			var len:uint = contents.length;
			for(var i:uint = 0; i < len; i++)  
			{  
				if(contents[i].equals(item))
				{
					removeData(i);
					break;
				}
			}
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
			if(_data!=null)
				data.splice(index,1);
			contents.splice(index,1);
			if (item is UIBase)
				(item as UIBase).destory();
			refresh();
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
		}
		/**
		 * 数据设置位置 
		 * @param v
		 * @param index
		 * @param isRefresh
		 */		
		public function setDataIndex(v:*,index:int):void
		{
			var d:int = data.indexOf(v);
			if(d>=0)
				setItemIndexAt(d,index);
		}
		/**
		 * 对象设置位置  
		 * @param item 添加equals方法
		 * @param index
		 * @param isRefresh
		 */		
		public function setItemIndex(item:DisplayObject,index:int):void
		{
			var len:uint = contents.length;
			for(var i:uint = 0; i < len; i++)  
			{  
				if(contents[i].equals(item))
				{
					setItemIndexAt(i,index);
					break;
				}
			}
		}	
		/**
		 * 显示对象位置设置位置  
		 * @param index1 显示对象位置
		 * @param index2 插入位置
		 * @param isRefresh
		 */		
		public function setItemIndexAt(index1:int,index2:int):void
		{
			var item:DisplayObject=contents[index1];
			contents.splice(index1,1);
			contents.splice(index2,0,item);
			if(data==null)return;
			var v:* = data[index1];
			data.splice(index1,1);
			data.splice(index2,0,v);
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
			contentPane.swapChildrenAt(index1,index2);
			if(data==null)return;
			var v:* = data[index1];
			data[index1] = data[index2];
			data[index2] = v;
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
					setItemIndexAt(j,j-1);
				setDataIndex(temp,j);
			}
			refresh();
		}
		/**
		 * 插入排序
		 * @param fun
		 * @param start 排序开始位置
		 * @param end 排序结束位置
		 * 
		 */		
		public function getInsertionSortDataItem(fun:Function,start:uint=0,end:uint=0):void
		{
			var len:uint=contents.length-end;
			var temp:*;
			for(var i:uint = 1+start; i < len; i++)  
			{  
				temp= contents[i];  
				for(var j:uint = i; (j > start) &&fun(contents[j - 1],temp); j--)  
					setItemIndexAt(j,j-1);
				setDataIndex(temp.data,j);
			}
			refresh();
		}
		/**
		 * 插入排序 --显示对象添加equals方法
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
					setItemIndexAt(j,j-1);
				setItemIndex(temp,j);
			}
			refresh();
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			clear();
			removeEventListener(MouseEvent.CLICK,clickHandler);
			
			super.destory();
		}
	}
}