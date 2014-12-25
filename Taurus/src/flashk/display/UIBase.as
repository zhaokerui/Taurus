package flashk.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashk.core.Tick;
	import flashk.core.UniqueCall;
	import flashk.events.KEvent;
	import flashk.events.TickEvent;
	
	[Event(name="update_complete",type="flashk.events.KEvent")]
	[Event(name="move",type="flashk.events.KEvent")]
	[Event(name="resize",type="flashk.events.KEvent")]

	/**
	 * 建议全部可视对象都以此类作为基类，而不仅仅是组件。这个类实现了光标和提示接口，以及属性变化事件
	 * 如果不需要Vaild事件，可将enabledDelayUpdate设为false,便不会占用多余的性能。
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-4 下午3:36:49
	 * */     
	public class UIBase extends KSprite implements IBase
	{
		private var _enabled:Boolean = true;
		private var _selected:Boolean = false;
		private var _enabledTick:Boolean = false;
		private var _paused:Boolean = false;
		private var _cursor:*;
		private var _toolTip:*;
		private var _toolTipObj:*;
		private var _owner:DisplayObject;
		private var _oldPosition:Point = new Point();
		private var _position:Point = new Point();
		protected var _data:Object;
		/**
		 * 自身
		 */
		public var self:UIBase;
		/**
		 * 是否激活各种Vaild事件（取消可大幅增加性能）
		 */
		public var enabledDelayUpdate:Boolean = true;
		/**
		 * 是否延迟执行Vaild事件
		 */
		public var delayCall:Boolean = true;
		/**
		 * 是否延迟更新坐标。如果延迟更新，将不会出现设置了属性值屏幕却不能立即看到表现导致错位的情况，
		 * 因为整个过程都被延后了。但这样画面会延后一帧，会产生画面拖慢，因此只在必要的时候使用
		 */		
		public var delayUpatePosition:Boolean = false;
		
		public function UIBase(skin:*=null,replace:Boolean=true)
		{
			this.self = this;
			super(skin,replace);
		}
		
		/**
		 * 拥有者
		 */
		public function get owner():DisplayObject
		{
			return _owner;
		}
		
		/**
		 * @private
		 */
		public function set owner(value:DisplayObject):void
		{
			_owner = value;
		}
		/**
		 * 光标的Class，可能的类型是Class或者String，Class类型直接是显示的图元，
		 * String类型时，将会从CursorSprite的cursors对象中寻找对应的Class;
		 * 
		 * 当GCursorSprite类不存在实例时，此属性无效
		 * 
		 * @return 
		 * 
		 */		
		public function get cursor():*
		{
			return _cursor;
		}
		
		public function set cursor(v:*):void
		{
			_cursor = v;
		}
		/**
		 * 提示的内容，不一定非要是字符串，以便实现复杂内容的提示
		 * 此属性在ToolTipSprite不存在实例时无效
		 * @return 
		 * 
		 */		
		public function get toolTip():*
		{
			return _toolTip;
		}
		
		public function set toolTip(v:*):void
		{
			_toolTip = v;
		}
		/**
		 * 提示的自定义显示，用于单个控件特殊的提示，可多个组件共享同一个实例。类型只能是字符串或者Base对象以及类。
		 * 当类型是字符串时，将会从ToolTipSprite查找已注册的ToolTipObj。都不满足时，将使用ToolTipSprite的默认提示
		 * 
		 * 此属性在ToolTipSprite不存在实例时无效
		 * @return 
		 * 
		 */		
		
		public function get toolTipObj():*
		{
			return _toolTipObj;
		}
		
		public function set toolTipObj(v:*):void
		{
			_toolTipObj = v;
		}
		/**
		 * 设置数据 
		 * @return 
		 * 
		 */		
		
		public function get data():*
		{
			return _data;
		}
		
		public function set data(value:*):void
		{
			_data = value;
			dispatchEvent(new KEvent(KEvent.DATA_CHANGE));
		}
		/**
		 * 坐标 
		 * @param v
		 * 
		 */
		public function set position(v:Point):void
		{
			setPosition(v);
		}
		
		public function get position():Point
		{
			return _position;
		}
		
		/**
		 * 旧坐标
		 * @return 
		 * 
		 */
		public function get oldPosition():Point
		{
			return _oldPosition;
		}
		/**
		 * 坐标变化位移
		 * @return 
		 * 
		 */
		public function get positionOffest():Point
		{
			return position.subtract(_oldPosition);
		}
		/**
		 * 设置状态
		 * 
		 * @return 
		 * 
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
		}
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		public override function set visible(value:Boolean) : void
		{
			if (value == visible)
				return;
			
			var evt:KEvent;
			if (value)
				evt = new KEvent(KEvent.SHOW,false,true)
			else
				evt = new KEvent(KEvent.HIDE,false,true)
			
			dispatchEvent(evt);
			if (evt.isDefaultPrevented())
				return;
			
			super.visible = value;
		}
		/**
		 * 设置坐标
		 *  
		 * @param x	x坐标
		 * @param y	y坐标
		 * @param noEvent	是否触发事件
		 * 
		 */
		public function setPosition(p:Point,noEvent:Boolean = false):void
		{
			var displayPoint:Point = new Point(super.x,super.y);
			if (!displayPoint.equals(p))
			{
				_oldPosition = displayPoint;
				_position = p;
				
				if (!delayUpatePosition)
				{
					super.x = p.x;
					super.y = p.y
				}
			}
			
			if (enabledDelayUpdate)
				vaildPosition(noEvent); 
		}
		public override function set x(value:Number):void
		{
			if (x == value)
				return;
			
			_oldPosition.x = super.x;
			position.x = value;
			
			if (!delayUpatePosition)
				super.x = value;
			
			if (enabledDelayUpdate)
			{
				if (delayCall)
					positionCall.invalidate();
				else
					positionCall.vaildNow();
			}
		}
		
		public override function get x() : Number
		{
			return position.x;
		}
		public override function set y(value:Number):void
		{
			if (y == value)
				return;
			
			_oldPosition.y = super.y;
			position.y = value;
			
			if (!delayUpatePosition)
				super.y = value;
			
			if (enabledDelayUpdate)
			{
				if (delayCall)
					positionCall.invalidate();
				else
					positionCall.vaildNow();
			}
		}
		
		public override function get y() : Number
		{
			return position.y;
		}
		
		/**
		 * 设置大小 
		 * @param width	宽度
		 * @param height	高度
		 * @param noEvent	是否触发事件
		 * 
		 */
		public function setSize(width:Number,height:Number,noEvent:Boolean = false):void
		{
			if (super.width == width && super.height == height)
				return;
			
			super.width = width;
			super.height = height;
			
			vaildSize(noEvent);
		}
		public override function set height(value:Number):void
		{
			if (super.height == value)
				return;
			
			super.height = value;
			
			if (enabledDelayUpdate)
			{
				if (delayCall)
					sizeCall.invalidate();
				else
					sizeCall.vaildNow();
			}
		}
		public override function set width(value:Number):void
		{
			if (super.width == value)
				return;
			
			super.width = value;
			
			if (enabledDelayUpdate)
			{
				if (delayCall)
					sizeCall.invalidate();
				else
					sizeCall.vaildNow();
			}
		}
		
		/**
		 * 大小 
		 * @return 
		 * 
		 */
		public function get size():Point
		{
			return new Point(width,height);
		}
		
		
		/**
		 * 初始化 
		 * 
		 */		
		protected override function init():void
		{
			super.init();
			
			createChildren();
		}
		protected function createChildren():void
		{
			
		}
		
		//性能优化
		
		private var _bitmap:Bitmap;
		private var _asBitmap:Boolean = false;
		
		/**
		 * 将content替换成Bitmap,增加性能
		 * 
		 */		
		public function set asBitmap(v:Boolean):void
		{
			if (!content)
				return;
			
			if (v)
			{
				content.visible = false;
				reRenderBitmap();	
			}
			else
			{
				content.visible = true;
				if (_bitmap)
				{
					_bitmap.bitmapData.dispose();
					_bitmap.parent.removeChild(_bitmap);
					_bitmap = null;
				}
			}
		}
		
		public function get asBitmap():Boolean
		{
			return _asBitmap;
		}
		
		/**
		 * 更新缓存位图
		 * 
		 */			
		public function reRenderBitmap():void
		{
			var oldRect:Rectangle = _bitmap ? _bitmap.getBounds(this) : null;
			var rect:Rectangle = content.getBounds(this);
			if (!oldRect || !rect.equals(oldRect))
			{
				if (_bitmap)
				{
					removeChild(_bitmap);
					_bitmap.bitmapData.dispose();
				}
				_bitmap = new Bitmap(new BitmapData(Math.ceil(rect.width),Math.ceil(rect.height),true,0));
				_bitmap.x = rect.x;
				_bitmap.y = rect.y;
				$addChild(_bitmap);
			}
			var m:Matrix = new Matrix();
			m.translate(-rect.x,-rect.y);
			_bitmap.bitmapData.draw(content,m);
		}
		
		
		/**
		 * Tick执行优先级
		 */
		public var priority:int = 0;
		
		/** @inheritDoc */	
		public function get paused():Boolean
		{
			return _paused;
		}
		
		public function set paused(v:Boolean):void
		{
			if (_paused == v)
				return;
			
			_paused = v;
			
			if (!_paused && _enabledTick)
				Tick.instance.addEventListener(TickEvent.TICK,tickHandler,false,priority);
			else
				Tick.instance.removeEventListener(TickEvent.TICK,tickHandler);
		}
		
		/**
		 * 时基事件
		 * @param event
		 * 
		 */
		public function get enabledTick():Boolean
		{
			return _enabledTick;
		}
		
		public function set enabledTick(v:Boolean):void
		{
			if (_enabledTick == v)
				return;
			
			_enabledTick = v;
			
			if (_enabledTick)
				Tick.instance.addEventListener(TickEvent.TICK,tickHandler);
			else
				Tick.instance.removeEventListener(TickEvent.TICK,tickHandler);
		}
		protected function tickHandler(event:TickEvent):void
		{
			vaildDisplayList();
		}
		/**
		 * 在暂停状态下，仍然可以手动使用此方法激活tick。利用它可以处理区域调速等功能。
		 * @param v
		 * 
		 */
		public function tick(v:int):void
		{
			var evt:TickEvent = new TickEvent(TickEvent.TICK);
			evt.interval = v;
			tickHandler(evt);
		}
		
		//更新显示对象属性
		protected var sizeCall:UniqueCall = new UniqueCall(vaildSize,true);
		protected var positionCall:UniqueCall = new UniqueCall(vaildPosition,true);
		protected var displayListCall:UniqueCall = new UniqueCall(vaildDisplayList);
		
		/**
		 * 立即更新显示 
		 * 
		 */
		public function vaildNow():void
		{
			vaildSize();
			vaildDisplayList();
		}
		/**
		 * 在之后更新大小
		 * 
		 */
		public function invalidateSize():void
		{
			sizeCall.invalidate();
		}
		/**
		 * 更新大小并且发送事件 
		 * 
		 */
		public function vaildSize(noEvent:Boolean = false):void
		{
			updateSize();
			
			if (!noEvent)
			{
				var e:KEvent = new KEvent(KEvent.RESIZE);
				e.now = new Point(width,height)
				dispatchEvent(e);
				
				if (parent)
				{
					e = new KEvent(KEvent.CHILD_RESIZE);
					e.now = new Point(width,height);
					e.child = this;
					parent.dispatchEvent(e);
				}
			}
		}
		/**
		 * 需要更新的显示对象大小
		 * 
		 */
		protected function updateSize():void
		{
		}
		/**
		 * 在之后更新坐标
		 * 
		 */
		public function invalidatePosition():void
		{
			positionCall.invalidate();
		}
		/**
		 * 更新坐标并且发送事件 
		 * 
		 */
		public function vaildPosition(noEvent:Boolean = false):void
		{
			if (super.x != position.x)
				super.x = position.x;
			
			if (super.y != position.y)
				super.y = position.y;			
			
			updatePosition();
			
			if (!noEvent)
			{
				var e:KEvent = new KEvent(KEvent.MOVE);
				e.old = _oldPosition;
				e.now = position;
				dispatchEvent(e);
			}
			_oldPosition = position.clone();
		}
		/**
		 * 更新位置的操作
		 * 
		 */
		protected function updatePosition():void
		{
		}
		/**
		 * 在之后更新显示
		 * 
		 */
		public function invalidateDisplayList():void
		{
			displayListCall.invalidate();
		}
		/**
		 * 更新显示并且发送事件 
		 * 
		 */
		public function vaildDisplayList(noEvent:Boolean = false):void
		{
			updateDisplayList();
			if (!noEvent)
				dispatchEvent(new KEvent(KEvent.UPDATE_COMPLETE));
		}
		/**
		 * 需要更新的显示列表 
		 * 
		 */		
		protected function updateDisplayList(): void
		{
		}
		
		public override function destory():void
		{
			if (destoryed)
				return;
			
			var evt:KEvent = new KEvent(KEvent.REMOVE,false,true)
			dispatchEvent(evt);
			
			if (evt.isDefaultPrevented())
				return;
			
			super.destory();
		}
	}
}