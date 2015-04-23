package flashk.controls
{
	
	import flashk.core.DragManager;
	import flashk.core.PopupManager;
	import flashk.core.UIBuilder;
	import flashk.core.UIConst;
	import flashk.display.UIBase;
	import flashk.events.ActionEvent;
	import flashk.events.ItemClickEvent;
	import flashk.layout.LayoutUtil;
	import flashk.layout.LinearLayout;
	import flashk.layout.Padding;
	
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
		public static var confirm:String = "确认";
		
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
		
		public var buttonHandler:Function;
		
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
		public static function show(text:String,title:String = null,buttons:Array = null,buttonHandler:Function = null,inQueue:Boolean = true):Alert
		{
			if (!buttons)
				buttons = defaultButtons;
			
			var alert:Alert = new Alert();
			alert.title = title;
			alert.text = text;
			alert.data = buttons;
			
			alert.buttonHandler = buttonHandler;
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
		public var closeButton:Button;
		public var dragShape:UIBase;
		
		public function Alert(skin:*=null, replace:Boolean=true, paused:Boolean=false, fields:Object=null)
		{
			if (!skin)
				skin = defaultSkin;
			
			super(skin, replace);
		}
		
		private function itemClickHandler(event:ItemClickEvent):void
		{
			if (this.buttonHandler!=null)
				this.buttonHandler(event.data);
			destory();
		}
		
		/** @inheritDoc*/
		public override function set data(v:*) : void
		{
			super.data = v;
			if (buttonBar)
			{
				(this.buttonBar.layout as LinearLayout).horizontalGap = 5;
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
			if(buttonBar)
			{
				buttonBar.autoLabelField = true;
				buttonBar.textPadding = new Padding(5,0,5,0);
				buttonBar.addEventListener(ItemClickEvent.ITEM_CLICK,itemClickHandler);
			}
			if(closeButton!=null)
			{
				closeButton.action="close";
				closeButton.addEventListener(ActionEvent.ACTION,closeButtonClickHandler);
			}
			DragManager.register(dragShape,this);
		}
		private function closeButtonClickHandler(event:ActionEvent):void
		{
			if (this.buttonHandler!=null)
				this.buttonHandler(null);
			destory();
		}
		/** @inheritDoc*/
		public override function destory() : void
		{
			if (destoryed)
				return;
			if(buttonBar)
				buttonBar.removeEventListener(ItemClickEvent.ITEM_CLICK,itemClickHandler);
			if(closeButton)
				closeButton.removeEventListener(ActionEvent.ACTION,closeButtonClickHandler);
			DragManager.unregister(dragShape);
			
			UIBuilder.destory(this);
			
			super.destory();
			
			PopupManager.instance.removePopup(this);
			this.buttonHandler=null;
		}
	}
}