package flashk.controls
{
	import flashk.core.UIConst;
	
	import taurus.skin.VSilderSkin;

	/**
	 * 纵向拖动块 
	 * @author kerry
	 * @version 1.0.0 
	 * 创建时间：2013-7-12 下午10:40:55
	 * */     
	public class VSilder extends Silder
	{
		public static var defaultSkin:* = VSilderSkin
		
		public function VSilder(skin:* =null, replace:Boolean=true, fields:Object=null)
		{
			if (!skin)
				skin = defaultSkin;
			
			super(skin, replace, fields);
			
			this.direction = UIConst.VERTICAL;
		}
	}
}