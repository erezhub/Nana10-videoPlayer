package com.ui
{
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.events.NetStatusEvent;
	
	public class Nana10VideoPlayer extends MediandVideoPlayer
	{
		public var isHQ:Boolean;
		private var origHeight:Number;
		private var origWidth:Number;
		private var currentHeight:Number;
		private var cover:Sprite;	
		private var liveStreamVolume:Number;
		private var volumeChanged:Boolean;
		private var liveStreamPaused:Boolean;
		
		public function Nana10VideoPlayer(w:int=320, h:int=240, pausedAtStart:Boolean=false, enlargeVideo:Boolean=true, backgroundColor:int=-1, loadAndPlay:Boolean = true, debugStatus:Boolean = false)
		{
			super(w, h, pausedAtStart, enlargeVideo, backgroundColor,loadAndPlay, debugStatus);
			
			cover = new Sprite();
			cover.addChild(ShapeDraw.drawSimpleRect(w,h));
			addChild(cover);
			
			origHeight = h;
			origWidth = w;			
		}
		
		public function init():void
		{
			toggleCover(false);
		}
		
		override public function set source(path:String):void
		{
			super.source = path;
			StatsManagers.updatePlayerStats(StatsManagers.VideoRequest);
		}
		
		public function toggleCover(show:Boolean):void
		{
			cover.visible = show;
		}
		
		override protected function onVideoStatus(info:Object):void
		{
			super.onVideoStatus(info);
			if (stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				setSize(stage.stageHeight);
			}
		}
			
		override public function play():void
    	{
			if (Nana10PlayerData.getInstance().isLive)
			{
				resumeLiveStream();
				return;
			}
			Debugging.printToConsole("--Nana10VideoPlayer.play", Debugging.GetStackInfo(true),ns);
    		if (ns != null)    		
    		{
    			ns.resume();
    			_isPlaying = true;
    		}
    	}
		
		override public function pause():void
		{
			if (Nana10PlayerData.getInstance().isLive)
			{
				pauseLiveStream();				
			}
			else
			{
				super.pause();
			}
		}
				
		public function onDisplayStateChanged(event:FullScreenEvent):void
		{
			origHeight = height;
			origWidth = width;
			setSize(height);
		}
		
		// for some reason, when playing castup's live stram, after pausing the stream the then resuming it - there's no image, only audio.
		// till this issue is properly addressed, the stream isn't realy paused, but muted and its last frame is displayed
		public function resumeLiveStream():void
		{
			Debugging.printToConsole("--Nana10VideoPlayer.resumeLiveStream");
			if (cover.numChildren == 2) cover.removeChildAt(1);
			cover.visible = false;
			if (!isNaN(liveStreamVolume))super.volume = liveStreamVolume;
			liveStreamPaused = false;
			_isPlaying = true;
		}
		
		public function pauseLiveStream():void
		{
			Debugging.printToConsole("--Nana10VideoPlayer.pauseLiveStream");
			cover.visible = true;
			try
			{
				var bitmapData:BitmapData = new BitmapData(video.width,video.height);
				bitmapData.draw(video);
				cover.addChild(new Bitmap(bitmapData));
			}
			catch (e:Error) {}
			liveStreamVolume = volume;
			volumeChanged = false;
			super.volume = 0;
			liveStreamPaused = true;
			_isPlaying = false;
			if (isReady == false) pausedAtStart = true;
		}
		
		
		override public function set volume(value:Number):void
		{
			if (liveStreamPaused)
			{
				volumeChanged = true;
				liveStreamVolume = value;
			}
			else
			{
				super.volume = value;
			}			
		}
		
		public function setSize(h:Number):void
		{
			video.scaleX = video.scaleY = 1;
			video.x = video.y = 0;
			if (Nana10DataRepository.getInstance().previewGroupID == 0) DisplayUtils.resize(video,stage.stageWidth,h,true,true,true);
			video.scaleX/=scaleX;
			video.scaleY/=scaleY;
			video.x/=scaleX;
			video.y/=scaleY;
		}
				
		public function get videoWidth():Number
		{
			return video.width;
		}
		
		public function get videoHeight():Number
		{
			return video.height;
		}
		
		public function get videoX():Number
		{
			return video.x;
		}
		
		public function get VideoY():Number
		{
			return video.y;
		}
		
		public function get hasNetStream():Boolean
		{
			return ns != null;			
		}
		
		// TEMP
		public function get coverVisible():Boolean
		{
			return cover.visible;
		}

	}
}