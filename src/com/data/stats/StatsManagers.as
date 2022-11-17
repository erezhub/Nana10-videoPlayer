package com.data.stats
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.StringUtil;
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.Version;
	import com.events.RequestEvents;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	import com.io.DataRequest;
	import com.io.ServerFunctions;
	import com.ui.pannels.OpeningForm;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
		
	public class StatsManagers
	{
		public static const PlayClick:int = 1;
		public static const PauseClick:int = 2;
		public static const HQOn:int = 3;
		public static const HQOff:int = 4;
		public static const SceneMenuOpen:int = 5;
		public static const ShareOpen:int = 6;
		public static const LightOn:int = 7;
		public static const LightOff:int = 8;
		public static const CommentsOpen:int = 9;
		public static const CommentsClose:int = 10;
		public static const FullScreenOn:int = 11;
		public static const FullScreenOff:int = 12;
		public static const JumpToTime:int = 13;
		public static const JumpToScene:int = 14;
		public static const PlayerExit:int = 15;
		public static const MoviePlay:int = 16;
		public static const MovieEnd:int = 17;
		public static const PreRollPlay:int = 18;
		public static const PreRollEnd:int = 19;
		public static const PreRollPause:int = 20;
		public static const MidRollPlay:int = 21;
		public static const MidRollPause:int = 22;
		public static const MidRollEnd:int = 23;
		public static const PostRollPlay:int = 24;
		public static const PostRollPause:int = 25;
		public static const PostRollEnd:int = 26;
		public static const MoreInNanaShow:int = 27;
		public static const BufferingStart:int = 28;
		public static const LoadComplete:int = 29;
		public static const BufferEmpty:int = 30;
		public static const MoviePause:int = 31;
		public static const GeneralError:int = 32;
		public static const PreRollBufferEmpty:int = 33;
		public static const MidRollBufferEmpty:int = 34;
		public static const PostRollBufferEmpty:int = 35;
		public static const PrerollLoadComplete:int = 37;
		public static const MidrollLoadComplete:int = 38;
		public static const PostrollLoadComplete:int = 39;
		public static const PlayerReportErateView:int = 40;
		public static const PlayerReportCheckM8View:int = 41;
		public static const PlayerReportErateClick:int = 42;
		public static const PlayerReportCheckM8Click:int = 43;
		public static const PlayerStart:int = 44;
		public static const PlayerStop:int = 45;
		public static const KeepAlive:int = 47;
		public static const AdError:int = 48;
		public static const ExpiredContent:int = 49;
		public static const AdLoadingTime:int = 50;
		public static const AutoPlay:int = 63;
		
		public static const DataLoadTime:int = 51;
		public static const DataLoadingTimeout:int = 52;
		public static const BugReport:int = 53;
		public static const VideoInitLoadTime:int = 54;
		public static const DataLoadError:int = 55;
		public static const MoreInNanaDataError:int = 56;
		public static const MoreInNanaThumbError:int = 57;
		public static const StillImageError:int = 58;
		public static const CommentsLoadError:int = 59;
		public static const NoPreroll:int = 60;
		public static const HiroLoadTime:int = 61;
		public static const LiveStreamFailure:int = 62;
		public static const FormDisplayed:int = 64;
		public static const FormIgnored:int = 65;
		public static const FormFilled:int = 66;
		public static const FormDataFound:int = 67;
		public static const ContentBlocked:int = 68;
		public static const ToolbarDownloaded:int = 69;
		public static const BannerClicked:int = 70;
		public static const VideoInitLoadTimeout:int = 71;
		public static const VideoStreamNotFound:int = 72;
		public static const VideoLoadSpeed:int = 73;
		public static const VideoRequest:int = 74;
		public static const DataFailure:int = 75;
		public static const VideoFailure:int = 76;
		public static const ContentInit:int = 77;
		public static const VideoInit:int = 78;
		
		private static var eventReport:Array = new Array();
		eventReport[PlayClick] = true;
		eventReport[PauseClick] = true;
		eventReport[HQOn] = false;
		eventReport[HQOff] = false;
		eventReport[SceneMenuOpen] = false;
		eventReport[ShareOpen] = false;
		eventReport[LightOn] = true;
		eventReport[LightOff] = true;
		eventReport[CommentsOpen] = true;
		eventReport[CommentsClose] = true;
		eventReport[FullScreenOn] = false;
		eventReport[FullScreenOff] = false;
		eventReport[JumpToTime] = true;
		eventReport[JumpToScene] = true;
		eventReport[PlayerExit] = true;
		eventReport[MoviePlay] = true;
		eventReport[MovieEnd] = true;
		eventReport[PreRollPlay] = true;
		eventReport[PreRollEnd] = false;
		eventReport[PreRollPause] = false;
		eventReport[MidRollPlay] = true;
		eventReport[MidRollPause] = false;
		eventReport[MidRollEnd] = false;
		eventReport[PostRollPlay] = true;
		eventReport[PostRollPause] = false;
		eventReport[PostRollEnd] = false;
		eventReport[MoreInNanaShow] = false;
		eventReport[BufferingStart] = false;
		eventReport[LoadComplete] = false;
		eventReport[BufferEmpty] = true;
		eventReport[MoviePause] = true;
		eventReport[GeneralError] = false;
		eventReport[PreRollBufferEmpty] = false;
		eventReport[MidRollBufferEmpty] = false;
		eventReport[PostRollBufferEmpty] = false;
		eventReport[PrerollLoadComplete] = false;
		eventReport[MidrollLoadComplete] = false;
		eventReport[PostrollLoadComplete] = false;
		eventReport[PlayerReportErateView] = false;
		eventReport[PlayerReportCheckM8View] = false;
		eventReport[PlayerReportErateClick] = false;
		eventReport[PlayerReportCheckM8Click] = false;
		eventReport[PlayerStart] = true;
		eventReport[PlayerStop] = false;
		eventReport[AutoPlay] = true;
		eventReport[KeepAlive] = true;
		eventReport[AdError] = true;
		eventReport[ExpiredContent] = true;
		eventReport[AdLoadingTime] = false;
		
		eventReport[DataLoadTime] = true;
		eventReport[DataLoadingTimeout] = true;
		eventReport[BugReport] = true;
		eventReport[VideoInitLoadTime] = true;
		eventReport[DataLoadError] = true;	
		eventReport[MoreInNanaDataError] = true;
		eventReport[MoreInNanaThumbError] = true;
		eventReport[StillImageError] = true;
		eventReport[CommentsLoadError] = true;
		eventReport[NoPreroll] = true;
		eventReport[HiroLoadTime] = true;
		eventReport[LiveStreamFailure] = true;
		eventReport[FormDisplayed] = true;
		eventReport[FormFilled] = true;
		eventReport[FormIgnored] = true;
		eventReport[FormDataFound] = true;
		eventReport[ContentBlocked] = true;
		eventReport[ToolbarDownloaded] = true;
		eventReport[BannerClicked] = false;
		eventReport[VideoInitLoadTimeout] = true;
		eventReport[VideoStreamNotFound] = true;
		eventReport[VideoRequest] = true;
		eventReport[DataFailure] = true;
		eventReport[VideoFailure] = true;
		eventReport[ContentInit] = true;
		eventReport[VideoInit] = true;
		
		private static var auditEvent:Array = new Array();
		auditEvent[FullScreenOn] = true;
		auditEvent[FullScreenOff] = true;
		auditEvent[BugReport] = true;
		auditEvent[MoreInNanaDataError] = true;
		auditEvent[MoreInNanaThumbError] = true;
		auditEvent[StillImageError] = true;
		auditEvent[CommentsLoadError] = true;
		auditEvent[NoPreroll] = true;
		auditEvent[HiroLoadTime] = true;
		auditEvent[ContentBlocked] = true;
		auditEvent[ToolbarDownloaded] = false;
		auditEvent[BannerClicked] = true;
		
		private static var monitorEvent:Array = new Array();
		monitorEvent[DataLoadTime] = true;
		monitorEvent[DataLoadingTimeout] = true;
		monitorEvent[VideoInitLoadTime] = true;
		monitorEvent[DataLoadError] = true;	
		monitorEvent[LiveStreamFailure] = true;
		monitorEvent[BufferEmpty] = true;
		monitorEvent[VideoInitLoadTimeout] = true;
		monitorEvent[VideoStreamNotFound] = true;
		monitorEvent[VideoLoadSpeed] = true;
		monitorEvent[VideoRequest] = true;
		monitorEvent[VideoFailure] = true;
		monitorEvent[DataFailure] = true;
		monitorEvent[ContentInit] = true;
		monitorEvent[VideoInit] = true;
						
		private static var dataRepository:Nana10DataRepository;
		private static var exParams:ExternalParameters;
		private static var stats:Array;
		private static var urlLoader:URLLoader;
		private static var urlVars:URLVariables;
		private static var dataRequest:DataRequest;
		private static var itemsSharedObject:SharedObject;
		private static var timer:Timer;
		private static var sending:Boolean;
		private static var isDev:Boolean;
		private static var _debug:Boolean;
		private static var seesionId:Number;
		private static var timeoutTimer:Timer;
		private static var counter:int;
		private static var errorsCounter:int;
		private static var prevMoviePosition:int;
		private static var firstKeepAlive:Boolean;
		private static var _videoStartPoint:int;
		
		public static function init(debug:Boolean):void
		{
			stats = [];
			exParams = ExternalParameters.getInstance();
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onReady);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlVars = new URLVariables();
			urlVars.VideoSessionID  = exParams.SessionID == undefined ? "11111111-2222-3333-4444-555555555555" : exParams.SessionID;			
			if (exParams.UniqueGUID != undefined) urlVars.AnonimousGUID = exParams.UniqueGUID;
			urlVars.debug = debug;
			_debug = debug;
			counter = 1;
			firstKeepAlive = true;
			
			timeoutTimer = new Timer(10000,1);
			timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);			
		}
		
		public static function set sessionId(value:String):void
		{
			urlVars.VideoSessionID = value;
		}
		
		public static function updatePlayerStats(type:int, textInfo:String = ""):void
		{
			if (Nana10DataRepository.getInstance().previewGroupID) return;
			var cm:CommunicationLayer = CommunicationLayer.getInstance();
			if (cm.state != CommunicationLayer.PLAYER)
			{
				switch (type)
				{
					/*case StatsManagers.PlayClick:
						switch (cm.state)
						{
							case CommunicationLayer.MIDROLL:
								type = StatsManagers.MidRollPlay;
								break;
							case CommunicationLayer.POSTROLL:
								type = StatsManagers.PostRollPlay;
								break;
							case CommunicationLayer.PREROLL:
								type = StatsManagers.PreRollPlay;
								break;
						}
						break;*/
					case (StatsManagers.PauseClick):
						switch (cm.state)
						{
							case CommunicationLayer.MIDROLL:
								type = StatsManagers.MidRollPause;
								break;
							case CommunicationLayer.POSTROLL:
								type = StatsManagers.PostRollPause;
								break;
							case CommunicationLayer.PREROLL:
								type = StatsManagers.PreRollPause;
								break;
						}
						break;
					case (StatsManagers.BufferEmpty):
						switch (cm.state)
						{
							case CommunicationLayer.MIDROLL:
								type = StatsManagers.MidRollBufferEmpty;
								break;
							case CommunicationLayer.POSTROLL:
								type = StatsManagers.PostRollBufferEmpty;
								break;
							case CommunicationLayer.PREROLL:
								type = StatsManagers.PreRollBufferEmpty;
								break;
						}
						break;
					case (StatsManagers.LoadComplete):
						switch (cm.state)
						{
							case CommunicationLayer.MIDROLL:
								type = StatsManagers.MidrollLoadComplete;
								break;
							case CommunicationLayer.POSTROLL:
								type = StatsManagers.PostrollLoadComplete;
								break;
							case CommunicationLayer.PREROLL:
								type = StatsManagers.PrerollLoadComplete;
								break;
						}
						break;
				}
			}
			if (eventReport[type] == false) return; // not all events should be actually reported to the DB
			var currTime:Number = cm.state == CommunicationLayer.PLAYER ? cm.playheadTime : cm.videoPlayer.playheadTime; //_videoPlayer ? _videoPlayer.playheadTime*1000: 0;
			if (!sending && stats.length == 0)
			{
				sendData(new StatsDataObject(type,currTime,textInfo,getTimer(),getCurrentServerName(type)));
			}
			else
			{	// for cases where evnets have to wait, setting the current server name, for by the time they'll be sent - the server name might change
				stats.push(new StatsDataObject(type, currTime, textInfo, getTimer(), getCurrentServerName(type)));
				Debugging.printToConsole("StatsManager: '"+getActionName(type)+"' is waiting",stats.length);
			}
		}
		
		private static function sendData(dataOjbect:StatsDataObject):void//type:int,position:int,info:String, sessionTime:int, eventOrder:int, serverName:String = null):void
		{	
			if (urlVars == null) return;
			var type:int = dataOjbect.type;
			var urlRequest:URLRequest = new URLRequest("http://ws-ext"+ CommunicationLayer.getInstance().environment +".nana10.co.il/Video/UVS.ashx");			
			urlRequest.contentType = "application/x-www-form-urlencoded";
			urlRequest.method = URLRequestMethod.POST;
			urlVars.VideoActionID = type;			
			urlVars.VideoID  = exParams.VideoID;
			urlVars.MoviePosition = Math.max(int(dataOjbect.position)*1000,0);
			urlVars.AuditEvent =  auditEvent[type] ? true : null;
			urlVars.MonitorEvent = monitorEvent[type] ? true : null;
			
			// for some unknown reason - the AdError is sent almost endlessly with the same MoviePosition  
			// trying to avoid it.
			if (type == AdError && urlVars.MoviePosition == prevMoviePosition) return;
			
			urlVars.EventOrder = dataOjbect.eventOrder;
			urlVars.SessionTime = dataOjbect.sessionTime;			
			urlVars.Embedded = Nana10PlayerData.getInstance().embededPlayer ? 1 : 0;
			urlVars.IsLive = Nana10PlayerData.getInstance().isLive ? 1 : 0;
			if (type == KeepAlive || type == PlayerStart)
			{
				if (type == KeepAlive)
				{
					urlVars.Duration = parseInt(dataOjbect.textInfo);
					urlVars.MinimalView = urlVars.Duration >= 15*1000 ? true : false;
					urlVars.MinimalView45Sec = urlVars.Duration >= 45*1000 ? true : false;
				}
				else if (urlVars.hasOwnProperty("MinimalView") || urlVars.hasOwnProperty("MinimalView45Sec"))
				{
					urlVars.MinimalView = urlVars.MinimalView45Sec = null;
				}
				urlVars.VideoActionTextInfo = Version.VERSION;
				var serviceID:int = parseInt(exParams.ServiceID);
				if (serviceID) urlVars.ServiceID = serviceID;
				var catID:int = parseInt(exParams.CategoryID);
				if (catID) urlVars.CategoryID = catID;
				var sectionID:int = parseInt(exParams.SectionID);
				if (sectionID) urlVars.SectionID = sectionID;
				var articleID:int = parseInt(exParams.ArticleID);
				if (articleID) urlVars.ArticleID = articleID;
				var partnerID:int = parseInt(exParams.PartnerID);
				if (partnerID) urlVars.PartnerID = partnerID;
				var sectionIDs:String = exParams.RelatedSections;
				if (sectionIDs) urlVars.SectionIds = sectionIDs;
				var folderID:int = Nana10DataRepository.getInstance().folderID;
				if (folderID) urlVars.FolderID = folderID;
				if (type == StatsManagers.PlayerStart)
				{					
					urlVars.ServiceID = exParams.ServiceID;
				}
				else if (firstKeepAlive && CommunicationLayer.getInstance().videoNetDuration > 0 && Nana10PlayerData.getInstance().isLive == false)
				{
					firstKeepAlive = false;
					urlVars.videotime = int(CommunicationLayer.getInstance().videoNetDuration*1000);
				}
			}
			else
			{				
				urlVars.PartnerID = urlVars.ServiceID = null;
				urlVars.Duration = urlVars.MinimalView = null;
			}
			if (auditEvent[type] == true || monitorEvent[type] == true )
			{
				if (Nana10PlayerData.getInstance().embededPlayer == false)
				{
					try
					{
						urlVars.BrowserType = ExternalInterface.call("MediAnd.getBrowserDetails") 
					}
					catch (e:Error) {}
				}
				switch (type)
				{
					case DataLoadTime:
						urlVars.ServerLoadTime = dataOjbect.textInfo;
						urlVars.ServerName = dataOjbect.serverName;
						break;
					case DataLoadingTimeout:
					case DataLoadError:
					case DataFailure:
						urlVars.ServerName = dataOjbect.serverName;
						urlVars.ServerLoadTime = null;
						break;
					case VideoInitLoadTime:
					case VideoLoadSpeed:
						urlVars.ServerLoadTime = dataOjbect.textInfo;
						urlVars.ServerName = dataOjbect.serverName;
						break;
					case LiveStreamFailure:
					case BufferEmpty:
					case VideoInitLoadTimeout:
					case VideoStreamNotFound:
					case VideoRequest:
						urlVars.ServerName = dataOjbect.serverName;
						urlVars.ServerLoadTime = null;
						break;
					default:
						urlVars.ServerName = urlVars.ServerLoadTime = null;
				}
				/*if (type == StatsManagers.VideoInitLoadTime)
				{
					urlVars.VideoStartPoint = _videoStartPoint;
				}
				else
				{
					urlVars.VideoStartPoint = null;
				}*/
			}
			else
			{
				urlVars.BrowserType = urlVars.VideoStartPoint = null;
				urlVars.ServerName = urlVars.ServerLoadTime = null;
			}
			if (type == FormFilled || type == FormDataFound)
			{
				var userSex:String = OpeningForm.SEX;
				if (userSex != "")
				{
					urlVars.UserSex = userSex == "f" ? 2 : 3;
				}
				else
				{
					urlVars.UserSex = null;	
				}
				var userAge:String = OpeningForm.AGE;
				urlVars.UserAge = StringUtils.isStringEmpty(userAge) ? null : userAge				
			}
			else
			{
				urlVars.UserAge = urlVars.UserSex = null;
			}
			urlVars.VideoActionTextInfo = getInfo(dataOjbect.textInfo,type);
			Debugging.printToConsole("stats vars: VideoAction="+getActionName(urlVars.VideoActionID),
									 "MoviePosition="+StringUtils.turnNumberToTime(urlVars.MoviePosition/1000,true,true,true), 
									 urlVars.VideoActionTextInfo.length != Version.VERSION.length ? ("VideoActionTextInfo="+urlVars.VideoActionTextInfo) : (type == KeepAlive ? "Duration="+urlVars.Duration : ""), 
									 urlVars.ServerName != null ? "ServerName=" + urlVars.ServerName : "",
									 urlVars.ServerLoadTime != null ? "ServerLoadSpeed=" + urlVars.ServerLoadTime : "",
									 "SessionTime="+StringUtils.turnNumberToTime(urlVars.SessionTime/1000,true,true,true))
			urlRequest.data = urlVars;					
				
			urlLoader.load(urlRequest);
			sending = true;
			timeoutTimer.reset();
			timeoutTimer.start();
			prevMoviePosition = urlVars.MoviePosition;
		}
		
		private static function getInfo(info:String, type:int):String
		{
			var textInfo:String;			
			/*if (type == StatsManagers.DataLoadTime || type == StatsManagers.HiroLoadTime)
			{
				textInfo = info;
			}
			else if (type == StatsManagers.VideoInitLoadTime)
			{
				textInfo = info + "," + videoLink
			}
			else if (type == StatsManagers.BufferEmpty && Nana10PlayerData.getInstance().isLive == false)
			{	// sending the server name
				textInfo = videoLink;
			}
			else
			{*/
				textInfo = Version.VERSION;
				if (StringUtils.isStringEmpty(info) == false && monitorEvent[type] == undefined) textInfo = textInfo.concat(", " + info);
				if (errorsCounter) textInfo = textInfo.concat(", (errors: "+errorsCounter+")");						
			//}
			return textInfo;
		}
		
		private static function getCurrentServerName(type:int):String
		{
			if (type == DataLoadTime || type == DataLoadError || type == DataLoadingTimeout || type == DataFailure)
			{
				return Nana10PlayerData.getInstance().useCastUpXML ? "castup" : "nana10";
			}
			var videoLink:String;
			if (StringUtils.isStringEmpty(exParams.MediaStockVideoItemGroupID) == false && exParams.MediaStockVideoItemGroupID != "0")
			{
				videoLink = Nana10PlayerData.getInstance().videoLink;
			}
			else
			{
				videoLink = Nana10DataRepository.getInstance().videoLink;
			}
			if (videoLink == null) return null;
			var i:int = videoLink.indexOf("://");
			return videoLink.substr(i+3,5);
		}
		
		private static function onReady(event:Event):void
		{
			if (event.target.data != "1" && event.target.data != "Ok1")
			{
				Debugging.printToConsole("StatsManager - error:",event.target.data);
				errorsCounter++;
			}
			sending = false;
			timeoutTimer.stop();
			Debugging.printToConsole("--StatsManager.onReady",stats.length);
			if (stats.length)
			{
				//var obj:Object = stats.shift();				
				sendData(stats.shift());
			}
		}
		
		private static function onError(event:IOErrorEvent):void
		{
			Debugging.printToConsole("StatsManager - onError",event.text);
			errorsCounter++;
			sending = false;
			timeoutTimer.stop();
			if (stats.length)
			{
				//var obj:Object = stats.shift();
				sendData(stats.shift());
			}
		}
		
		private static function onTimeout(event:TimerEvent):void
		{
			urlLoader.close();
			Debugging.printToConsole("StatsManager - onTimeout");
			errorsCounter++;
			sending = false;
			if (stats.length)
			{
				//var obj:Object = stats.shift();
				sendData(stats.shift());
			}
		}
		
		public static function set videoStartPoint(value:String):void
		{
			if (value.length)
			{
				_videoStartPoint = parseFloat(value) * 1000;
			}
			else
			{
				_videoStartPoint = 0;
			}
		}
				
		public static function reset(debug:Boolean):void
		{
			firstKeepAlive = true;
			urlVars = new URLVariables();
			urlVars.VideoSessionID  = exParams.SessionID;		
			if (exParams.UniqueGUID != undefined) urlVars.AnonimousGUID = exParams.UniqueGUID;
			urlVars.debug = debug;
		}
		
		// only for debug purpose
		private static function getActionName(value:int):String
		{
			var action:String;
			switch (value)
			{
				case 1:
					action = "PlayClick";
					break;
				case 2:
					action = "PauseClick";
					break;
				case 3:
					action = "HQOn";
					break;
				case 4:
					action = "HQOff";
					break;
				case 5:
					action = "SceneMenuOpen";
					break;
				case 6:
					action = "ShareOpen";
					break;
				case 7:
					action = "LightOn";
					break;
				case 8:
					action = "LightOff";
					break;
				case 9:
					action = "CommentsOpen";
					break;
				case 10:
					action = "CommentsClose";
					break;
				case 11:
					action = "FullScreenOn";
					break;
				case 12:
					action = "FullScreenOff";
					break;
				case 13:
					action = "JumpToTime";
					break;
				case 14:
					action = "JumpToScene";
					break;
				case 15:
					action = "PlayerExit";
					break;
				case 16:
					action = "MoviePlay";
					break;
				case 17:
					action = "MovieEnd";
					break;
				case 18:
					action = "PreRollPlay";
					break;
				case 19:
					action = "PreRollEnd";
					break;
				case 20:
					action = "PreRollPause";
					break;
				case 21:
					action = "MidRollPlay";
					break;
				case 22:
					action = "MidRollPause";
					break;
				case 23:
					action = "MidRollEnd";
					break;
				case 24:
					action = "PostRollPlay";
					break;
				case 25:
					action = "PostRollPause";
					break;
				case 26:
					action = "PostRollEnd";
					break;
				case 27:
					action = "MoreInNanaShow";
					break;
				case 28:
					action = "BufferingStart";
					break;
				case 29:
					action = "LoadComplete";
					break;
				case 30:
					action = "BufferEmpty";
					break;
				case 31:
					action = "MoviePause";
					break;
				case 32:
					action = "Error";
					break;
				case 33:
					action = "PreRollBufferEmpty";
					break;
				case 34:
					action = "MidRollBufferEmpty";
					break;
				case 35:
					action = "PostRollBufferEmpty";
					break;
				case 37:
					action = "PrerollLoadComplete";
					break;
				case 38:
					action = "MidrollLoadComplete";
					break;
				case 39:
					action = "PostrollLoadComplete";
					break;
				case 40:
					action = "PlayerReportErateView";
					break;
				case 41:
					action = "PlayerReportCheckM8View";
					break;
				case 42:
					action = "PlayerReportErateClick"
					break;
				case 43:
					action = "PlayerReportCheckM8Click";
					break;
				case 44:
					action = "PlayerStart";
					break;
				case 45:
					action = "AutoPlay";
					break;
				case 47:
					action = "KeepAlive";
					break;
				case 48:
					action = "AdError";
					break;
				case 49:
					action = "ExpiredContent";
					break;
				case 50:
					action = "AdLoadingTime";
					break;
				case 51:
					action = "DataLoadTime";
					break;
				case 52:
					action = "DataLoadingTimeout";
					break;
				case 53:
					action = "BugReport";
					break;
				case 54:
					action = "VideoInitLoadTime";
					break;
				case 55:
					action = "DataLoadError";
					break;
				case 56:
					action = "MoreInNanaDataError";
					break;
				case 57:
					action = "MoreInNanaThumbError";
					break;
				case 58:
					action = "StillImageError";
					break;
				case 59:
					action = "CommentsLoadError";
					break;
				case 60:
					action = "NoPreroll";					
					break;
				case 61:
					action = "HiroLoadTime";
					break;
				case 62:
					action = "LiveStreamFailure";
					break;
				case 63:
					action = "autoPlay";
					break;
				case 64:
					action = "formDisplayed";
					break;
				case 65:
					action = "formIgnored";
					break;
				case 66:
					action = "formFilled";
					break;
				case 67:
					action = "FormDataFound";
					break;
				case 68:
					action = "ContentBlocked";
					break;
				case 69:
					action = "ToolbarDownloaded";
					break;
				case 70:
					action = "BannerClicked";
					break;
				case 71:
					action = "VideoInitLoadTimeout";
					break;
				case 72:
					action = "VideoStreamNotFound";
					break;
				case 73:
					action = "VideoLoadSpeed";
					break;
				case 74:
					action = "VideoRequst";
					break;
				case 75:
					action = "DataFailure";
					break;
				case 76:
					action = "VideoFailure";
					break;
				case 77:
					action = "ContentInit";
					break;
				case 78:
					action = "VideoInit";
					break;
				default:					
					action = "not found"
			}
			return action;
		}
	}
}