package flashk.controls
{

	/**
	 * 按钮条
	 * 
	 * 标签规则：子对象的render将会被作为子对象的默认skin
	 * 
	 * @author kerry
	 * 
	 */
	public class ButtonBar extends Repeater
	{
		public function ButtonBar(skin:*=null, replace:Boolean=true,ref:* = null,fields:Object = null)
		{
			if (!ref)
				ref = Button;
			
			super(skin, replace,ref);
		}
	}
}