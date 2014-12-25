package flashk.controls
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import flashk.utils.ObjectUtil;

	
	[Event(name="change",type="flash.events.Event")]
	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-6 下午2:17:13
	 * */     
	public class RadioButtonGroup extends EventDispatcher
	{
		private static var groups:Dictionary = new Dictionary();
		/**
		 * 手动执行构造方法是无效的，应当使用getGroupByName方法创建
		 * 
		 * @param groupName
		 * 
		 */
		public function RadioButtonGroup(privateClass:PrivateClass)
		{
		}
		/**
		* 获取单选框组
		*  
		* @param groupName
		* @return 
		* 
		*/
		public static function getGroupByName(groupName:String):RadioButtonGroup
		{
			if (!groups[groupName])
			{
				var group:RadioButtonGroup= new RadioButtonGroup(new PrivateClass());
				group.groupName = groupName;
				groups[groupName] = group;
			}
			
			return groups[groupName];
		}
		
		/**
		 * 组名
		 */
		public var groupName:String;
		
		/**
		 * 包含的单选框
		 */
		public var items:Array;
		
		private var _selectedItem:RadioButton;
		
		/**
		 * 选择的组
		 */
		public function get selectedItem():RadioButton
		{
			return _selectedItem;
		}
		
		public function set selectedItem(v:RadioButton):void
		{
			if (_selectedItem == v)
				return;
			
			_selectedItem = v;
			
			for (var i:int = 0;i < items.length;i++)
			{
				var item:RadioButton = items[i] as RadioButton;
				item.selected =  (item == v);
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 选择的值
		 */
		public function get selectedValue():*
		{
			return _selectedItem ? _selectedItem.value : null;
		}
		
		public function set selectedValue(v:*):void
		{
			for (var i:int = 0;i < items.length;i++)
			{
				var item:RadioButton = items[i] as RadioButton;
				if (item.value == v)
				{
					selectedItem = item;
					return;
				}
			}
			selectedItem = null;
		}
		
		
		/**
		 * 增加 
		 * @param item
		 * 
		 */
		public function addItem(item:RadioButton):void
		{
			if (!items)
				items = [item];
			else
				items.push(item);
		}
		
		/**
		 * 删除 
		 * @param item
		 * 
		 */
		public function removeItem(item:RadioButton):void
		{
			if (items)
			{
				ObjectUtil.remove(items,this);
				if (items.length == 0)
					delete groups[groupName];
			}
		}
	}
}
class PrivateClass{}