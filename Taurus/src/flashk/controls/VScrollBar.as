package flashk.controls
{
	import flashk.core.UIConst;
	
	import taurus.skin.VScrollBarSkin;

	/**
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-7-11 下午1:38:25
	 * */     
	public class VScrollBar extends ScrollBar
	{
		public static var defaultSkin:* = VScrollBarSkin;
		
		public function VScrollBar(skin:*=null, replace:Boolean=true)
		{
			if (!skin)
				skin = defaultSkin;
			
			super(skin, replace);
			
			this.direction = UIConst.VERTICAL;
		}
	}
}

