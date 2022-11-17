package com
{
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.ImageSnapper;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.data.WatchedVideoData;
	import com.data.items.Nana10SegmentData;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	import com.ui.controls.ControlsBar;
	
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	public class KeyboardShortcutsMangaer
	{
		public static var stage:Stage;
		public static var controls:ControlsBar;
		public static var imageSnapper:ImageSnapper;
		public static var allowAllKeybaordShortcuts:Boolean;
				
		public static function enableKeyboardShortcuts():void
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public static function disableKeyboardShortcuts():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private static function onKeyUp(event:KeyboardEvent):void
		{
			if ((event.keyCode >= Keyboard.F1 && event.keyCode <= Keyboard.F15) || stage == null) return; // ignore F keys and when off-stage
			var char:String = String.fromCharCode(event.keyCode);
			var commLayer:CommunicationLayer = CommunicationLayer.getInstance();
			if (char == "E" && event.altKey && event.ctrlKey && event.shiftKey)
			{
				Debugging.alert(" Created by eRez Huberman\n\tMediEND Inc., Nana10\n\t(c)  2009-2012");
				Nana10PlayerData.getInstance().showAds = false;
				return;
			}
			if (event.ctrlKey && event.shiftKey)
				if (event.keyCode == Keyboard.END)
				{ // skip ad
					//controls.skipAd();
					commLayer.skipAd();
					return;
				}
				else if (event.keyCode == Keyboard.HOME)
				{
					commLayer.showAd();
					return;
				}
			if (char.toLowerCase() == "d" && event.ctrlKey && event.altKey)
			{ // toggle debugging console
				Debugging.onScreen = !Debugging.onScreen;
				return;
			}
			if (char.toLowerCase() == "c" && event.ctrlKey && event.altKey)
			{ // clear debugging console
				Debugging.clearOnScreen();
				return;
			}
			if (char.toLowerCase() == "s" && event.ctrlKey && event.altKey)
			{	// display the video player's loading speed
				controls.displayLoadingSpeed();
				return;
			}
			if (imageSnapper && event.shiftKey && event.keyCode == Keyboard.ENTER)
			{	// snap video's image using the ImageSnapper (if available)
				imageSnapper.saveImage(null);
				return;
			}
			
			//if (allowAllKeybaordShortcuts)
				//{
				if (char== "f" || char == "F")
						controls.onToggleFullscreen();
				
				if (commLayer.state == CommunicationLayer.PLAYER)
				{
					switch (char)
					{
						case "e":
						case "E":
							commLayer.toggleShare();
							break;
						case "H":
						case "h":
							controls.toggleHQ();
							break;
					}
				}
				var realTime:Number;
				switch (event.keyCode)
				{
					case Keyboard.SPACE:
						Debugging.printToConsole("--UserAction: keyboard Space",StringUtils.turnNumberToTime(commLayer.playheadTime,true,true,true));
						controls.toggleVideo(true);
						break; 
					case Keyboard.LEFT:
						if (commLayer.state == CommunicationLayer.PLAYER && commLayer.playheadTime > 20 && commLayer.enableSeek)
						{ 
							Debugging.printToConsole("--UserAction: Keyboard Left ",StringUtils.turnNumberToTime(commLayer.playheadTime,true,true,true));
							WatchedVideoData.closeTiming(commLayer.playheadTime);
							realTime = calculateAccurateTime(commLayer.playheadTime-20);
							WatchedVideoData.addTiming(realTime);
							StatsManagers.updatePlayerStats(StatsManagers.JumpToTime,StringUtils.turnNumberToTime(realTime,true,true,true));
							commLayer.seek(realTime);
						}
						break;
					case Keyboard.RIGHT:
						if (commLayer.state == CommunicationLayer.PLAYER && commLayer.playheadTime + 20 < commLayer.videoNetDuration && commLayer.enableSeek) 
						{
							Debugging.printToConsole("--UserAction: Keyboard Right",StringUtils.turnNumberToTime(commLayer.playheadTime,true,true,true));
							WatchedVideoData.closeTiming(commLayer.playheadTime);
							realTime = calculateAccurateTime(commLayer.playheadTime+20);
							WatchedVideoData.addTiming(realTime);
							StatsManagers.updatePlayerStats(StatsManagers.JumpToTime,StringUtils.turnNumberToTime(realTime,true,true,true));
							commLayer.seek(realTime);
						}
						break;
					case Keyboard.UP:
						controls.changeVolume(true);
						break;
					case Keyboard.DOWN:
						controls.changeVolume(false);					
						break;					
				} 
			/*}
			else if (event.keyCode == Keyboard.SPACE) 
			{
				Debugging.firebug("--UserAction: Keyboard Space",StringUtils.turnNumberToTime(commLayer.playheadTime,true,true,true));
				controls.toggleVideo(true);
			}*/
		}
		
		private static function calculateAccurateTime(currentTime:Number):Number
		{
			var dataRepository:Nana10DataRepository = Nana10DataRepository.getInstance();
			var totalItems:int = dataRepository.totalItems;
			var segmentsGap:Number = 0;
			for (var i:int = 0; i < totalItems; i++)
			{
				if (dataRepository.getItemByIndex(i) is Nana10SegmentData)
				{
					var segmentData:Nana10SegmentData = dataRepository.getItemByIndex(i) as Nana10SegmentData;
					segmentsGap+=segmentData.gapToPreviousSegment;
					if (currentTime + segmentsGap > segmentData.timeCode && currentTime + segmentsGap < segmentData.endTimecode)
					{
						CommunicationLayer.getInstance().currentSegmentId = segmentData.id;
						currentTime+=segmentsGap;
						CommunicationLayer.getInstance().scenesGaps = segmentsGap;
						break;
					}
				}
			}
			return currentTime;
		}
	}
}