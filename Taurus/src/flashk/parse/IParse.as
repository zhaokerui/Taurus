package flashk.parse
{
	public interface IParse
	{
		/**
		 * 解析
		 * @param target
		 * 
		 */
		function parse(target:*):void;
		
		/**
		 * 子对象
		 * @param v
		 * 
		 */
		function get children():Array;
		
		/**
		 * 父对象
		 * @param v
		 * 
		 */
		function get parent():IParse;
		function set parent(v:IParse):void;
	}
}