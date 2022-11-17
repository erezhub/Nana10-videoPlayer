package com.data
{
	import com.data.cm8.CM8PluginDelegate;
	import com.events.Nana10DataEvent;
	import com.events.Nana10PlayerEvent;
	import com.events.VideoControlsEvent;
	import com.fxpn.util.Debugging;
	import com.ui.Nana10VideoPlayer;
	import com.ui.ads.AdsContainer;
	
	import flash.events.EventDispatcher;
	
	public class CommunicationLayer extends EventDispatcher
	{
		public static var PLAYER:int = 0;
		public static var PREROLL:int = 1;
		public static var MIDROLL:int = 2;
		public static var POSTROLL:int = 3;
		
		public static const MINS_BETWEEN_MIDROLLS:int = 5;
		public static const SECS_BEFORE_AD_MESSAGE:int = 6;
		public static const AD_PREBUFFER_TIME:int = 15;
		
		private static var _instance:CommunicationLayer;
		
		private var _videoPlayer:Nana10VideoPlayer;	
		private var _cm8Delegate:CM8PluginDelegate;
		//private var _sceneStartTime:Number = 0;
		private var _currentStartTime:Number = 0;
		private var _offset:Number = 0;
		//private var _sceneDuration:Number = 0;
		private var _videoStartOffset:Number = 0;
		private var _enableSeek:Boolean;
		private var _scencesGaps:Number = 0;  // gap between the scenes till current playhead positoin
		private var _actionsServer:String;
		
		public var videoSeekPointsArray:Array;
		public var videoGrossDuration:Number = 0; // length of video to display - from first segment to the last one
		public var videoNetDuration:Number = 0; // videoGrossDuration minus gaps between segments
		private var _videoStartPoint:Number;
		public function get videoStartPoint():Number
		{
			return _videoStartPoint;
		}

		public function set videoStartPoint(value:Number):void
		{			
			_videoStartPoint = Math.max(value,0);
		}

 // for videos that don't start from 0:00:000
		public var currentSegmentId:int;
		private var _hasPreroll:Boolean;
		private var _hadPreroll:Boolean;
		
		public var hasPostroll:Boolean;
		
		public var state:int; // false - normal; true - advertisment
		
		public function CommunicationLayer()
		{
			if (_instance != null)
			{
				throw new Error("CommunicationLayer can only be accessed through TaggerCommunicationLayer.getInstance()")
			}			
		}
		
		public static function getInstance():CommunicationLayer
		{
			if (_instance == null)
			{
				_instance = new CommunicationLayer();
			}
			return _instance;
		}
		
		public function set hasPreroll(value:Boolean):void
		{
			_hasPreroll = value;
			if (value) _hadPreroll = true;
		}
		
		public function get hasPreroll():Boolean
		{
			return _hasPreroll;
		}
		
		public function get hadPreroll():Boolean
		{
			return _hadPreroll;
		}
		
		public function set videoPlayer(value:Nana10VideoPlayer):void
		{
			_videoPlayer = value;
		}
		
		public function get videoPlayer():Nana10VideoPlayer
		{
			return _videoPlayer;
		}
		
		public function set cm8Deleage(value:CM8PluginDelegate):void
		{
			_cm8Delegate = value;
		}
		
		public function get playheadTime():Number
		{
			var _playheadTime:Number = _videoPlayer.playheadTime;
			if (!(_videoPlayer is AdsContainer))
				_playheadTime += (_currentStartTime - _offset) - _scencesGaps - _videoStartOffset;
			return  _playheadTime;
		}
		
		public function get videoDuration():Number
		{
			return _videoPlayer.duration;
		}
		
		public function gotoFrame(timeCode:Number):void
		{
			_videoPlayer.gotoFrame(timeCode);
		}
		
		public function seek(timeCode:Number):void
		{
			dispatchEvent(new VideoControlsEvent(VideoControlsEvent.GO_TO_FRAME,timeCode));
		}
		
		public function toggleShare():void
		{
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.EMBED));
		}
		
		/*public function set sceneStartTime(value:Number):void
		{
			_sceneStartTime = value;
			trace("commLayer",_sceneStartTime);
		}
		
		public function get sceneStartTime():Number
		{
			return _sceneStartTime;
		}*/
		
		public function set currentStartTime(value:Number):void
		{
			_currentStartTime = value;
		}
		
		public function get currentStartTime():Number
		{
			return _currentStartTime;
		}
		
		public function set offset(value:Number):void
		{
			_offset = value;
		}
		
		public function get offset():Number
		{
			return _offset;
		}
		
		/*public function set sceneDuration(value:Number):void
		{
			_sceneDuration = value;
		}
		
		public function get sceneDuration():Number
		{		
			if (_sceneDuration)
			{
				return _sceneDuration;
			}
			return _videoPlayer.duration + _currentStartTime - _offset;
		}*/
		
		public function set videoStartOffset(value:Number):void
		{
			_videoStartOffset = Math.max(value,0); // making sure its not negative
			//videoGrossDuration+=_videoStartOffset;
			//videoNetDuration+= _videoStartOffset;
		}
		
		public function get videoStartOffset():Number
		{
			return _videoStartOffset;
		}
		
		public function set enableSeek(value:Boolean):void
		{
			_enableSeek = value;
		}
		
		public function get enableSeek():Boolean
		{
			return _enableSeek;
		}
		
		public function set scenesGaps(value:Number):void
		{
			_scencesGaps = value;
		}
		
		public function get scenesGaps():Number
		{
			return _scencesGaps;
		}
		
		public function get actionsServer():String
		{
			if (_actionsServer == null)
			{				
				_actionsServer = "http://common"+ environment +".nana10.co.il/Video/Action.ashx/Player/";
				//_actionsServer = "http://localhost:63215/Action.ashx/Player/";
			}
			return _actionsServer;
		}
		
		public function get environment():String
		{
			return ExternalParameters.getInstance().Environment == undefined ? "" : ExternalParameters.getInstance().Environment;
		}
		
		public function switchToZixi():void
		{
			dispatchEvent(new Nana10DataEvent(Nana10DataEvent.DATA_READY));
		}
		
		// for testing purposes
		public function showAd():void
		{
			_cm8Delegate.reachedCuePoint(1000);
		}
		
		// for testing purposes
		public function skipAd():void
		{
			_cm8Delegate.terminateRunningAds();
			state = CommunicationLayer.PLAYER;
		}
		
		public function reset():void
		{
			//_sceneStartTime = 0;
			_currentStartTime = 0;
			_offset = 0;
			//_sceneDuration = 0;
			_videoStartOffset = 0;
			_scencesGaps = 0;
			videoGrossDuration = videoNetDuration = videoStartOffset = 0; 
			videoStartPoint = NaN;
			hasPreroll = false;
		}
		
	}
}