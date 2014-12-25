package flashk.controls
{
	import flashk.core.UIConst;
	
	import taurus.skin.HScrollBarSkin;

	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-7-11 下午1:38:50
	 * */     
	public class HScrollBar extends ScrollBar
	{
		public static var defaultSkin:* = HScrollBarSkin;
		
		public function HScrollBar(skin:*=null, replace:Boolean=true)
		{
			if (!skin)
				skin = defaultSkin;
			
			super(skin, replace);
			
			this.direction = UIConst.HORIZONTAL;
		}
	}
}

