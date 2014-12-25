package flashk.controls
{
	import flashk.core.UIConst;
	
	import taurus.skin.HSilderSkin;

	/**
	 * 横向拖动块 
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-7-12 下午10:39:55
	 * */     
	public class HSilder extends Silder
	{
		public static var defaultSkin:* = HSilderSkin
		
		public function HSilder(skin:* =null, replace:Boolean=true, fields:Object=null)
		{
			if (!skin)
				skin = defaultSkin;
			
			super(skin, replace, fields);
			
			this.direction = UIConst.HORIZONTAL;
		}
	}
}