package flashk.controls
{
	import flashk.core.UIConst;
	
	import taurus.skin.CheckBoxSkin;

	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-6-5 下午10:57:08
	 * */     
	public class CheckBox extends Button
	{
		public static var defaultSkin:* = CheckBoxSkin;
		
		/**
		 * 值
		 */
		public var value:*;
		
		public function CheckBox(skin:*=null, replace:Boolean=true,autoRefreshLabelField:Boolean = true)
		{
			if (!skin)
				skin = defaultSkin;
			super(skin,replace,autoRefreshLabelField);
			super.autoSize = UIConst.RIGHT;
			toggle = true;
		}
	}
}