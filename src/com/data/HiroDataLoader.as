package com.data
{
	//import com.data.datas.items.ItemData;
	//import com.data.datas.items.partners.nana10.Nana10ItemData;
	//import com.data.datas.items.partners.nana10.Nana10VideoData;
	import com.data.datas.items.ItemData;
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.events.Nana10DataEvent;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.SharedObjectUtil;
	import com.fxpn.util.StringUtils;
	import com.ui.pannels.OpeningForm;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	public class HiroDataLoader extends EventDispatcher
	{
		private var hiroWrapper:Object;
		private var adsPlaylist:Array;
		private var dataRepository:Nana10DataRepository;
		
		private var movieData:Object;
		private var userSex:String;
		private var userAge:String;
		private var hiroTarget:String;
		private var tags:String;
		private var loadingPreroll:Boolean;
		private var _overlayURL:String;
		private var _overlayClickURL:String;
		private var _pauseOverlayURL:String;
		private var _pauseOverlayClickURL:String;
		private var _hasPreroll:Boolean;
		private var hasPlaylist:Boolean;
		private var _ready:Boolean;
		private var timeout:Timer;
		
		public function HiroDataLoader()
		{
			loadWrapper();	
			dataRepository = Nana10DataRepository.getInstance();
			
			timeout = new Timer(10000);
			timeout.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeout);
		}
		
		private function loadWrapper():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.load(new URLRequest(ExternalParameters.getInstance().HiroWrapper));
		}
		
		private function onLoaded(event:Event):void
		{
			_ready = true;
			adsPlaylist = [];
			var ep:ExternalParameters = ExternalParameters.getInstance();
			hiroWrapper = event.target.content;
			hiroWrapper.player = this;			
			movieData = {
						movieURL			:	ep.VideoID,
						movieDurationInSec 	: 	dataRepository.videoDuration,
						breakLocations		: 	""
						};
			//userAge = OpeningForm.AGE;
			switch (OpeningForm.AGE)
			{
				case "1":
					userAge = "0-17";
					break;
				case "2":
					userAge = "18-24";
					break;
				case "3":
					userAge = "25-34";
					break;
				case "4":
					userAge = "35-60";
					break;
				case "5":
					userAge = "60+";
					break;
				default:
					userAge = "";
					break;
			}
			userSex = OpeningForm.SEX;
			hiroTarget = ep.HiroTarget;
			tags = ep.ArticleID + ","+ ep.CategoryID + "," + ep.SectionID + ","+ep.VideoID;
			dispatchEvent(new Nana10DataEvent(Nana10DataEvent.HIRO_WRAPPER_READY));
		}
		
		public function getPreRoll():void
		{
			if (_hasPreroll || !_ready) return;
			Debugging.printToConsole("HiroDataLoader.getPreRoll");
			if (SharedObjectUtil.SharedObjectAvailable())
			{
				loadingPreroll = true;
				hiroWrapper.getPreRoll(movieData,hiroTarget,tags,userSex+", "+userAge);
				timeout.start();
			}
			else
			{
				Debugging.printToConsole("--HiroDataLoader.NoSharedObject");
				CommunicationLayer.getInstance().hasPreroll = false;
				dispatchEvent(new Nana10DataEvent(Nana10DataEvent.HIRO_DATA_READY));	
			}
		}
		
		public function getPlaylist():void
		{
			if (hasPlaylist || !_ready) return;
			var totalItems:int = dataRepository.totalItems;
			Debugging.printToConsole("HiroDataLoader.getPlaylist. dataRepositoyr.totalItems: " + totalItems);
			var breaksPositions:Array = [];
			var duration:Number = dataRepository.videoDuration;
			for (var i:int = 0; i < totalItems; i++)
			{
				var itemData:Nana10MarkerData = dataRepository.getItemByIndex(i);
				if (itemData.type == Nana10ItemData.MARKER && itemData.timeCode > 1 && itemData.timeCode < duration - 0.01 && itemData.markerType == Nana10MarkerData.AD) // locating the ads items
				{
					breaksPositions.push(itemData.timeCode);
				}
			}
			
			movieData.breakLocations = breaksPositions.toString();
			Debugging.printToConsole("breakLocations", breaksPositions.length);
			loadingPreroll = false;
			hiroWrapper.getPlaylist(movieData,hiroTarget,tags,userSex+", "+userAge);
		}
		
		public function playPlaylist(playlist:Array):void 
		{
			Debugging.printToConsole("HiroDataLoader.playPlaylist",playlist.length);
			timeout.stop();
			setPlayList(playlist);
			if (loadingPreroll) 
			{
				setPreroll();
			}
			else
			{
				setMidRolls();			
			}
			dispatchEvent(new Nana10DataEvent(Nana10DataEvent.HIRO_DATA_READY));
		}
		
		private function setPlayList(playList:Array):void
		{
			//adsPlaylist = [];
			var totalItems:int = dataRepository.totalItems;
			for (var i:int = 0; i < playList.length; i++) 
			{
				var track:Object = playList[i];	
				Debugging.printToConsole("hiro ad info: isVideoAd="+track.isVideoAd + ", insertOnPause=" + track.insertOnPause + ", url=" + track.url + ", position="+StringUtils.turnNumberToTime(track.posInSec) + ", adStartCompanion=" + track.adStartCompanion);
				if (track.isVideoAd && track.url.indexOf("dummy_ad") == -1)
				{
					adsPlaylist.push(track);
				}
				else if (track.insertOnPause && track.url.indexOf("dummy_ad") == -1)
				{
					_pauseOverlayURL = track.url;
					_pauseOverlayClickURL = track.clickUrl;
				}
				else if (track.insertOnPause == false && track.url.indexOf("dummy_ad") == -1 && track.url.indexOf("product=Overlay") > -1)
				{
					_overlayURL = track.url;
					_overlayClickURL = track.clickUrl;
				}
			}
		}
				
		private function setPreroll():void
		{
			_hasPreroll = true;
			if (adsPlaylist.length)
			{
				var preroll:Object = adsPlaylist[0];
				adsPlaylist = [preroll];
			}
			else
			{
				CommunicationLayer.getInstance().hasPreroll = false;
			}
		}
		
		private function setMidRolls():void
		{	
			hasPlaylist = true;
			// removing from the data-repository breaks' candidates which weren't matched by actual break locations set by Hiro 
			var totalItems:int = dataRepository.totalItems;
			var lastPlaylistItem:int = 0;
			for (var i:int = 0; i < totalItems; i++)
			{
				var itemData:Nana10MarkerData = dataRepository.getItemByIndex(i);
				if (itemData.type == Nana10ItemData.MARKER && itemData.markerType == Nana10MarkerData.AD) // locating the ads items
				{
					var playListitems:int = adsPlaylist.length;
					var found:Boolean = false;
					for (var j:int = lastPlaylistItem; j < playListitems; j++)
					{							
						if (Math.abs(adsPlaylist[j].posInSec - itemData.timeCode) < 1) 
						{	// candidate was matched
							found = true;
							lastPlaylistItem = j+1;
							break;
						}
					}
					if (!found) // candidate wasn't matched - remove from the DataRepository
					{
						dataRepository.removeItemById(itemData.id);
						// also removing its preload and pre-ad items
						for (var k:int = i-1; k > 0; k--)
						{
							if (dataRepository.getItemByIndex(k).type == Nana10ItemData.PRE_AD)
							{
								dataRepository.removeItemById(dataRepository.getItemByIndex(k).id);
								//k--;
								i--;
								totalItems--;
							}
							else if (dataRepository.getItemByIndex(k).type == Nana10ItemData.PRELOAD_AD)
							{
								dataRepository.removeItemById(dataRepository.getItemByIndex(k).id);
								k--;
								i--;
								totalItems--;
								break;
							}
						}
						totalItems--;
						i--;
						Debugging.printToConsole("REMOVED");
					}
				}
			}	
		}
		
		private function onError(evnet:IOErrorEvent):void
		{
			Debugging.printToConsole("--HiroDataLoader.onError");
			dispatchEvent(new Nana10DataEvent(Nana10DataEvent.HIRO_DATA_READY));
		}
		
		private function onTimeout(event:TimerEvent):void
		{
			Debugging.printToConsole("--HiroDataLoader.onTimeout");
			CommunicationLayer.getInstance().hasPreroll = false;
			dispatchEvent(new Nana10DataEvent(Nana10DataEvent.HIRO_DATA_READY));	
		}
		
		public function getAdByTime(timeCode:Number,postRoll:Boolean = false):Object
		{
			if (adsPlaylist == null) return null;			
			var totalitems:int = adsPlaylist.length;
			if (postRoll)
			{
				return (adsPlaylist[totalitems - 1]);	
			}			
			for (var i:int = 0; i < totalitems; i++)
			{
				if (Math.abs(adsPlaylist[i].posInSec - timeCode) < 1) return adsPlaylist[i];
			}
			return null;
		}
		
		public function prepareAd(adURL:String):void
		{
			hiroWrapper.prepareAd(adURL);
		}
		
		public function PrepareAdComplete(adData:Object):void
		{
			var event:Nana10DataEvent = new Nana10DataEvent(Nana10DataEvent.HIRO_AD_PREPARED);
			event.adURL = adData.url;
			event.adClickURL = adData.clickUrl;
			dispatchEvent(event);
		}
		
		public function reportViewedAd(adURL:String):void
		{
			hiroWrapper.reportViewedAd(adURL);
		}
		
		public function reportClickedAd(adURL:String):void
		{
			Debugging.printToConsole("HiroDataLoader.reportClickedAd");
			try
			{
				hiroWrapper.reportClickedAd(adURL);
			}
			catch (e:Error)
			{
				trace("reportClickedAd error",e.message);
			};
		}
		
		private function adClickURLReady(url:String):void
		{
			Debugging.printToConsole("HiroDataLoader.adClickURLReady");
			navigateToURL(new URLRequest(url),"_blank");
		}
		
		public function get pauseOverlayURL():String
		{			
			return _pauseOverlayURL;
		}
		
		public function get pauseOverlayClickURL():String
		{			
			return _pauseOverlayClickURL;
		}
		
		public function get overlayURL():String
		{			
			return _overlayURL;
		}
		
		public function get overlayClickURL():String
		{			
			return _overlayClickURL;
		}
		
		public function get hasPreroll():Boolean
		{
			return _hasPreroll;
		}
		
		public function reset():void
		{
			_hasPreroll = hasPlaylist = false;
		}
		
		/*public function pause():void
		{
			trace("pause");
		}*/
	}
}