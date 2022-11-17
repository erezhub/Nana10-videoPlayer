package com.ui.controls
{
	import com.fxpn.display.ShapeDraw;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class Playhead extends Sprite
	{
		private var tooltip:ProgressTooltip;
		
		public function Playhead()
		{			
			addChild(ShapeDraw.drawSimpleRect(1,12,0x172322));
			
			tooltip = new ProgressTooltip(0x172322,0.8,0xffffff);
			tooltip.text = "00:00";
			addChild(tooltip);
		}
		
		public function set currentTime(value:String):void
		{
			tooltip.x = 0;
			tooltip.text = value;
		}
	}
}