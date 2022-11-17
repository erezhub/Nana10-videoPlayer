package com.data
{
	//import com.data.datas.KeyframeData;
	import com.adobe.serialization.json.JSON;
	import com.data.datas.notes.CommentData;
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.data.items.Nana10SegmentData;
	import com.data.items.player.Nana10CommentData;
	import com.data.stats.StatsManagers;
	import com.events.Nana10DataEvent;
	import com.events.Nana10PlayerEvent;
	import com.events.RequestEvents;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	import com.io.DataRequest;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.flash_proxy;
	import flash.utils.getTimer;
	
	[Event (name="loadStillImage", type="com.events.Nana10DataEvent")]
	[Event (name="sharedDataReady", type="com.events.Nana10DataEvent")]
	[Event (name="dataReady", type="com.events.Nana10DataEvent")]
	[Event (name="loadVideo", type="com.events.Nana10DataEvent")]
	[Event (name="switchVideo", type="com.events.Nana10DataEvent")]
	[Event (name="switchMAVideo", type="com.events.Nana10DataEvent")]
	[Event (name="videoNotFound", type="com.events.Nana10DataEvent")]
	[Event (name="dataError", type="com.events.RequestEvents")]
	public class Nana10PlayerData extends EventDispatcher
	{
		private static var instance:Nana10PlayerData;
		
		private var externalParams:ExternalParameters;
		private var dataRepository:Nana10DataRepository;
		private var _showAds:Boolean;
		private var _autoPlay:Boolean;
		private var _smoothing:Boolean;
		private var _embededPlayer:Boolean;
		private var _useCastUpXML:Boolean;
		private var _isLive:Boolean;
		private var _checkForLinkChange:Boolean;
		private var _resetVideo:Boolean;
		private var _startWithHQ:Boolean;
		//private var _sceneStartTime:Number;
		//private var _sceneDuration:Number;
		private var _showHQ:Boolean;
		private var _hqAvailable:Boolean;
		private var _videoLinkHQ:String;
		private var _commentsLoaded:Boolean;
		private var urlDuration:Number;
		
		private var mainDataRequest:DataRequest;
		private var sharedDataRequest:DataRequest;
		private var videoFileRequest:DataRequest;
		private var _sceneID:int;	
		private var alternateVideosURL:Array;
		private var currentAlternateVideoIndex:int;
		private var dataLoadTime:int;
		private var timeoutsCounter:int;
		private var sharedDataReady:Boolean;
		
		public function Nana10PlayerData(singletonEnforcer:SingletonEnforcer)
		{			
			externalParams = ExternalParameters.getInstance();
			dataRepository = Nana10DataRepository.getInstance();
			timeoutsCounter = 0;
		}
		
		public static function getInstance():Nana10PlayerData
		{
			if (instance == null)
			{
				instance = new Nana10PlayerData(new SingletonEnforcer());
			}
			return instance;
		}
		
		public function init(stage:Stage):void
		{
			Debugging.printToConsole("--Nana10PlayerData.init");
			externalParams.init(stage.loaderInfo.parameters);
			
			_autoPlay = (externalParams.AutoPlay != undefined && externalParams.AutoPlay == 1) || dataRepository.previewGroupID;
			_smoothing = externalParams.LQSmoothing != undefined && externalParams.LQSmoothing == 1
			_showAds = externalParams.ShowAds == 1 || dataRepository.previewGroupID;
			try
			{
				if (ExternalInterface.call("parent.RequestQueryString","WNB") == 1) _showAds = false;
			}
			catch (e:Error) {};
			_isLive = externalParams.IsLive == 1;
			_checkForLinkChange = externalParams.CheckForLinkChange == 1;
		}
		
		// preparing the movie data for loading		
		public function prepareData(updateStats:Boolean = true):void
		{
			Debugging.printToConsole("--Nana10PlayerData.prepareData");
			var dataURL:String;			
			if (externalParams.MediaStockVideoItemGroupID != null && externalParams.MediaStockVideoItemGroupID.length && externalParams.MediaStockVideoItemGroupID != "0")
			{	// tagger-generated video
				dataURL = CommunicationLayer.getInstance().actionsServer + "GetData?GroupID=" + externalParams.MediaStockVideoItemGroupID;
				_useCastUpXML = false;
			}
			else if ((externalParams.VideoLink != null && externalParams.VideoLink.length) || externalParams.CUTest)
			{   // CastUp generated video
				if (externalParams.CUTest)
				{
					dataURL = ExternalInterface.call("RequestQueryString","VideoLink");	
					dataURL = unescape(dataURL);
					Debugging.printToConsole(dataURL);
				}
				else
				{
					dataURL = externalParams.VideoLink.toString();
				}
				_useCastUpXML = true;
				dataRepository.videoTitle = externalParams.Title;
				if (_embededPlayer) dataURL = dataURL.concat("&external=1");
				var i1:int = dataURL.indexOf("&dr=");
				if (i1 > -1)
				{
					var i2:int = dataURL.indexOf("&",i1+1);
					var duration:Array = dataURL.substring(i1 + 4,i2).split(":");
					urlDuration = parseInt(duration[0])*60*60 + parseInt(duration[1])*60 + parseFloat(duration[2]);
				}
				else
				{
					urlDuration = 0;
				}
			}
			else
			{   // embeded player or new end of video
				getShareData();
				if (! _resetVideo) _embededPlayer = true;
				return;
			}
			if (mainDataRequest == null)
			{
				mainDataRequest = new DataRequest(10000); // main request timeout is set to 10sec			
				mainDataRequest.addEventListener(RequestEvents.DATA_READY, onDataReady);
				mainDataRequest.addEventListener(RequestEvents.DATA_ERROR, onDataError);
			}
			mainDataRequest.url = dataURL;
			if (updateStats)
			{
				if (_embededPlayer) StatsManagers.updatePlayerStats(StatsManagers.PlayerStart,"FlashPlayer");
				StatsManagers.updatePlayerStats(StatsManagers.KeepAlive,"0");
			}
		}
		
		// using the dataURL prepared in the 'prepareData' to actually load it
		public function makeDataRequest(requestTimeout:int = 0):void
		{
			Debugging.printToConsole("--Nana10PlayerData.makeDataRequest");
			Debugging.printToConsole("dataURL = "+ mainDataRequest.url);
			try
			{
				if (requestTimeout) mainDataRequest.timeout = requestTimeout;
				mainDataRequest.load();
				dataLoadTime = getTimer();
			}
			catch (e:Error)
			{
				var event:RequestEvents = new RequestEvents(RequestEvents.DATA_ERROR);
				event.errorMessage = e.message;
				event.url = mainDataRequest.url;
				onDataError(event);
			}
		}
		
		private function onDataReady(event:RequestEvents):void
		{
			Debugging.printToConsole("--Nana10PlayerData.onDataReady. loading speed:",event.loadingSpeed,"Kb/sec");
			StatsManagers.updatePlayerStats(StatsManagers.DataLoadTime,String(getTimer() - dataLoadTime));
			timeoutsCounter = 0;
			// parse the raw data
			if (_useCastUpXML)
			{
				CastUpXMLParser.parseXML(event.xmlData,urlDuration);
				dataRepository.videoLinkHQ = externalParams.VideoLinkHQ;
			}
			else
			{
				if (event.jsonData.ActionSucceeded == false)
				{
					var requestEvent:RequestEvents = new RequestEvents(RequestEvents.DATA_ERROR);
					requestEvent.errorMessage = event.jsonData.ErrorMessage;
					requestEvent.url = event.url;
					dispatchEvent(requestEvent);
					return;
				}
				dataRepository.parseData(event.jsonData.Details);
				if (dataRepository.videoTitle == "not found")
				{
					Debugging.printToConsole("content not found");
					var dataEvent:Nana10DataEvent = new Nana10DataEvent(Nana10DataEvent.DATA_READY);
					dataEvent.videoFile = "90103a_en.wmv";
					dispatchEvent(dataEvent);
					return;
				} else if (dataRepository.totalItems == 0)
				{	// data doesn't include any items
					StatsManagers.updatePlayerStats(StatsManagers.GeneralError,"Error loading video data.  there are no items (Nana10PlayerData.onDataReady)");
					var errorEvent:RequestEvents = new RequestEvents(RequestEvents.DATA_ERROR);
					errorEvent.errorMessage = "no items";
					dispatchEvent(errorEvent);				
					return;
				}
				
				Nana10DataParser.parseData();
				 
			}
			if (dataRepository.videoLink == null)
			{	// data doesn't include path for the video
				StatsManagers.updatePlayerStats(StatsManagers.GeneralError,"Error loading video data. Can't find video file path while loading '"+mainDataRequest.url+"' (Nana10Player.onDataReady)");
				dispatchEvent(new Nana10DataEvent(Nana10DataEvent.VIDEO_NOT_FOUND));				
				return;
			}
			
			_hqAvailable = !StringUtils.isStringEmpty(dataRepository.videoLinkHQ);						
			//videoPlayer.smoothing = smoothing;
			var clipDuration:Number = dataRepository.videoDuration;
			_startWithHQ = externalParams.PlayHQ && !externalParams.HQSlideShow;
			var nana10DataEvent:Nana10DataEvent;
			// when working with nana10 the retreived video file path can be in 2 options:  either the file itself in flv or mpg4 format
			// (mostly when working with cast-up xml), or not a video file, but an asp file which contains the path to the videos (mostly 
			// when working with MediAnd's data) 
			if (dataRepository.videoLink.indexOf(".asp") > -1)
			{
				getVideoFile(dataRepository.videoLink + "&curettype=1");
			}
			else
			{
				var start:String = "";
				if (CommunicationLayer.getInstance().videoStartPoint) // video doesn't start from its begining
				{
					start = "&start=" + CommunicationLayer.getInstance().videoStartPoint;
				}
				
				nana10DataEvent = new Nana10DataEvent(Nana10DataEvent.DATA_READY);
				nana10DataEvent.videoStartTime = start;
				dispatchEvent(nana10DataEvent);
			}
		}
				
		// loading the file containing the path to the video files
		public function getVideoFile(videoFile:String):void
		{
			Debugging.printToConsole("--Nana10PlayerData.getVideoFile",videoFile);
			if (videoFileRequest == null)
			{
				videoFileRequest = new DataRequest(15000);
				videoFileRequest.addEventListener(RequestEvents.DATA_READY, onVideoFileReady);
				videoFileRequest.addEventListener(RequestEvents.DATA_ERROR, onVideoFileError);
			}
			dataLoadTime = getTimer();
			_useCastUpXML = true;
			videoFileRequest.load(videoFile);
		}
		
		private function onVideoFileReady(event:RequestEvents):void
		{
			Debugging.printToConsole("--Nana10PlayerData.onVideoFileReady");
			// getting the video files from the loaded data	
			alternateVideosURL = event.textData.split(";");			
			alternateVideosURL[0].replace(".flv",".flvs");
			Debugging.printToConsole("total clips refs: " + alternateVideosURL.length);
			var nana10DataEvent:Nana10DataEvent = new Nana10DataEvent(Nana10DataEvent.DATA_READY);
			if (alternateVideosURL.length == 680)
			{	// for unknown reason, sometimes abrod-users which content is blocked - recieve a 680 long array of alternate video urls'
				nana10DataEvent.videoFile = "90104a_en.wmv";
			}
			else
			{
				nana10DataEvent.videoFile = alternateVideosURL[0];
			}
			//nana10DataEvent.videoStartTime = start;
			videoFileRequest.removeEventListener(RequestEvents.DATA_ERROR,onVideoFileReady);
			videoFileRequest.removeEventListener(RequestEvents.DATA_ERROR,onVideoFileError);
			videoFileRequest = null;
			timeoutsCounter = 0;
			if (_useCastUpXML) StatsManagers.updatePlayerStats(StatsManagers.DataLoadTime,String(getTimer() - dataLoadTime));
			_useCastUpXML = false;
			dispatchEvent(nana10DataEvent);
		}
		
		private function onVideoFileError(event:RequestEvents):void
		{
			Debugging.printToConsole("--Nana10PlayerData.onVideoFileError",event.errorMessage);
			//dispatchEvent(event.clone());
			onDataError(event.clone() as RequestEvents);
		}
		
		// error loading video
		public function get alternateVideoURL():String
		{
			Debugging.printToConsole("--Nana10PlayerData.alternateVideoURL");
			if (useCastUpXML)
			{
				if (_showHQ)
				{
					return castUpAlternateHQVideoURL;
				}
				else
				{
					return castUpAlternateVideoURL;
				}
			}
			else
			{
				return nanaAlternateVideoURL;
			}
		}
		
		// get the next video file on the CastUp's data list
		private function get castUpAlternateVideoURL():String
		{
			Debugging.printToConsole("--Nana10PlayerData.getCastupAlternateVideoURL");
			if (CastUpXMLParser.hasAlternateVideoURL)
			{
				return  CastUpXMLParser.alternateVideoURL;	
			}
			else
			{  // tried all the video files - unsuccessfully
				return null;//"Error";
			}
		}
		
		// get the next HQ video file on the CastUp's data
		private function get castUpAlternateHQVideoURL():String
		{
			Debugging.printToConsole("--Nana10PlayerData.getCastupAlternateHQVideoURL");
			if (CastUpXMLParser.alternateHQVideoURLS && CastUpXMLParser.currentHQVideoURL < CastUpXMLParser.alternateHQVideoURLS.length - 1)
			{
				CastUpXMLParser.hqVideo = CastUpXMLParser.alternateHQVideoURLS[++CastUpXMLParser.currentHQVideoURL];
				return CastUpXMLParser.hqVideo; 
			}
			else
			{ 	// tried all the video files - unsuccessfully
				return null;//"Error HQ";
			}
		}
		
		// get the next video file on the Mediand's data
		private function get nanaAlternateVideoURL():String
		{
			Debugging.printToConsole("Nana10PlayerData.getNanaAlternateVideoURL");
			if (alternateVideosURL && currentAlternateVideoIndex < alternateVideosURL.length - 1)
			{
				var url:String = alternateVideosURL[++currentAlternateVideoIndex];
				url = url.replace(".flv",".flvs");
				return url;
			}
			else
			{	// tried all the video files - unsuccessfully
				return null;//"Error";
			}
		}
		
		public function set alternativeVideosURLArray(value:String):void
		{
			alternateVideosURL = value.split(";");
		}
				
		public function getShareData():void
		{
			Debugging.printToConsole("--Nana10PlayerData.getSharedData");
			sharedDataReady = false;
			if (sharedDataRequest == null)
			{
				sharedDataRequest = new DataRequest();
				sharedDataRequest.addEventListener(RequestEvents.DATA_READY, onSharedVideoDataReady);
				sharedDataRequest.addEventListener(RequestEvents.DATA_ERROR, onDataError);
			}
			if (externalParams.ArticleID == 833505 && externalParams.VideoID is String && externalParams.VideoID.indexOf(",") > -1)
			{	// in melingo's (morfix) embedded player, several paramters are passed as the VideoID.
				// selecting the current one according to the current minute in the hour (and the total number of videos)
				var melingoVideos:Array = externalParams.VideoID.split(",");
				var date:Date = new Date();
				var index:int = date.minutes/(60/melingoVideos.length);
				externalParams.VideoID = melingoVideos[index];
			}
			var requestParams:String  = "?VideoID=" + externalParams.VideoID;
			if (externalParams.ArticleID != undefined) requestParams = requestParams.concat("&ArticleID=" + externalParams.ArticleID);
			if (externalParams.SectionID != undefined) requestParams = requestParams.concat("&SectionID=" + externalParams.SectionID);
			if (externalParams.CategoryID != undefined) requestParams = requestParams.concat("&CategoryID=" + externalParams.CategoryID);
			if (externalParams.PartnerID != undefined) requestParams = requestParams.concat("&PartnerID=" + externalParams.PartnerID);
			
			sharedDataRequest.load(CommunicationLayer.getInstance().actionsServer + "GetDataShared" + requestParams);
		}
		
		// data for embeded player is loaded
		private function onSharedVideoDataReady(event:RequestEvents):void
		{
			Debugging.printToConsole("--Nana10PlayerData.onSharedVideoDataReady");
			var xml:XML = event.xmlData;
			var requestEvent:RequestEvents;
			if (xml == null || xml.length() == 0 || xml.ActionSucceeded == "False")
			{
				requestEvent = new RequestEvents(RequestEvents.DATA_ERROR,xml);
				requestEvent.errorMessage = xml.ErrorDescription;
				onDataError(requestEvent);
				return;
			}
			// populate the externalParams class manualy
			externalParams.VideoLink = xml.VideoLink.toString();
			externalParams.MediaStockVideoItemGroupID = xml.MediaStockVideoItemGroupID.toString();
			if (externalParams.VideoLink == "" && externalParams.MediaStockVideoItemGroupID == "")
			{
				requestEvent = new RequestEvents(RequestEvents.DATA_ERROR,xml);
				requestEvent.errorMessage = "No Video data (link or groupID) from getSharedData";
				onDataError(requestEvent);
				return;
			}
			sharedDataReady = true;
			if (externalParams.SessionID == null)
			{
				externalParams.SessionID = StatsManagers.sessionId = xml.SessionID.toString();
				Debugging.printToConsole("--Nana10PlayerData.onSharedVideoDataReady, sessionID",externalParams.SessionID);
			}
			externalParams.ServiceID = xml.ServiceID.toString();
			externalParams.PartnerID = xml.PartnerID.toString();
			externalParams.CategoryID = xml.CategoryID.toString();
			externalParams.SectionID = xml.SectionID.toString();
			externalParams.ArticleID = xml.ArticleID.toString();
			externalParams.RelatedSections = xml.RelatedSections.toString();
			externalParams.SceneID = xml.SceneID.toString();
			externalParams.VideoLinkHQ = xml.VideoLinkHQ.toString();
			_showAds = xml.ShowAds == 1;
			externalParams.CUTicket = xml.CUTicket.toString();
			externalParams.CM8Target = xml.CM8Target.toString();
			externalParams.HiroTarget = xml.HiroTarget.toString();
			externalParams.TalkbackID = xml.TalkbackID.toString();
			externalParams.Title = xml.Title.toString();
			externalParams.ShareLink = xml.ShareLink.toString();
			externalParams.ShowDetailsForm = xml.ShowDetailsForm .toString();
			externalParams.PlayHQ = (xml.PlayHQ != undefined && xml.PlayHQ == 1);
			externalParams.HQSlideShow = (xml.HQSlideShow != undefined && xml.HQSlideShow == 1);
			externalParams.HQAppURL = xml.HQAppURL.toString();
			externalParams.HQAppLogoURL = xml.HQAppLogoURL.toString();
			externalParams.EnableEmbed = xml.EnableEmbed ? xml.EnableEmbed.toString() : 0;// == "1" || externalParams.EnableEmbed; // in case it was already set to true - don't overwrite it
			externalParams.AdURL = xml.AdURL.toString();
			externalParams.HiroWrapper = xml.HiroWrapper.toString();
			externalParams.ServiceName = xml.ServiceName.toString();
			_autoPlay = (xml.AutoPlay != undefined && xml.AutoPlay == 1) || _resetVideo || _autoPlay;  // in case it was already set to true - don't overwrite it
			_smoothing = xml.LQSmoothing != undefined && xml.LQSmoothing == 1;
			_isLive = xml.IsLive != undefined && xml.IsLive == 1;
			if (externalParams.CategoryID == 0) externalParams.CategoryID = xml.CategoryID.toString(); 
				
			var nana10PlayerEvent:Nana10DataEvent;
			// load still image if found
			if (xml.StillImageUrl != null && String(xml.StillImageUrl).indexOf("http") > -1)
			{
				externalParams.StillImageUrl = xml.StillImageUrl;
				nana10PlayerEvent = new Nana10DataEvent(Nana10DataEvent.LOAD_STILL_IMAGE);
				nana10PlayerEvent.stillImageURL = xml.StillImageUrl;
				dispatchEvent(nana10PlayerEvent);
			}
			
			nana10PlayerEvent = new Nana10DataEvent(Nana10DataEvent.SHARED_DATA_READY);
			nana10PlayerEvent.CM8Target = xml.CM8Target;
			dispatchEvent(nana10PlayerEvent);
		}
		
		private function onDataError(event:RequestEvents):void
		{
			Debugging.printToConsole("--Nana10PlayerData.onDataError",event.errorMessage);
			if (event.errorMessage.indexOf("Error #1085") == -1)
			{	// only after 3 failures - display an error message; otherwise - make another attempt
				if (timeoutsCounter < 2)
				{
					timeoutsCounter++;
					if (embededPlayer && !sharedDataReady)
					{
						prepareData(false);					
					}
					else if (isLive || videoFileRequest != null)
					{
						getVideoFile(externalParams.VideoLink + "&curettype=1");
					}
					else
					{
						makeDataRequest(timeoutsCounter*15000); // on each attempt - setting a longer timeout
					}
				}
				else
				{
					dispatchEvent(event.clone());
				}
				StatsManagers.updatePlayerStats(StatsManagers.GeneralError,"Error loading data. "+event.errorMessage+": "+event.url+", (Nana10PlayerData.onDataError)");
				if (event.errorMessage.indexOf("Timeout!") > -1)
				{
					StatsManagers.updatePlayerStats(StatsManagers.DataLoadingTimeout,String(timeoutsCounter));
				}
				else
				{
					StatsManagers.updatePlayerStats(StatsManagers.DataLoadError,event.errorMessage + " " + String(timeoutsCounter));
				}
				//}
			}
			else
			{
				dispatchEvent(event.clone());
			}
		}
		
		// loading comments data
		public function loadComments():void
		{
			Debugging.printToConsole("--Nana10PlayerData.loadComments");
			if (!_commentsLoaded)
			{
				var dataRequest:DataRequest = new DataRequest();
				dataRequest.addEventListener(RequestEvents.DATA_READY, onCommentDataReady);
				dataRequest.addEventListener(RequestEvents.DATA_ERROR, onCommentsDataError);
				dataRequest.load("http://common.nana10.co.il/Talkback/getVideoTB.ashx?TalkbackID=" + externalParams.TalkbackID);
				_commentsLoaded = true;
				if (CommunicationLayer.getInstance().videoNetDuration > 5*60)
				{	// adding default comment (to videos longer than 5mins)
					var defaultCommnet:Nana10CommentData = new Nana10CommentData(0,"'רוצים שהתגובה שלכם תופיע על גבי הסרטון? לחצו כעת על 'הוסף הערה","");
					defaultCommnet.timeCode = CommunicationLayer.getInstance().videoStartPoint;
					dataRepository.addItem(defaultCommnet);
				}
			}
		}
		
		private function onCommentDataReady(event:RequestEvents):void
		{	
			Debugging.printToConsole("--Nana10PlayerData.onCommentsDataReady");
			// for every comment add a keyframe and a comments item
			var comments:XMLList = event.xmlData.TalkbackReplyList.TalkbackReply;
			var communicationLayer:CommunicationLayer = CommunicationLayer.getInstance();
			for each (var comment:XML in comments)
			{				
				//var commentTimeCode:int = comment.@ReplyTime * 1000;
				var commentData:Nana10CommentData = new Nana10CommentData(comment.@MsgID, String(comment.@Content).substr(0,140), comment.@AuthorName);
				commentData.timeCode = comment.@ReplyTime;
				dataRepository.addItem(commentData);
				/*var keyframeData:KeyframeData = new KeyframeData(commentTimeCode,commentTimeCode);
				dataRepository.addKeyframe(keyframeData);
				keyframeData.addItem(nana10Commnet);
				nana10Commnet.addKeyframe(commentTimeCode);*/
			}			
			dispatchEvent(new Nana10DataEvent(Nana10DataEvent.COMMENTS_LOADED));		
		}
		
		private function onCommentsDataError(event:RequestEvents):void
		{
			Debugging.printToConsole("--Nana10PlayerData.onCommentsDataError");
			StatsManagers.updatePlayerStats(StatsManagers.CommentsLoadError,"Error loading comments. "+event.errorMessage+": "+externalParams.TalkbackID+" (Nana10PlayerData.onCommentsDataError)");
			dispatchEvent(new Nana10DataEvent(Nana10DataEvent.COMMENTS_LOADED));	
		}
		
		// when displaying partial clip - removing un-nessecary data from the data repository
		public function updateDataRepository(startTime:Number, offset:Number):void
		{
			Debugging.printToConsole("--Nana10PlayerData.updateDataRepository");
			// going through all the keyframes, removing those before movie start, and updating those after movie start
			var totalItems:int = dataRepository.totalItems;
			for (var i:int = 0; i < totalItems; i++)
			{
				var itemData:Nana10MarkerData = dataRepository.getItemByIndex(i);
				if (itemData.timeCode < startTime - offset)
				{	// keyframes before scene start
					dataRepository.removeItemById(itemData.id);
					i--;
					totalItems--;
				}
				else if (Math.abs(itemData.timeCode - startTime) > 0.01)
				{
					itemData.timeCode-=(startTime - offset);
					if (itemData is Nana10SegmentData)
					{
						(itemData as Nana10SegmentData).endTimecode-=(startTime - offset);
					}
				}
				else
				{	// first item - set its timecode to 0
					itemData.timeCode-=startTime;
					if (itemData is Nana10SegmentData)
					{
						(itemData as Nana10SegmentData).endTimecode-=startTime;
						(itemData as Nana10SegmentData).duration+= offset;
					}
				}
			}
			/*var totalItems:int = dataRepository.totalItems;
			for (var j:int = 0; j < totalItems; j++)
			{
				if (dataRepository.getItemByIndex(j) is Nana10Comment)
				{
					(dataRepository.getItemByIndex(j) as Nana10Comment).keyframesIds[0]-=(startTime - offset);
				}
			}*/
		}
		
		public function checkVideoLink():Boolean
		{
			var callMetaDataReady:Boolean;
			var videoLink:String = externalParams.VideoLink;
			var validMediaStockGroupID:Boolean = (externalParams.MediaStockVideoItemGroupID != null && externalParams.MediaStockVideoItemGroupID.length && externalParams.MediaStockVideoItemGroupID != "0")
			if (videoLink && ((isLive && (videoLink.indexOf("rtmp") > -1) || videoLink.indexOf("zixi") > -1) || videoLink.indexOf(".mp4") > -1) && !validMediaStockGroupID)
			{				
				dataRepository.videoLink = videoLink;
				//onMetaDataReady(null);
				callMetaDataReady = true;
			}
			else if (isLive == false || (videoLink && videoLink.indexOf("gm.asp") == -1) || (isLive && videoLink == null))
			{
				makeDataRequest();
				callMetaDataReady = false;
			}
			return callMetaDataReady;
		}
		
		public function get showAds():Boolean
		{
			return _showAds;
		}
		
		public function set showAds(value:Boolean):void
		{
			_showAds = value;
		}
		
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}
		
		public function set autoPlay(value:Boolean):void
		{
			_autoPlay = value;
		}
		
		public function get smoothing():Boolean
		{
			return _smoothing;
		}
		
		public function get embededPlayer():Boolean
		{
			return _embededPlayer;
		}
		
		public function get useCastUpXML():Boolean
		{
			return _useCastUpXML;
		}

		public function set resetVideo(val:Boolean):void
		{
			_resetVideo = val;
		}

		public function get resetVideo():Boolean
		{
			return _resetVideo;
		}
		
		public function get startWithHQ():Boolean
		{
			return _startWithHQ;
		}
		
		public function set startWithHQ(value:Boolean):void
		{
			_startWithHQ = value;
		}
		
		public function get showHQ():Boolean
		{
			return _showHQ;
		}
		
		public function set showHQ(value:Boolean):void
		{
			_showHQ = value;
		}
		
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function get checkForLinkChange():Boolean
		{
			return _checkForLinkChange;
		}
		
		public function reset():void
		{
			//_sceneDuration = _sceneStartTime = 0;
			_commentsLoaded = false;
			_resetVideo = true;
			timeoutsCounter = 0;
		}

		public function get hqAvailable():Boolean
		{
			return _hqAvailable;
		}

		public function set hqAvailable(value:Boolean):void
		{
			_hqAvailable = value;
		}
		
		public function get videoLink():String
		{
			if (alternateVideosURL == null) return null;
			return alternateVideosURL[currentAlternateVideoIndex]
		}
		
		public function resetAlternateVideoIndex():void
		{
			currentAlternateVideoIndex = 0;
		}

	}
}

internal class SingletonEnforcer{}