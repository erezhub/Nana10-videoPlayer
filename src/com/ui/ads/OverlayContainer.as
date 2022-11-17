package com.ui.ads
{
	import com.events.Nana10PlayerEvent;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import gs.TweenLite;
	
	import resources.overlay.CloseBtn;
	import resources.overlay.OpenBtn;
	
	public class OverlayContainer extends Sprite
	{
		public static const STANDART:int = 1;
		public static const PAUSE:int = 2;
		
		private var _type:int;
		private var _maxHeight:Number;
		private var _maxWidth:Number;
		private var isSwf:Boolean;
		private var btn:Sprite;	
		private var content:DisplayObject;
		private var center:Boolean;
		private var _height:Number;
		private var _width:Number;
		private var controls:Boolean;
		private var closeBtn:CloseBtn;
		private var openBtn:OpenBtn;
		
		public function OverlayContainer(maxWidth:Number,maxHeight:Number, url:String, type:int)
		{
			_maxWidth = maxWidth;
			_maxHeight = maxHeight;
			_type = type;
			load(url);
		}
		
		private function load(url:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			//var rand:String = (url.indexOf("?") == -1 ? "?rand=" : "&rand=") + int(1000*Math.random());
			loader.load(new URLRequest(url),context);
		}
		
		private function onLoaded(event:Event):void
		{
			content = event.target.content;
			addChild(content);
			if (content is MovieClip && (content as MovieClip).hasOwnProperty("stage_mc"))
			{
				DisplayUtils.resizeLoadedSWF(content,(content as MovieClip).stage_mc.width,(content as MovieClip).stage_mc.height,_maxWidth,_maxHeight,_type == PAUSE);
				_width = (content as MovieClip).stage_mc.width * content.scaleX;
				_height = (content as MovieClip).stage_mc.height * content.scaleY;	
				content.x = (_maxWidth - _width)/2;			
			}
			else
			{
				DisplayUtils.resize(this,_maxWidth,_maxHeight);				
				buttonMode = true;
			}			
			
			btn = new Sprite();
			btn.addChild(ShapeDraw.drawSimpleRect(content.width,content.height,1,0));
			addEventListener(MouseEvent.CLICK,onClicked);
			btn.x = content.x;
			btn.y = content.y;
			btn.buttonMode = true;
			addChild(btn);
			
			if (_type == STANDART)
			{
				closeBtn = new CloseBtn();
				closeBtn.x = content.x + width - closeBtn.width - 5;
				closeBtn.y = 5;
				closeBtn.addEventListener(MouseEvent.CLICK,onClose);
				addChild(closeBtn);
				
				openBtn = new OpenBtn();
				openBtn.x = content.x + (width - openBtn.width)/2;
				openBtn.y =  height// - openBtn.height + 50;
				openBtn.addEventListener(MouseEvent.CLICK,onOpen);
				openBtn.alpha = 0;
				addChild(openBtn);
			}
			
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.OVERLAY_READY));
		}
		
		private function onError(event:IOErrorEvent):void 
		{
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.OVERLAY_ERROR));
		}
		
		private function onClose(event:MouseEvent):void
		{
			TweenLite.to(content,0.3,{alpha: 0});
			TweenLite.to(closeBtn,0.3,{alpha: 0});
			TweenLite.to(openBtn,0.3,{alpha: 1});
		}
		
		private function onOpen(evnet:MouseEvent):void
		{
			TweenLite.to(content,0.3,{alpha: 1});
			TweenLite.to(closeBtn,0.3,{alpha: 1});
			TweenLite.to(openBtn,0.3,{alpha: 0});
		}
		
		private function onClicked(event:MouseEvent):void
		{
			if (event.target == closeBtn || event.target == openBtn) return;
			Debugging.printToConsole("--UserAction: clicked overlay");
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.OVERLAY_CLICKED));
		}
		
		public function displayStateChanged(stageWidth:Number, stageHeight:Number):void
		{
			if (content is MovieClip && (content as MovieClip).hasOwnProperty("stage_mc"))
			{
				content.scaleX = content.scaleY = 1;
				DisplayUtils.resizeLoadedSWF(content,(content as MovieClip).stage_mc.width,(content as MovieClip).stage_mc.height,stageWidth,stageHeight,_type == PAUSE);
				_width = (content as MovieClip).stage_mc.width * content.scaleX;
				_height = (content as MovieClip).stage_mc.height * content.scaleY;
				content.x = (stageWidth - _width)/2;				
			}
			else
			{
				x = y = 0;
				DisplayUtils.resize(this,stageWidth,stageHeight);
			}
			btn.width = content.width;
			btn.height = content.height;
			btn.x = content.x;
			btn.y = content.y;
			
			if (_type == STANDART)
			{
				closeBtn.x = content.x +  width - closeBtn.width - 5;
				openBtn.x = content.x + (width - openBtn.width)/2;
				openBtn.y =  height - (stage.displayState == StageDisplayState.FULL_SCREEN ? openBtn.height - 15 : 0);
			}
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (_type ==  PAUSE)
			{
				if (value)
				{
					if (content)
					{
						addChild(content);
						addChild(btn);
						if (content is MovieClip) 
							(content as MovieClip).gotoAndPlay(1);
					}
				}
				else if (content)
				{
					removeChild(content);
				}
			}
		}
		
		override public function get height():Number
		{
			if (isNaN(_height))
				return super.height;
			return _height;
		}
		
		override public function get width():Number
		{
			if (isNaN(_width))
				return super.width;
			return _width;
		}
	}
}