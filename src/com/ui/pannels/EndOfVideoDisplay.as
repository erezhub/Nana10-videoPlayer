package com.ui.pannels
{
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.stats.StatsManagers;
	import com.events.Nana10PlayerEvent;
	import com.events.RequestEvents;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	import com.fxpn.util.TextFieldUtils;
	import com.io.DataRequest;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;
	
	import resources.Logo;
	
	public class EndOfVideoDisplay extends Sprite
	{
		private var bg:Shape;
		private var clipsData:XML;
		private var nextClipIndex:int;
		private var nextVideoID:int;
		private var nextArticleID:int;
		private var dataReady:Boolean;
		private var _height:Number;
		private var displayTimer:Timer;
		private var imageContainer:Sprite;
		private var title_txt:TextField;
		private var headline_txt:TextField;
		private var logo:Logo;
		private var picLoader:Loader;
		
		public function EndOfVideoDisplay()
		{
			bg = ShapeDraw.drawSimpleRect(100,100,0xffffff);
			addChild(bg);
			imageContainer = new Sprite();
			addChild(imageContainer);
			
			var fmt:TextFormat = new TextFormat("Arial",16);
			title_txt = new TextField();
			title_txt.defaultTextFormat = fmt;
			addChild(title_txt);
			headline_txt = new TextField();
			fmt.bold = true;
			headline_txt.defaultTextFormat = fmt;
			headline_txt.text = ":הקטע הבא";
			headline_txt.autoSize = TextFieldAutoSize.RIGHT;
			addChild(headline_txt);
			//headline_txt.border = title_txt.border = true;
			
			logo = new Logo();
			DisplayUtils.setTintColor(logo,0);
			addChild(logo);
			
			displayTimer = new Timer(5000,1);
			displayTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
			
			picLoader = new Loader();
			picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageReady);
			picLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
			
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			setBG();
		}
		
		private function setBG():void
		{
			bg.width = stage.stageWidth;
			bg.height = _height;	
			
			DisplayUtils.spacialAlign(bg,logo,DisplayUtils.LEFT,5,DisplayUtils.BOTTOM,5);
			if (imageContainer.width) placeElements();
		}
		
		// load end-of-video data
		public function loadData():void
		{
			Debugging.printToConsole("--EndOfVideoDisplay.loadData");
			if (clipsData == null)
			{	// making this load once - loading a list of (up to) 20 clips, and playing them one after the other
				var url:String = CommunicationLayer.getInstance().actionsServer + "GetRelatedVideos?ServiceID="+ExternalParameters.getInstance().ServiceID+"&Top=20&ExcludeVideoID="+ExternalParameters.getInstance().VideoID;
				var dataRequest:DataRequest = new DataRequest();
				dataRequest.addEventListener(RequestEvents.DATA_READY, onDataReady);
				dataRequest.addEventListener(RequestEvents.DATA_ERROR, onDataError);
				dataRequest.load(url);
			}
			/*else
			{
				setData(clipsData.Video[nextClipIndex]);
			}*/
		}
		
		private function onDataReady(event:RequestEvents):void
		{
			Debugging.printToConsole("--EndOfVideoDisplay.onDataReady",event.xmlData.children().length());
			clipsData = event.xmlData;			
			if (clipsData.ActionSucceeded == "False")
			{
				event.errorMessage = clipsData.ErrorDescription;
				clipsData = null;
				onDataError(event);
				return;
			}
			setData(clipsData.Video[nextClipIndex]);
			dataReady = true;
			if (visible) displayTimer.start();
		}
		
		private function onDataError(event:RequestEvents):void
		{
			Debugging.printToConsole("--EndOfVideoDisplay.onDataError",event.errorMessage);
			if (visible)
			{
				dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.END_OF_VIDEO_ERROR));
			}
		}
		
		private function setData(data:XML):void
		{
			Debugging.printToConsole("--EndOfVideoDisplay.setData");
			if (data == null)
			{	// reached the end of the list - start from the begining
				nextClipIndex = 0;
				data = clipsData.Video[nextClipIndex];
			}
			Debugging.printToConsole(nextClipIndex-1,data.@VideoID,data.@ArticleID,data.@Title);
			nextVideoID = data.@VideoID; 
			nextArticleID = data.@ArticleID; 
			title_txt.text = data.@Title;
			title_txt.autoSize = TextFieldAutoSize.CENTER;
			
			if (imageContainer.numChildren) imageContainer.removeChildAt(0);
			if (String(data.@PicPath).length)
			{   // load the thumb
				imageContainer.addChild(picLoader);				
				picLoader.load(new URLRequest(data.@PicPath),new LoaderContext(true));				
			}
		}
		
		private function onImageReady(event:Event):void
		{
			try
			{
				var image:DisplayObject = event.target.content as DisplayObject
			}
			catch (e:Error)
			{
				StatsManagers.updatePlayerStats(StatsManagers.MoreInNanaThumbError,"Error loading end of video image. "+e.message);
				Debugging.printToConsole("EndOfVideoDisplay - error loading image: ", e.message)
				return;
			}
			placeElements();
		}
		
		private function placeElements():void
		{
			imageContainer.x = imageContainer.y = 0;
			imageContainer.scaleX = imageContainer.scaleY = 1;
			DisplayUtils.resize(imageContainer,bg.width*0.5,bg.height*0.5,false);
			DisplayUtils.align(bg,imageContainer);
			title_txt.y = imageContainer.y - title_txt.height - 5;
			DisplayUtils.align(bg,title_txt,true,false);
			headline_txt.y = title_txt.y - headline_txt.height + 5;
			headline_txt.x = imageContainer.x + imageContainer.width - headline_txt.width;
		}
		
		private function onImageError(event:IOErrorEvent):void {}
		
		private function onTimer(event:TimerEvent):void
		{
			var nana10PlayerEvent:Nana10PlayerEvent = new Nana10PlayerEvent(Nana10PlayerEvent.REPLACE_VIDEO);
			nana10PlayerEvent.videoId = nextVideoID;
			nana10PlayerEvent.articleId = nextArticleID;
			dispatchEvent(nana10PlayerEvent);
			//dataReady = false;
		}
		
		override public function set visible(value:Boolean):void
		{
			if (value)
			{
				if (dataReady)
				{
					displayTimer.start();
				}
				else
				{
					loadData();
				}
			}
			else if (clipsData && visible)
			{
				setData(clipsData.Video[++nextClipIndex]);
			}
			super.visible = value;
		}
		
		override public function set height(value:Number):void
		{
			_height = value;
			if (stage) setBG();
		}
	}
}