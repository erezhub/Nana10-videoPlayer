package com.data
{
	import com.data.datas.items.partners.nana10.Nana10ItemData;

	public class Nana10Comment extends Nana10ItemData
	{
		public function Nana10Comment(id:int, author:String, content:String )
		{
			super(Nana10ItemData.COMMENT,id,author,0,null,null, content);
		}
		
		public function get content():String
		{
			return description;
		}
		
		public function get author():String
		{
			return title;
		}
		
	}
}