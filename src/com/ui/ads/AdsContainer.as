package com.ui.ads
{
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.HiroDataLoader;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.data.Version;
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.data.items.Nana10SegmentData;
	import com.events.Nana10DataEvent;
	import com.events.Nana10PlayerEvent;
	import com.events.RequestEvents;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	import com.io.DataRequest;
	import com.ui.Nana10VideoPlayer;
	
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	[Event (name="loadVideo", type="com.events.Nana10PlayerEvent")]	
	[Event (name="adBegins", type="com.events.Nana10PlayerEvent")]
	[Event (name="adEnds", type="com.events.Nana10PlayerEvent")]
	[Event (name="adError", type="com.events.Nana10PlayerEvent")]
	public class AdsContainer extends Nana10VideoPlayer
	{
		private var externalParams:ExternalParameters;
		private var adsDataRequest:DataRequest;
		private var adClickRequest:DataRequest;
		private var erateReportRequest:DataRequest;
		private var _adsURL:String;
		private var adClickURL:String;
		private var adUpdateURL:String;
		private var erateCode:String;
		private var adURL:String;
		private var _hasPreroll:Boolean;
		private var _hasPostroll:Boolean;
		private var hadPreroll:Boolean;
		private var hadPostroll:Boolean;
		private var _loadingPostroll:Boolean;
		private var midrollReady:Boolean;
		private var _playWhenDataReady:Boolean;
		private var prerollLoadTimer:Timer;
		private var adType:int;
		private var is3rdParty:Boolean;
		private var timer:Timer;
		private var hiroDataLoader:HiroDataLoader;
		private var adIndex:int;
		private var _showPreAd:Boolean;
		private var hasAds:Boolean;
		private var loadingTime:int;
		private var reportedPreroll:Boolean;
		
		public function AdsContainer(w:int=320, h:int=240, pausedAtStart:Boolean=false, enlargeVideo:Boolean=true, backgroundColor:int=-1, loadAndPlay:Boolean=true, enableDebug:Boolean=false)
		{
			super(w, h, pausedAtStart, enlargeVideo, backgroundColor, loadAndPlay, enableDebug);
				
			externalParams = ExternalParameters.getInstance();
			setAdsURL();
		
			addEventListener(MouseEvent.CLICK, onClick);
			
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			_showPreAd = true;
		}
		
		public function setAdsURL(CM8Target:String = null):void
		{
			if (CM8Target == null)
			{
				_adsURL = "http://nana10.checkm8.com/adam/inline?template=inline_nana10_flash_video&cat=" + externalParams.CM8Target;
			}
			else
			{
				_adsURL = "http://nana10.checkm8.com/adam/inline?template=inline_nana10_flash_video&cat=" + CM8Target;
			}
		}
		
		public function getHiroData():void
		{
			if (hiroDataLoader == null) 
			{
				hiroDataLoader = new HiroDataLoader();
				hiroDataLoader.addEventListener(Nana10DataEvent.HIRO_WRAPPER_READY, onHiroWrapperReady);
				hiroDataLoader.addEventListener(Nana10DataEvent.HIRO_DATA_READY, onHiroDataReady);
				hiroDataLoader.addEventListener(Nana10DataEvent.HIRO_AD_PREPARED,onAdPrepared);
			}
			else if (hiroDataLoader.hasPreroll == false)
			{
				hiroDataLoader.getPreRoll();
				adIndex = 0;
			}
			else				
			{
				hiroDataLoader.getPlaylist();
				adIndex = 0;
			}
		}
		
		private function onHiroWrapperReady(event:Nana10DataEvent):void
		{
			hiroDataLoader.getPreRoll();
			adIndex = 0;
		}
		
		private function onHiroDataReady(event:Nana10DataEvent):void
		{
			dispatchEvent(event);
		}
		
		// before each KF containing ad - add a KF 3 seconds earlier, which will hold an empyt item, just so the pre-ad message would pop 
		public function addPreAds():void
		{
			if (hasAds) return;
			var duration:Number = CommunicationLayer.getInstance().videoGrossDuration//.sceneDuration;
			//var hasAds:Boolean
			//var preAdData:Nana10MarkerData = new Nana10MarkerData(0,Nana10ItemData.PRE_AD);//new Nana10ItemData(Nana10ItemData.PRE_AD,0,"pread",0); // the same object is used in every keyframe
			//var loadAdData:Nana10MarkerData = new Nana10MarkerData(0,Nana10ItemData.PRELOAD_AD);//new Nana10ItemData(Nana10ItemData.LOAD_ADD,0,"laodAd",0);
			var dataRepository:Nana10DataRepository = Nana10DataRepository.getInstance();
			var totalItems:int = dataRepository.totalItems;
			var lastAd:Number = 0;
			for (var i:int = 0; i < totalItems; i++)
			{
				var itemData:Nana10MarkerData = dataRepository.getItemByIndex(i);
				if (itemData.type == Nana10ItemData.MARKER && (dataRepository.previewGroupID == 0 || itemData.belongsToGroup(dataRepository.previewGroupID)) && itemData.markerType == Nana10MarkerData.AD) // locating the ads items
				{
					var tc:Number = itemData.timeCode;
					if (tc > duration) continue;
					if (tc > CommunicationLayer.SECS_BEFORE_AD_MESSAGE + 1)
					{   // if the ad is placed more than 7 seconds after the video's start - add a pre-ad
						addAutomaticMarker(tc-CommunicationLayer.SECS_BEFORE_AD_MESSAGE,Nana10ItemData.PRE_AD);
						if (tc + 0.5 > duration)
						{  // if the ad is less than 100ms before the video ends - its a post-roll
							_hasPostroll = hadPostroll = true;
						}
						if (tc > CommunicationLayer.AD_PREBUFFER_TIME)
						{
							addAutomaticMarker(tc-CommunicationLayer.AD_PREBUFFER_TIME,Nana10ItemData.PRELOAD_AD);
						}
					}
					lastAd = tc;
					hasAds = true;							
				}
			}
			if (!hasAds) // if the movie's data doesn't contains ads - add automatic ads
			{
				addAutomaticAds(dataRepository,totalItems);
				hasAds = true;
			}
			if (CommunicationLayer.getInstance().hasPostroll)
			{
				_hasPostroll = hadPostroll = true;
				if (duration > CommunicationLayer.AD_PREBUFFER_TIME)
				{
					if (duration - CommunicationLayer.AD_PREBUFFER_TIME < lastAd)
					{
						addAutomaticMarker(lastAd + 1,Nana10ItemData.PRELOAD_AD);	
					}
					else
					{
						addAutomaticMarker(duration-CommunicationLayer.AD_PREBUFFER_TIME,Nana10ItemData.PRELOAD_AD);
					}
				}
				addAutomaticMarker(duration-CommunicationLayer.SECS_BEFORE_AD_MESSAGE,Nana10ItemData.PRE_AD);
			}
		}
		
		private function addAutomaticAds(dataRepository:Nana10DataRepository, totalItems:int):void
		{	
			var adsGap:int = CommunicationLayer.MINS_BETWEEN_MIDROLLS * 60;
			var currentAdTime:int = adsGap;
			var netDuration:Number = CommunicationLayer.getInstance().videoNetDuration;
			var adsArray:Array = [];
			//CommunicationLayer.getInstance().hasPreroll = true
			if (netDuration > adsGap + 30) // add ads if video is longer than the gap + half a minute
			{				
				while (netDuration - currentAdTime > 60)  // don't put ads less then 60sec before the end of video
				{
					adsArray.push({timeCode: currentAdTime-CommunicationLayer.AD_PREBUFFER_TIME, type: Nana10ItemData.PRELOAD_AD});
					adsArray.push({timeCode: currentAdTime-CommunicationLayer.SECS_BEFORE_AD_MESSAGE, type: Nana10ItemData.PRE_AD});
					adsArray.push({timeCode: currentAdTime, type: Nana10ItemData.MARKER});
					currentAdTime+= adsGap;
				}
				if (adsArray.length)
				{	// now locate the ads according to the segments' spreading
					var currAd:int;
					var totalGaps:Number = 0;				
					for (var i:int = 0; i< totalItems; i++)
					{
						if (dataRepository.getItemByIndex(i) is Nana10SegmentData)
						{
							var segmentData:Nana10SegmentData = dataRepository.getItemByIndex(i) as Nana10SegmentData;
							totalGaps+= segmentData.gapToPreviousSegment;
							while (true)
							{
								if (adsArray[currAd].timeCode < segmentData.endTimecode - totalGaps)
								{
									addAutomaticMarker(adsArray[currAd].timeCode + totalGaps,adsArray[currAd].type);
									currAd++;
									if (currAd == adsArray.length) return;
								}
								else
								{
									break;
								}
							}
						}
					}
				}
			}
		}
		
		// adds a marker at a given time-code with a given item data
		private function addAutomaticMarker(timeCode:Number,itemType:int):void
		{
			var markerData:Nana10MarkerData = new Nana10MarkerData(0,itemType);
			markerData.timeCode = timeCode;
			Nana10DataRepository.getInstance().addItem(markerData);
		}
		
		public function preloadAd(timeCode:Number):void
		{
			Debugging.printToConsole("--AdsContainer.preloadAd");
			_playWhenDataReady = midrollReady = false;
			getAdData(timeCode,true);
		}
		
		public function playAdd(timeCode:Number):void
		{
			Debugging.printToConsole("--AdsContainer.playAd");
			_playWhenDataReady = true;
			if (midrollReady)
			{
				beginPlayAd();
				videoReady(true);
			}
			else
			{
				getAdData(timeCode,false);
			}
		}
		
		private function getAdData(timeCode:Number,preloading:Boolean):void
		{
			loadingTime = getTimer();
			if (externalParams.HiroWrapper)
			{
				var adData:Object = hiroDataLoader.getAdByTime(timeCode,timeCode >= CommunicationLayer.getInstance().videoNetDuration - 0.5);
				setAdType(timeCode);
				if (adData)
				{					
					if (!preloading && Nana10PlayerData.getInstance().isLive == false && timeCode >= CommunicationLayer.getInstance().videoNetDuration - 0.5)
					{
						_hasPostroll = false;
						adType = CommunicationLayer.POSTROLL;
					}
					if (adData.url.indexOf("dummy_ad")==0)
					{
						hiroDataLoader.reportViewedAd(adData.url);
						errorLoadingAd("hiro returned dummy_ad");
						//videoEnded(false);
					}
					else if (adData.isPrepared == false)
					{
						hiroDataLoader.prepareAd(adData.url);
					}
					else
					{
						setAd(adData.url);
						adURL = adData.url;
						adClickURL = adData.clickUrl;
					}
				}
				else
				{
					if (preloading && timeCode - CommunicationLayer.getInstance().scenesGaps >= CommunicationLayer.getInstance().videoNetDuration - 0.5)
					{
						_showPreAd = false
						adType = CommunicationLayer.POSTROLL;
					}
					errorLoadingAd("Hiro data error - no adData" + (preloading ? " (preloading)" : ""));
				}
			}
			else
			{
				getCM8Data(timeCode);
			}
		}
		
		private function getCM8Data(timeCode:Number):void
		{
			Debugging.printToConsole("--AdsContainer.getData");
			var position:String;
			// ad's type is set by its timecode
			if (timeCode <= 0.1)
			{
				position = "VideoPreroll";
				adType = CommunicationLayer.PREROLL;
			}
			else if (timeCode - CommunicationLayer.getInstance().scenesGaps >= CommunicationLayer.getInstance().videoNetDuration - 0.5)
			{	//PostRolls aren't used anymore
				position = "VideoPostroll";
				_loadingPostroll = true;
				//stopVideo = true;
				adType = CommunicationLayer.POSTROLL;
			}
			else
			{
				position = "VideoMidroll";
				adType = CommunicationLayer.MIDROLL;
			}
			
			if (adsDataRequest == null)
			{
				adsDataRequest = new DataRequest();
				adsDataRequest.addEventListener(RequestEvents.DATA_READY, onDataReady);
				adsDataRequest.addEventListener(RequestEvents.DATA_ERROR, onDataError);
			}
			is3rdParty = false;
			adsDataRequest.load(_adsURL + "&format=" + position);
			
			//adsDataRequest.load("http://nana10.checkm8.com/adam/inline.xml?template=inline_nana10_wmv_video&format=VideoPreroll&VideoID=47380&cat=pid48.channels.sid244.general&CA=7&CG=3&ArticleID=576982&SectionID=2174&CategoryID=210135");
			//adsDataRequest.load("http://nana10.checkm8.com/adam/inline.xml?template=inline_nana10_flash_video&format=VideoPreroll&VideoID=47380&cat=pid48.channels.sid244.general&CA=7&CG=3&ArticleID=576982&SectionID=2174&CategoryID=210135");
			//adsDataRequest.load(_adsURL + "&naft=" + position);
			//adsDataRequest.load("http://nana10.checkm8.com/adam/inline?template=inline_nana10_flash_video&cat=pid48.channels.sid123.general&CA=7&CG=3&SectionID=11246&format=VideoPreroll");
		}
		
		private function setAdType(timeCode:Number):void
		{
			if (timeCode <= 0.1)
			{
				adType = CommunicationLayer.PREROLL;
			}
			else if (timeCode - CommunicationLayer.getInstance().scenesGaps >= CommunicationLayer.getInstance().videoNetDuration - 0.5)
			{	
				adType = CommunicationLayer.POSTROLL;
				_loadingPostroll = true;
			}
			else
			{
				adType = CommunicationLayer.MIDROLL;
			}
		}
		
		private function onDataReady(event:RequestEvents):void
		{
			Debugging.printToConsole("--AdsContainer.onDataReady");
			var url:String;
			if (event.xmlData != null)
			{
				if (CommunicationLayer.getInstance().hasPreroll || event.xmlData.ENTRY[1]==null)
				{
					url = event.xmlData.ENTRY.REF.@HREF;
				}
				else
				{
					url = event.xmlData.Entry[1].ref.@href;
				}			
				for each (var param:XML in event.xmlData.ENTRY.PARAM)
				{	// checking if there's a 3rd party ad
					if (String(param.@NAME == "3rdParty") && String(param.@VALUE).toLocaleLowerCase()=="true")
					{
						adsDataRequest.load(url);
						is3rdParty = true;
						return;	
					}
				}
			}
			if (url != null && url.length && (url.indexOf(".flv") > -1 || url.indexOf(".mpg") > -1 || url.indexOf(".asp") > -1))
			{
				setAd(url + (is3rdParty ? "" : "&ticket=" + externalParams.CUTicket));
				adClickURL = adUpdateURL = erateCode = null;
				for each (var param1:XML in event.xmlData.ENTRY.PARAM)
				{	// retrieving the ad's click urls
					switch (String(param1.@NAME))
					{
						case "LogoURL":
							if (String(param1.@VALUE).indexOf("http://")!=-1) adClickURL = param1.@VALUE;
							break;
						case "EventView":
							adUpdateURL = param1.@VALUE;
							break;
						case "ErateCode":
							erateCode = param1.@VALUE;
							break;
					}				
				}
			}
			else
			{
				errorLoadingAd(event.xmlData,event.url);
			}
		}
		
		private function onAdPrepared(event:Nana10DataEvent):void
		{
			setAd(event.adURL);
			adURL = event.adURL;
			adClickURL = event.adClickURL;
		}
		
		private function onDataError(event:RequestEvents):void
		{
			loadingTime = 0;
			Debugging.printToConsole("--AdsContainer.onDataError",event.errorMessage, event.url)
			StatsManagers.updatePlayerStats(StatsManagers.AdError,"Error loading ad data. "+event.errorMessage +" "+event.url+ " (AdsContainer.onDataError)");
			videoEnded();
		}
		
		private function errorLoadingAd(error:String, videoURL:String = ""):void
		{
			midrollReady = false;
			Debugging.printToConsole("--AdsContainer.errorLoadingAd", error);
			
			if (_loadingPostroll)
			{
				_loadingPostroll = false;
				_hasPostroll = false;
				_showPreAd = false;
			}
			StatsManagers.updatePlayerStats(StatsManagers.AdError,"Error loading ad data. "+videoURL +", response: " + error + " (AdsContainer.errorLoadingAd)");
			if (adType != CommunicationLayer.POSTROLL && Nana10DataRepository.getInstance().previewGroupID == 0)
			{
				
				var event:Nana10PlayerEvent = new Nana10PlayerEvent(Nana10PlayerEvent.AD_ERROR);
				event.hiddenReport = true;
				//dispatchEvent(event);
			}
			if (_playWhenDataReady) videoEnded();
			loadingTime = 0;
		}
		
		private function setAd(url:String):void
		{
			dispose();
			source = url // setting the ads' video player's source	
			//source = "http://switch206-01.castup.net/cunet/gm.asp?ClipMediaID=6147394&ak=null&cuud=advertising&ticket=515F574A25F03DEE6C3A3DBB8329491797197B05112AC91F6A397EE69B5BF393271876C3BDBXO5D040107000A05161C1861610D0E0F61616363666B66706B70D10F487E6C778301F07A052&ticket=undefined" // TEMP
			if (CommunicationLayer.getInstance().hasPreroll || _playWhenDataReady)
			{
				if (CommunicationLayer.getInstance().hasPreroll)
				{
					prerollLoadTimer = new Timer(250);
					prerollLoadTimer.addEventListener(TimerEvent.TIMER,onPrerollVideoLoading);
					prerollLoadTimer.start();
				}
				beginPlayAd();
			}
			else
			{
				//source = "http://switch206-01.castup.net/cunet/gm.asp?ClipMediaID=5849107&ak=null&cuud=advertising&ticket=undefined"; // TEMP
				pause();
			}
		}
		
		private function beginPlayAd():void
		{
			play();
			timer.start();
		}
		
		private function onAdViewUpdateError(event:RequestEvents):void {}
		
		
		private function onReportSent(event:RequestEvents):void
		{
			//Debugging.firebug("report sent:",event.url);
		}
		
		override protected function onVideoStatus(info:Object):void
		{		
			super.onVideoStatus(info);	
			if (loadingTime)
			{
				//Debugging.firebug("ad's loading time:",StringUtils.turnNumberToTime((getTimer() - loadingTime)/1000,false,false,true,false));
				StatsManagers.updatePlayerStats(StatsManagers.AdLoadingTime,String(getTimer() - loadingTime));
			}
			loadingTime = 0;
			videoReady();
		}
		
		override protected function onNetStatus(event:NetStatusEvent):void
		{
			super.onNetStatus(event);
			
			switch (event.info.code)
			{				
				case "NetStream.Play.StreamNotFound":				
					videoError(true);
					break; 
				case "NetStream.Play.FileStructureInvalid":
					videoError(false);
					break;
				/*case "NetStream.Play.Stop":
					if (!timer.running) videoEnded(false);
					break;*/
			}
		}
			
		private function onTimer(event:TimerEvent):void
		{
			if (playheadTime >= _duration - 0.25)
			{ 
				videoEnded(false);				
				timer.stop();
			}
		}
		
		private function videoReady(playNow:Boolean = false):void
		{
			Debugging.printToConsole("--AdsContainer.videoReady");
			midrollReady = true;
			_loadingPostroll = false;
			if (_playWhenDataReady || playNow)
			{
				visible = true;
				CommunicationLayer.getInstance().state = adType;
				switch (adType)
				{
					case CommunicationLayer.MIDROLL:
						StatsManagers.updatePlayerStats(StatsManagers.MidRollPlay);
						break;
					case CommunicationLayer.POSTROLL:
						StatsManagers.updatePlayerStats(StatsManagers.PostRollPlay);
						_hasPostroll = false;
						break;
					case CommunicationLayer.PREROLL:
						if (!reportedPreroll) StatsManagers.updatePlayerStats(StatsManagers.PreRollPlay);
						reportedPreroll = false;
						break;
				}
				if (adUpdateURL != null)
				{
					if (adClickRequest == null)
					{
						adClickRequest = new DataRequest();
						adClickRequest.addEventListener(RequestEvents.DATA_ERROR, onAdViewUpdateError);							
					}
					adClickRequest.load(adUpdateURL);
					StatsManagers.updatePlayerStats(StatsManagers.PlayerReportCheckM8View);
				}
				if (erateCode != null)
				{
					if (erateReportRequest == null)
					{
						erateReportRequest = new DataRequest();
						erateReportRequest.addEventListener(RequestEvents.DATA_ERROR, onAdViewUpdateError);	
						erateReportRequest.addEventListener(RequestEvents.DATA_READY, onReportSent);						
					}
					erateReportRequest.load("http://213.8.137.51/Erate/ReportCookie.asp?ToolId="+erateCode+"&EventType=1");
					StatsManagers.updatePlayerStats(StatsManagers.PlayerReportErateView);
				}
				if (externalParams.HiroWrapper)
				{
					hiroDataLoader.reportViewedAd(adURL);
				}
				dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.AD_BEGINS));
				
			}
		}
		
		private function videoEnded(error:Boolean = true):void
		{
			Debugging.printToConsole("ad ended");
			switch (adType)
			{
				case CommunicationLayer.MIDROLL:
					StatsManagers.updatePlayerStats(StatsManagers.MidRollEnd);
					break;
				case CommunicationLayer.POSTROLL:
					StatsManagers.updatePlayerStats(StatsManagers.PostRollEnd);
					_hasPostroll = false;
					break;
				case CommunicationLayer.PREROLL:
					StatsManagers.updatePlayerStats(StatsManagers.PreRollEnd);
					break;
			}
			visible = false;
			_loadingPostroll = false;
			dispose();
			var event:Nana10PlayerEvent = new Nana10PlayerEvent(Nana10PlayerEvent.AD_ENDS);
			event.adError = error && _playWhenDataReady;
			dispatchEvent(event);
			_hasPreroll = midrollReady = false;
			CommunicationLayer.getInstance().state = CommunicationLayer.PLAYER;
		}
		
		private function videoError(type:Boolean):void
		{
			var typeDesc:String;
			if (type)
			{
				typeDesc = "notFound";
			}
			else
			{
				typeDesc = "invalidFileStructure";
			}
			if (prerollLoadTimer && prerollLoadTimer.running)
			{
				stopPrerollLoadTimer();
			}
			StatsManagers.updatePlayerStats(StatsManagers.AdError,"Error loading ad video. "+typeDesc +" "+source+ " (AdsContainer.videoError)");
			if (_playWhenDataReady)
			{	
				videoEnded();
			}	
		}
		
		// once the preroll finished loading - start loading the main video
		private function onPrerollVideoLoading(event:TimerEvent):void
		{
			if (howMuchLoaded >=1)
			{
				StatsManagers.updatePlayerStats(StatsManagers.LoadComplete);
				dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.LOAD_VIDEO));
				
				stopPrerollLoadTimer();
			}
		}
		
		private function stopPrerollLoadTimer():void
		{
			prerollLoadTimer.stop();
			prerollLoadTimer.removeEventListener(TimerEvent.TIMER, onPrerollVideoLoading);
			//prerollLoadTimer = null;
		}
		
		// ads' video player clicked
		private function onClick(event:MouseEvent):void
		{
			Debugging.printToConsole("--UserAction: clicked ad (AdsContainer)");
			clickAd();	
		}
		
		public function clickAd():void
		{
			if (StringUtils.isStringEmpty(adClickURL) == false)
			{	
				if (externalParams.HiroWrapper)
				{
					hiroDataLoader.reportClickedAd(adURL);
				}
				else
				{
					navigateToURL(new URLRequest(adClickURL),"_blank");
				}
				if (erateCode)
				{
					erateReportRequest.load("http://213.8.137.51/Erate/ReportCookie.asp?ToolId="+erateCode+"&EventType=2");
					StatsManagers.updatePlayerStats(StatsManagers.PlayerReportErateClick);					
				}
				StatsManagers.updatePlayerStats(StatsManagers.PlayerReportCheckM8Click);							
			}
		}
		
		public function get hasPreroll():Boolean
		{
			return _hasPreroll;
		}
		
		public function get hasPostroll():Boolean
		{
			return _hasPostroll;
		}
		
		public function get playWhenDataReady():Boolean
		{
			return _playWhenDataReady;
		}
		
		public function reset():void
		{
			//_hasPreroll = hadPreroll;
			_hasPostroll = hadPostroll;
			_showPreAd = true;
			if (hiroDataLoader) hiroDataLoader.reset();
			hasAds = false;
		}
		
		public function get loadingPostroll():Boolean
		{
			return _loadingPostroll;
		}
		
		public function get pauseOverlayURL():String
		{
			if (hiroDataLoader)	return hiroDataLoader.pauseOverlayURL;
			return null;
		}
		
		public function get pauseOverlayClickURL():String
		{
			if (hiroDataLoader)	return hiroDataLoader.pauseOverlayClickURL;
			return null;
		}
		
		public function get overlayURL():String
		{
			if (hiroDataLoader)	return hiroDataLoader.overlayURL;
			return null;
		}
		
		public function get overlayClickURL():String
		{
			if (hiroDataLoader)	return hiroDataLoader.overlayClickURL;
			return null;
		}
		
		public function overlayOpened(url:String):void
		{
			hiroDataLoader.reportViewedAd(url);
		}
		
		public function overlayClicked(url:String):void
		{
			hiroDataLoader.reportClickedAd(url);
		}

		public function get showPreAd():Boolean
		{
			return _showPreAd;
		}
		
		override public function set volume(value:Number):void
		{
			super.volume = value * 0.2;	
		}
		
		override public function get volume():Number
		{
			return super.volume / 0.2;
		}

	}
}