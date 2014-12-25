package flashk.controls
{
	import flashk.core.DragManager;
	import flashk.core.PopupManager;
	import flashk.core.UIBuilder;
	import flashk.core.UIConst;
	import flashk.display.UIBase;
	import flashk.events.ItemClickEvent;
	import flashk.layout.LayoutUtil;
	
	import taurus.skin.AlertSkin;
	
	
	/**
	 * 警示框
	 * 
	 * @author kerry
	 * 
	 */
	public class Alert extends Panel
	{
		public static var defaultSkin:* = AlertSkin;
		/**
		 * 默认按钮 
		 */
		public static var defaultButtons:Array = ["确认"];
		
		/**
		 * 文字
		 * @return 
		 * 
		 */
		public function get text():String
		{
			return textTextField.text;
		}
		
		public function set text(v:String):void
		{
			textTextField.text = v;
		}
		
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
		
		public var closeHandler:Function;
		
		/**
		 * 显示 
		 * 
		 * @param text	文字
		 * @param title	标题
		 * @param buttons	按钮
		 * @param icon	图标
		 * @param closeHandler	关闭事件
		 * @return 
		 * 
		 */
		public static function show(text:String,title:String = null,buttons:Array = null,closeHandler:Function = null,inQueue:Boolean = true):Alert
		{
			if (!buttons)
				buttons = defaultButtons;
			
			var alert:Alert = new Alert();
			alert.title = title;
			alert.text = text;
			alert.data = buttons;
			
			alert.closeHandler = closeHandler;
			PopupManager.instance.showPopup(alert,null,true,UIConst.POINT);
			
			return alert;
		}
		
		/**
		 * 排队显示
		 *  
		 * @param text
		 * @param title
		 * @param buttons
		 * @param closeHandler
		 * @param inQueue
		 * @return 
		 * 
		 */
		public static function commit(text:String,title:String = null,buttons:Array = null,closeHandler:Function = null,inQueue:Boolean = true):Alert
		{
			return show(text,title,buttons,closeHandler,true)
		}
		
		private var _title:String;
		private var _text:String;
		
		public var titleTextField:Text;
		public var textTextField:Text;
		public var buttonBar:ButtonBar;
		public var dragShape:UIBase;
		
		public function Alert(skin:*=null, replace:Boolean=true, paused:Boolean=false, fields:Object=null)
		{
			if (!skin)
				skin = defaultSkin;
			
			super(skin, replace);
		}
		
		private function itemClickHandler(event:ItemClickEvent):void
		{
			if (this.closeHandler!=null)
				this.closeHandler(event);
			destory();
		}
		
		/** @inheritDoc*/
		public override function set data(v:*) : void
		{
			super.data = v;
			if (buttonBar)
			{
				this.buttonBar.data = v;
				this.buttonBar.layout.vaildLayout();
				this.buttonBar.autoSize();
				LayoutUtil.silder(buttonBar,this,UIConst.CENTER);
			}
		}
		
		/** @inheritDoc*/
		public override function setContent(skin:*, replace:Boolean=true) : void
		{
			super.setContent(skin,replace);
			
			UIBuilder.buildAll(this);
			
			buttonBar.addEventListener(ItemClickEvent.ITEM_CLICK,itemClickHandler);
			DragManager.register(dragShape,this);
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			
			buttonBar.removeEventListener(ItemClickEvent.ITEM_CLICK,itemClickHandler);
			DragManager.unregister(dragShape);
			
			UIBuilder.destory(this);
			
			super.destory();
			
			PopupManager.instance.removePopup(this);
		}
	}
}