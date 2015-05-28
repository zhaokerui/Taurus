package flashk.controls
{
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flashk.core.DragManager;
	import flashk.core.RootManager;
	import flashk.core.UIBuilder;
	import flashk.display.UIBase;
	import flashk.events.ActionEvent;
	import flashk.utils.ClassFactory;
	
	import taurus.skin.WindowSkin;
	
	[Event(name="close",type="flash.events.Event")]

	/**
	 * 可拖动的窗口
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-6 下午3:45:06
	 * */     
	public class Window extends Panel
	{
		public static var defaultSkin:* = WindowSkin;
		public var closeButton:Button;
		public var titleTextField:Text;
		public var dragBase:UIBase;
		public var background:UIBase;
		public var closeHandler:Function;
		/**
		 * 是否激活居中显示
		 */
		public var enabledCenter:Boolean = true;
		/**
		 * 是否激将窗口移动到显示列表的最顶层
		 */		
		public var enabledMoveWindowTop:Boolean = true;
		/**
		 * 关闭按钮位置偏移值 
		 */		
		public var closeButtonOffset:uint = 0;
		/**
		 * 内容显示区偏移值 
		 */		
		public var backgroundOffset:uint = 5;
		public var enabledAutoBackgroundOffset:Boolean = true;
		/**
		 * 是否接受皮肤的大小 
		 */
		public var autoWindowSize:Boolean = true;
		
		/**
		 * 标题
		 * @return 
		 * 
		 */
		public function get title():String
		{
			return titleTextField.text;
		}
		
		public function set title(v:String):void
		{
			titleTextField.text = v;
		}
		public function setTitle(v:String,offset:int = -1):void
		{
			titleTextField.text = v;
			if(offset==-1)
				this.x = (width - titleTextField.width)/2;
			else
				this.x = offset;
		}
		private var backgroundWindow:DisplayObject;
		public var fields:Object = {closeButton:"closeButton",dragBase:"dragBase",background:"background",titleTextField:"titleTextField"};
		
		public function Window(skin:*=null, replace:Boolean=true,autoSize:Boolean = true,windowSkin:* = null,fields:Object = null)
		{
			autoWindowSize = autoSize;
			if(!windowSkin)
				windowSkin = defaultSkin;
			if (fields)
				this.fields = fields;
			super(skin, replace);
			setBackgroundSkin(windowSkin);
			this.addEventListener(MouseEvent.MOUSE_DOWN,moveWindowTop);
		}
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			
			UIBuilder.buildAll(this);
			
			if(titleTextField)
				titleTextField.mouseEnabled=false;
			if(closeButton!=null)
			{
				autoWindowSize = false;
				closeButton.action="close";
				closeButton.addEventListener(ActionEvent.ACTION,closeButtonClickHandler);
				if(dragBase==null)
				{
					var dis:Shape = new Shape();
					dis.graphics.beginFill(0,0);
					dis.graphics.drawRect(0 ,0,closeButton.x,closeButton.y+closeButton.height);
					dragBase = new UIBase(dis);
					this.addChildAt(dragBase,this.getChildIndex(closeButton));
				}
			}
			if(dragBase)
				DragManager.register(dragBase,this,null,null,dragBaseMouseHandler);
		}
		
		public override function setBackgroundSkin(skin:*):void
		{
			if(autoWindowSize)
			{
				if (backgroundWindow)
					$removeChild(backgroundWindow);
				
				destoryAutoWindow();
				
				if (skin)
				{
					if (skin is Class)
						skin = new ClassFactory(skin);
					
					if (skin is ClassFactory)
						skin = (skin as ClassFactory).newInstance();
					backgroundWindow = skin as DisplayObject;
					$addChildAt(backgroundWindow,0);
					
					closeButton = new Button(UIBuilder.getSkinByName(backgroundWindow,fields.closeButton));
					dragBase = new UIBase(UIBuilder.getSkinByName(backgroundWindow,fields.dragBase));
					background = new UIBase(UIBuilder.getSkinByName(backgroundWindow,fields.background));
					titleTextField = new Text(UIBuilder.getSkinByName(backgroundWindow,fields.titleTextField));
					titleTextField.mouseEnabled=false;
					closeButton.action="close";
					closeButton.addEventListener(ActionEvent.ACTION,closeButtonClickHandler);
					closeButtonOffset = background.width-closeButton.x;
					DragManager.register(dragBase,this,null,null,dragBaseMouseHandler);
				}
				refresh();
			}
		}
		protected function destoryAutoWindow():void
		{
			if(closeButton!=null)
			{
				closeButton.removeEventListener(ActionEvent.ACTION,closeButtonClickHandler);
				closeButton.destory();
				closeButton = null;
			}
			if(background!=null)
			{
				background.destory();
				background = null;
			}
			if(titleTextField!=null)
			{
				titleTextField.destory();
				titleTextField = null;
			}
			if(dragBase!=null)
			{
				DragManager.unregister(dragBase);
				dragBase.destory();
				dragBase = null;
			}
		}
		public function refresh():void
		{
			if(autoWindowSize)
			{
				var offset:uint=backgroundOffset;
				if(enabledAutoBackgroundOffset)
				{
					if(background.x<0)
					{
						offset = uint(Math.abs(background.x));
					}else{
						content.x =offset;
					}
				}else{
					content.x =offset;
					if(background.x<0)
					{
						offset += uint(Math.abs(background.x));
					}
				}
				var w:Number=width;
				if(w<content.width)
				{
					w = content.width;
				}
				var h:Number=height;
				if(h<content.height)
				{
					h = content.height;
				}
				dragBase.width = int(w+offset*2);
				background.width = int(w+offset*2);
				background.height = int(h+offset);
				closeButton.x = int(w+offset*2-closeButtonOffset);
			}
		}
		protected override function updateSize():void
		{
			super.updateSize();
			refresh();
		}
		private function closeButtonClickHandler(event:ActionEvent):void
		{
			close();
			if(this.closeHandler==null)
				dispatchEvent(new Event(Event.CLOSE));
			else
				this.closeHandler();
		}
		public function close():void
		{
			if(this.parent!=null)
			{
				this.parent.removeChild(this);
			}
		}
		/**
		 * 调整窗口位置，使其可以在舞台中被点中
		 */ 
		protected function dragBaseMouseHandler(event:Event):void
		{
			if(!dragBase||!stage)
				return;
			var pos:Point = dragBase.localToGlobal(new Point());
			var stageX:Number = pos.x;
			var stageY:Number = pos.y;
			if(pos.x+dragBase.width<35)
			{
				stageX = 35 - dragBase.width;
			}
			if(pos.x>stage.stageWidth-20)
			{
				stageX = stage.stageWidth-20;
			}
			if(pos.y+dragBase.height<20)
			{
				stageY = 20 - dragBase.height;
			}
			if(pos.y>stage.stageHeight-20)
			{
				stageY = stage.stageHeight-20;
			}
			this.x += int(stageX-pos.x);
			this.y += int(stageY-pos.y);
		}
		/**
		 * 将窗口移动到显示列表的最顶层
		 */ 
		protected function moveWindowTop(event:MouseEvent):void
		{
			if(enabledMoveWindowTop)
			{
				if(this.mouseX<0 || this.mouseY <0 || this.mouseX>this.width || this.mouseY >this.height)
				{
					return;
				}
				if(this.parent is Loader) return;
				this.parent.setChildIndex(this,this.parent.numChildren-1);
			}
		}
		protected override function init():void
		{
			if(enabledCenter&&RootManager.initialized)
			{
				this.x = int((RootManager.stage.stageWidth - this.width)/2);
				this.y = int((RootManager.stage.stageHeight - this.height)*0.4);
			}
		}
		public override function destory() : void
		{
			if (destoryed)
				return;
			if(autoWindowSize)
			{
				destoryAutoWindow();
			}else{
				if(closeButton!=null)
				{
					closeButton.removeEventListener(ActionEvent.ACTION,closeButtonClickHandler);
				}
				if(dragBase)
					DragManager.unregister(dragBase);
			}
			UIBuilder.destory(this);
			this.removeEventListener(MouseEvent.MOUSE_DOWN,moveWindowTop);
			
			super.destory();
		}
	}
}