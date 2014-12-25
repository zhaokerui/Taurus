package flashk.controls
{
	import flash.events.MouseEvent;
	
	import flashk.core.UIConst;
	
	import taurus.skin.RadioButtonSkin;
	
	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-5 下午10:57:55
	 * */     
	public class RadioButton extends Button
	{
		public static var defaultSkin:* = RadioButtonSkin;
		
		private var _groupName:String;
		
		
		/**
		 * data中作为value的字段
		 */
		public var valueField:String;
		
		private var _value:*;
		
		public function RadioButton(skin:*=null, replace:Boolean=true,autoRefreshLabelField:Boolean = true)
		{
			if (!skin)
				skin = defaultSkin;
			super(skin,replace,autoRefreshLabelField);
			super.autoSize = UIConst.RIGHT;
		}
		
		/**
		 * 值
		 */
		public function get value():*
		{
			return valueField ? data[valueField] :_value;
		}
		
		public function set value(v:*):void
		{
			if (valueField)
			{
				if (data == null)
					data = new Object();
				
				super.data[valueField] = v;
			}
			else
				_value = v;
		}
		/**
		 * 所属的组名
		 */
		public function get groupName():String
		{
			return _groupName;
		}
		
		public function set groupName(v:String):void
		{
			_groupName = v;
			var g:RadioButtonGroup = RadioButtonGroup.getGroupByName(v);
			g.addItem(this);
		}
		public override function set selected(v:Boolean) : void
		{
			if (super.selected == v)
				return;
			
			super.selected = v;
			
			if (groupName && v)
			{
				var g:RadioButtonGroup = RadioButtonGroup.getGroupByName(groupName);
				g.selectedItem = this;
			}
		} 
		protected override function clickHandler(event:MouseEvent):void
		{
			super.clickHandler(event);
			
			this.selected = true;
		}
		public override function destory():void
		{
			if (destoryed)
				return;
			
			if (groupName)
			{
				var g:RadioButtonGroup = RadioButtonGroup.getGroupByName(groupName);
				g.removeItem(this);
			}
			
			super.destory();
		}
	}
}