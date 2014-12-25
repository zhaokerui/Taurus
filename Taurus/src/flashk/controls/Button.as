package flashk.controls
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import flashk.display.UIBase;
	import flashk.events.ActionEvent;
	import flashk.layout.Padding;
	
	import taurus.skin.ButtonSkin;
	
	
	[Event(name="change",type="flash.events.Event")]
	[Event(name="action",type="flash.events.ActionEvent")]

	/**
	 * 按钮
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-4 下午5:43:57
	 * */     
	public class Button extends UIBase
	{
		public static const LABEL_UP:String = "up";
		public static const LABEL_OVER:String = "over";
		public static const LABEL_DOWN:String = "down";
		public static const LABEL_DISABLED:String = "disabled";
		public static const LABEL_SELECTED_UP:String = "selectedUp";
		public static const LABEL_SELECTED_OVER:String = "selectedOver";
		public static const LABEL_SELECTED_DOWN:String = "selectedDown";
		public static const LABEL_SELECTED_DISABLED:String = "selectedDisabled";
		
		public static const LABELS:Array = [[LABEL_UP,LABEL_SELECTED_UP],
			[LABEL_OVER,LABEL_SELECTED_OVER],
			[LABEL_DOWN,LABEL_SELECTED_DOWN],
			[LABEL_DISABLED,LABEL_SELECTED_DISABLED]];
		private const UP:int = 0;
		private const OVER:int = 1;
		private const DOWN:int = 2;
		private const DISABLED:int = 3;
		
		
		public static var defaultSkin:* = ButtonSkin;//保存默认skin
		
		private var _toggle:Boolean;
		
		private var _mouseDown:Boolean = false;
		private var _mouseOver:Boolean = false;
		
		private var mouseDownTimer:Timer;
		private var mouseDownDelayTimer:int;
		
		/**
		 * 执行的指令名称
		 */		
		public var action:String;
		
		/**
		 * 鼠标按下时移过是否转换焦点
		 */		
		public var trackAsMenu:Boolean = false;
		
		/**
		 * 是否允许按下时模拟连续点击
		 */
		public var incessancyClick:Boolean = false;
		
		/**
		 * 连续点击的延迟响应时间
		 */
		public var incessancyDelay:int = 300;
		
		/**
		 * 连续点击的响应间隔
		 */
		public var incessancyInterval:int = 50;
		
		/**
		 * 是否可以点击选择 
		 */
		public var toggle:Boolean = false;
		
		/**
		 * 鼠标是否按下
		 */
		public function get mouseDown():Boolean
		{
			return _mouseDown;
		}
		
		public function set mouseDown(v:Boolean):void
		{
			_mouseDown = v;
		}
		
		/**
		 * 鼠标是否触发
		 */
		public function get mouseOver():Boolean
		{
			return _mouseOver;
		}
		
		public function set mouseOver(v:Boolean):void
		{
			_mouseOver = v;
		}
		
		public function Button(skin:*=null, replace:Boolean=true,separateTextField:Boolean = false, textPadding:Padding=null, autoRefreshLabelField:Boolean = true)
		{
			this._autoRefreshLabelField = autoRefreshLabelField;
			if (!skin)
				skin = Button.defaultSkin;
			super(skin, replace);
			
			if(content is MovieClip)
			{
				this.mouseChildren = false;
			}
			this.separateTextField = separateTextField;
			this.textPadding = textPadding;
		}
		public override function set enabled(v:Boolean) : void
		{
			if (super.enabled == v)
				return;
			
			this.mouseEnabled = super.enabled = v;
			tweenTo(UP);
		}
		public override function set selected(v:Boolean):void
		{
			if (super.selected == v)
				return;
			
			super.selected = v;
			
			tweenTo(mouseOver ? OVER : UP);
			
			dispatchEvent(new Event(Event.CHANGE))
		}
		/** @inheritDoc*/
		public override function setContent(skin:*, replace:Boolean=true):void
		{
			defaultSkin = skin;
			super.setContent(skin,replace);
			if (_autoRefreshLabelField)
				refreshLabelField();
		}
		protected override function init():void
		{
			super.init();
			addEvents();
			tweenTo(UP);
		}
		
		/**
		 * 增加事件
		 * 
		 */
		protected function addEvents():void
		{
			addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			if (stage)
				stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			addEventListener(MouseEvent.CLICK,clickHandler);
		}
		
		/**
		 * 删除事件
		 * 
		 */
		protected function removeEvents():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			removeEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			removeEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			removeEventListener(MouseEvent.CLICK,clickHandler);
		}
		/** @inheritDoc*/
		
		/**
		 * 跳转到某个状态 
		 * @param n
		 * 
		 */
		protected function tweenTo(n:int):void
		{
			if (!enabled)
				n = DISABLED;
			if (content is MovieClip)
			{
				var mc:MovieClip = content as MovieClip;
				if(mc.totalFrames==1)
				{
					mc.gotoAndStop(1);
				}else if(mc.totalFrames==2)
				{
					if(n==0||n==1)
					{
						mc.gotoAndStop(1);
					}else{
						mc.gotoAndStop(2);
					}
				}else if(mc.totalFrames==3)
				{
					if(n==3)
					{
						mc.gotoAndStop(3);
					}else{
						mc.gotoAndStop(n+1);
					}
				}else if(mc.totalFrames==4)
				{
					mc.gotoAndStop(n+1);
				}else if(mc.totalFrames==6)
				{
					mc.gotoAndStop(n+1);
					if(selected)
					{
						if(n==3)
						{
							mc.gotoAndStop(6);
						}else{
							mc.gotoAndStop(n+4);
						}
					}else{
						if(n==3)
						{
							mc.gotoAndStop(3);
						}else{
							mc.gotoAndStop(n+1);
						}
					}
				}else{
					var next:String = LABELS[n][int(selected)];
					mc.gotoAndStop(next);
				}
			}
		}
		
		/**
		 * 鼠标按下事件
		 * @param event
		 * 
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			if (mouseDown)
				return;
			
			tweenTo(DOWN);
			mouseDown = true;
			if (incessancyClick)
				mouseDownDelayTimer = setTimeout(enabledIncessancyHandler,incessancyDelay);
		}
		
		private function enabledIncessancyHandler():void
		{
			enabledIncessancy = true;
		}
		
		/**
		 * 鼠标松开事件 
		 * @param event
		 * 
		 */
		protected function mouseUpHandler(event:MouseEvent):void
		{
			if (!mouseDown)
				return;
			
			tweenTo(mouseOver ? OVER : UP);
			
			mouseDown = false;
			enabledIncessancy = false;
			
			if (trackAsMenu)
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		/**
		 * 鼠标移入事件
		 * @param event
		 * 
		 */
		protected function rollOverHandler(event:MouseEvent):void
		{	
			if (event.buttonDown)
			{
				if (trackAsMenu || mouseDown)
					tweenTo(DOWN);
			}
			else
			{
				tweenTo(OVER);
			}
			
			mouseOver = true;
		}
		/**
		 * 鼠标移出事件 
		 * @param event
		 * 
		 */
		protected function rollOutHandler(event:MouseEvent):void
		{
			tweenTo(UP);
			
			mouseOver = false;
		}
		/**
		 * 点击事件
		 * @param event
		 * 
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			if (toggle)
				selected = !selected;
			
			if (this.action)
			{
				var e:ActionEvent = new ActionEvent(ActionEvent.ACTION);
				e.action = this.action;
				dispatchEvent(e)
			}
		}
		
		//激活连续点击
		private function set enabledIncessancy(v:Boolean):void
		{
			if (mouseDownTimer)
			{
				mouseDownTimer.stop();
				mouseDownTimer.removeEventListener(TimerEvent.TIMER,incessancyHandler);
				mouseDownTimer = null;
			}
			if (v)
			{
				mouseDownTimer = new Timer(incessancyInterval,int.MAX_VALUE);
				mouseDownTimer.addEventListener(TimerEvent.TIMER,incessancyHandler);
				mouseDownTimer.start();
			}
			else
			{
				clearTimeout(mouseDownDelayTimer);
			}
		}
		
		/**
		 * 连续点击事件
		 * @param event
		 * 
		 */
		protected function incessancyHandler(event:TimerEvent):void
		{
			dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		//带Label按钮
		/**
		 * Label文本实例 
		 */
		public var labelTextField:Text;
		
		/**
		 * data中显示成label的字段
		 */
		public var labelField:String;
		
		/**
		 * 是否创建Label文本框（此属性已取消，必须用GButtonBase构造函数的第5个参数来设置）
		 */
		private var _autoRefreshLabelField:Boolean = true;
		public function get autoRefreshLabelField():Boolean
		{
			return _autoRefreshLabelField;
		}
		
		public function set autoRefreshLabelField(v:Boolean):void
		{
			throw new Error("GButtonBase的autoRefreshLabelField属性已失效，必须用构造函数的第5个参数来设置");
		}
		
		/**
		 * 根据文本框更新图形大小
		 * 
		 */
		public function adjustContextSize():void
		{
			if (labelTextField)
				labelTextField.adjustContextSize();
		}
		
		/**
		 * 删除Label文本框 
		 * 
		 */
		public function removeLabelTextField():void
		{
			if (labelTextField)
			{
				labelTextField.destory();
				labelTextField = null;
			}
		}
		
		/**
		 * 是否自动根据文本调整Skin体积。当separateTextField为false时，此属性无效。
		 * 要正确适应文本，首先必须在创建时将separateTextField参数设为true，其次可以根据textPadding来决定边距
		 */
		public function get enabledAdjustContextSize():Boolean
		{
			return labelTextField ? labelTextField.enabledAdjustContextSize : false;
		}
		
		public function set enabledAdjustContextSize(value:Boolean):void
		{
			if (labelTextField)
				labelTextField.enabledAdjustContextSize = value;
		}
		
		
		/**
		 * 动态创建的TextField的初始位置（如果是从skin中创建，此属性无效）
		 */
		public function get textStartPoint():Point
		{
			return labelTextField ? labelTextField.textStartPoint : null;
		}
		
		public function set textStartPoint(value:Point):void
		{
			if (labelTextField)
				labelTextField.textStartPoint = value;
		}
		
		
		/**
		 * 文本自适应边距 
		 * @return 
		 * 
		 */
		public function get textPadding():Padding
		{
			return labelTextField ? labelTextField.textPadding : null;
		}
		
		public function set textPadding(value:Padding):void
		{
			if (labelTextField)
				labelTextField.textPadding = value;
		}
		
		/**
		 * Label自动大小
		 */
		public function get autoSize():String
		{
			return labelTextField ? labelTextField.autoSize : null;
		}
		
		public function set autoSize(value:String):void
		{
			if (labelTextField)
				labelTextField.autoSize = value;
		}
		
		/**
		 * 是否将文本从Skin中剥离。剥离后Skin缩放才不会影响到文本的正常显示
		 */
		public function get separateTextField():Boolean
		{
			return labelTextField ? labelTextField.separateTextField : false;
		}
		
		public function set separateTextField(v:Boolean):void
		{
			if (labelTextField)
				labelTextField.separateTextField = v;
		}
		
		/**
		 * 自动截取文本 
		 * @return 
		 * 
		 */
		public function get enabledTruncateToFit():Boolean
		{
			return labelTextField ? labelTextField.enabledTruncateToFit : false;
		}
		
		public function set enabledTruncateToFit(v:Boolean):void
		{
			if (labelTextField)
				labelTextField.enabledTruncateToFit = v;
		}
		
		/**
		 * 文本是否垂直居中
		 */
		public function get enabledVerticalCenter():Boolean
		{
			return labelTextField ? labelTextField.enabledVerticalCenter : false;
		}
		
		public function set enabledVerticalCenter(v:Boolean):void
		{
			if (labelTextField)
				labelTextField.enabledVerticalCenter = v;
		}
		
		/**
		 * 激活文本自适应
		 * 
		 */
		public function enabledAutoLayout(padding:Padding,autoSize:String = TextFieldAutoSize.LEFT):void
		{
			if (labelTextField)
				labelTextField.enabledAutoLayout(padding,autoSize);
		}
		
		/**
		 * Label文字 
		 * @return 
		 * 
		 */
		public function get label():String
		{
			return labelField ? data[labelField] : (data is String || data is Number) ? data : null;
		}
		
		public function set label(v:String):void
		{
			if (labelField)
			{
				if (super.data == null)
					super.data = new Object();
				
				super.data[labelField] = v;
			}
			else
				data = v;
		}
		/** @inheritDoc*/
		public override function set data(v:*) : void
		{
			super.data = v;
			
			if (label != null)
			{
				if (labelTextField && _autoRefreshLabelField)
					labelTextField.text = label;
			}
		} 
		
		/**
		 * 更新label
		 * 
		 */
		public function refreshLabelField():void
		{
			if (labelTextField)
			{
				//复制原属性
				var newText:Text = new Text(content,false,separateTextField,textPadding);
				newText.enabledAdjustContextSize = enabledAdjustContextSize;
				newText.enabledTruncateToFit = enabledTruncateToFit;
				newText.enabledVerticalCenter = enabledVerticalCenter;
				newText.autoSize = autoSize;
				
				labelTextField.destory();
				labelTextField = newText;
			}
			else
			{
				labelTextField = new Text(content,false);
			}
			
			if (!labelTextField.parent)
				addChild(labelTextField)
			
			if (label != null)
				labelTextField.text = label;
		}
		
		
		
		
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			
			removeEvents();
			
			enabledIncessancy = false;
			
			if (labelTextField)
				labelTextField.destory();
			
			super.destory();
		}
	}
}