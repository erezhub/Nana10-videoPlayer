/**
 * this class is relevant only for live-stream, and then only when the 'CheckForLinkChange' property in the FlashVars is set to 1/true
 * when applicable, it calls every 20 seconds to a web-service which returns an updated data object weather the video source should be changed, or even the entire player.
 * this is usefull when the live stream's source is changed, so users who already watch the stream, will be updated. 
 */ 
package com.data
{
	import com.events.RequestEvents;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	import com.io.DataRequest;
	import com.ui.Nana10VideoPlayer;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;

	public class CheckVideoLinkChange
	{
		private static var timer:Timer;
		private static var dataRequest:URLLoader;
		private static var linkLoader:URLLoader;
		private static var urlRequset:URLRequest;
		private static var lastGMasp:String;
		private static var exParams:ExternalParameters;
		private static var switchToZixi:Boolean;
		private static var _playingZixi:Boolean;
		
		public static function init():void
		{
			Debugging.printToConsole("--CheckForLinkChange");
			exParams = ExternalParameters.getInstance();
			
			timer = new Timer(20000); 
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			timer.start();
			
			dataRequest = new URLLoader();
			dataRequest.addEventListener(Event.COMPLETE,onResponse);
			dataRequest.addEventListener(IOErrorEvent.IO_ERROR,onError);
			linkLoader = new URLLoader();
			linkLoader.addEventListener(Event.COMPLETE,onLinkReady);
			linkLoader.addEventListener(IOErrorEvent.IO_ERROR,onError);
			urlRequset = new URLRequest();
			urlRequset.url = "http://common"+ CommunicationLayer.getInstance().environment +".nana10.co.il/Video/VideoLinkChange.ashx?VideoID=" + exParams.VideoID + "&VideoURL=" + escape(exParams.VideoLink);
		}
		
		public static function hold():void
		{
			timer.stop();	
		}
		
		public static function resume():void
		{
			timer.start();	
		}
		
		public static function checkNow():void
		{
			urlRequset.url = "http://common"+ CommunicationLayer.getInstance().environment +".nana10.co.il/Video/VideoLinkChange.ashx?VideoID=" + exParams.VideoID + "&VideoURL=" + escape(exParams.VideoLink);
			dataRequest.load(urlRequset);
		}
		
		private static function onTimer(event:TimerEvent):void
		{				
			dataRequest.load(urlRequset);
		}
		
		private static function onResponse(event:Event):void
		{
			Debugging.printToConsole("--CheckForLinkChange.onResponse");
			var data:Array = (event.target.data as String).split(",");
			var changed:Boolean;
			var videoURL:String;
			var replacePlayer:Boolean;
			var playerType:String;
			var IsLive:String;
			var CheckForLinkChange:String;
			for (var i:int = 0; i < data.length; i++)
			{
				if (data[i].indexOf("VideoURL") > -1)
				{					
					videoURL = data[i];
					var i1:int = videoURL.indexOf(":");
					videoURL = videoURL.substring(i1+2,videoURL.length-1);
					if (videoURL.length < 5) videoURL = ""; // if the parsed videoURL is empty, its value can turn into """
				}
				else if (data[i].indexOf("PlayerType") > -1)
				{
					playerType = data[i].split(":")[1]
				}
				else if (data[i].indexOf("IsLinkChanged") > -1)
				{
					changed = data[i].split(":")[1] == "1"
				}
				else if (data[i].indexOf("CheckForLinkChange") > -1)
				{
					CheckForLinkChange = data[i].split(":")[1];
				}
				else if (data[i].indexOf("IsLive") > -1)
				{
					IsLive = data[i].split(":")[1];
				}
			}
			if (playerType == "1")
			{	// change to the WMV player - call a JS function to replace the entire player
				try
				{
					ExternalInterface.call("MediAnd.ChangePlayerType",videoURL , CheckForLinkChange, IsLive, playerType);
				}
				catch (e:Error) 
				{
					Debugging.printToConsole("MediAnd.ChangePlayerType ERROR");	
				}
			}
			else
			{
				if (changed && !StringUtils.isStringEmpty(videoURL))
				{
					if (videoURL.indexOf("gm.asp") > -1)
					{
						loadGMasp(videoURL);
					}
					else if ((!switchToZixi || videoURL.indexOf("zixi") == -1) && !_playingZixi)
					{
						changeVideoLink(videoURL);
					}
				}
			}
			if (CheckForLinkChange == "0")
			{	// stop checking
				exParams.CheckForLinkChange = 0;
				timer.stop();
			}
		}
		
		private static function onError(event:IOErrorEvent):void {}
		
		private static function loadGMasp(url:String):void
		{
			switchToZixi = _playingZixi = false;
			if (lastGMasp == null)
			{
				lastGMasp = url;
			}
			else if (lastGMasp != url)
			{	// it is possible that the 'IsLinkChanged' property returned from the WS is true, but the link wasn't changed actually.
				// so making sure that the link recieved is actually new
				Debugging.printToConsole("--CheckVideoLinkChange.loadGMasp",url);
				var linkRequest:URLRequest = new URLRequest(url + "&curettype=1");
				linkLoader.load(linkRequest);
				lastGMasp = url;
			}
		}
		
		private static function onLinkReady(event:Event):void
		{	// new link is ready - replace the player's source
			var videoURL:String = event.target.data;
			if (videoURL.indexOf(";") > -1)
			{
				Nana10PlayerData.getInstance().alternativeVideosURLArray = videoURL;
				Nana10PlayerData.getInstance().resetAlternateVideoIndex();
				videoURL = Nana10PlayerData.getInstance().videoLink;
			}
			var videoPlayer:Nana10VideoPlayer = CommunicationLayer.getInstance().videoPlayer;
			if (videoPlayer.source != videoURL)	
			{
				exParams.VideoLink = lastGMasp; 
				urlRequset.url = "http://common"+ CommunicationLayer.getInstance().environment +".nana10.co.il/Video/VideoLinkChange.ashx?VideoID=" + exParams.VideoID + "&VideoURL=" + escape(lastGMasp);
				videoPlayer.dispose(true);
				videoPlayer.source = videoURL;
				videoPlayer.startLoading();
			}
		}
		
		private static function changeVideoLink(url:String):void
		{
			Debugging.printToConsole("--CheckForLinkChange.changeVideoLink",url);
			exParams.VideoLink = url;
			switchToZixi = _playingZixi = url.indexOf("zixi") > -1; 
			if (switchToZixi)
			{
				Nana10DataRepository.getInstance().videoLink = url;
				CommunicationLayer.getInstance().switchToZixi();
				lastGMasp = url;
			}
			else
			{
				var nana10PlayerData:Nana10PlayerData = Nana10PlayerData.getInstance();
				nana10PlayerData.autoPlay = true;
				nana10PlayerData.showAds = false;
				nana10PlayerData.prepareData();
				nana10PlayerData.makeDataRequest();
			}
		}
		
		public static function set playingZixi(value:Boolean):void
		{
			_playingZixi = value;
			lastGMasp = "";
		}
	}
}