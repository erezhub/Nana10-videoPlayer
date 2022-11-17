package com.ui.controls
{
	import com.fxpn.display.AccurateShape;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ProgressTooltip extends Sprite
	{
		private var tooltipArrow:Shape;
		private var tooltipBackground:AccurateShape;
		private var tooltipTextField:TextField;
		
		public function ProgressTooltip(bgColor:int = 0xffffff, fillAlpha:Number = 1, textColor:int = 0)
		{
			tooltipBackground = new AccurateShape();
			tooltipBackground.graphics.beginFill(bgColor,fillAlpha);
			tooltipBackground.graphics.drawRect(0,0,10,10);
			tooltipBackground.origSize(10,10);
			addChild(tooltipBackground);
			
			tooltipTextField = new TextField();
			tooltipTextField.selectable = false;
			tooltipTextField.x = 0;
			tooltipTextField.y = -1;
			addChild(tooltipTextField);
			
			tooltipArrow = new Shape();
			var g:Graphics = tooltipArrow.graphics;
			g.beginFill(bgColor);
			g.moveTo(0,3);
			g.lineTo(2,0);
			g.lineTo(-2,0);
			g.lineTo(0,3);
			g.endFill();
			addChild(tooltipArrow);
			
			var fmt:TextFormat = new TextFormat("Arial",9,textColor);
			fmt.align = TextFormatAlign.CENTER;
			tooltipTextField.defaultTextFormat = fmt;
			tooltipTextField.autoSize = TextFieldAutoSize.CENTER;	
		}
		
		public function set text(value:String):void
		{
			tooltipTextField.text = value;
			
			tooltipBackground.width = tooltipTextField.width + 12;
			tooltipBackground.x = -tooltipBackground.width/2;
			tooltipBackground.height = tooltipTextField.height;
			//tooltipTextField.x = (tooltipBackground.width - tooltipTextField.width)/2;
			tooltipTextField.x = tooltipBackground.x + 6;
			tooltipTextField.y = 1;
			tooltipArrow.y = tooltipBackground.height;
			
			//x-= tooltipBackground.width/2;
			
			y = -height;
			//tooltipArrow.x = tooltipBackground.width/2;
		}
		
		public function get text():String
		{
			return tooltipTextField.text;
		}							   
	}
}