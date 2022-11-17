package com.events
{
	import flash.events.Event;

	public class Nana10DataEvent extends Event
	{
		public static const LOAD_STILL_IMAGE:String = "loadStillImage";
		public static const DATA_READY:String = "dataReady";
		public static const SHARED_DATA_READY:String = "sharedDataReady";
		public static const VIDEO_NOT_FOUND:String = "videoNotFound";
		public static const LOAD_VIDEO:String = "loadVideo";
		public static const SWITCH_VIDEO:String = "switchVideo";
		public static const SWITCH_NANA_VIDEO:String = "switchNanaVideo";
		public static const COMMENTS_LOADED:String = "commentsLoaded";
		public static const HIRO_WRAPPER_READY:String = "hiroWrapperReady";
		public static const HIRO_DATA_READY:String = "hiroDataReady";
		public static const HIRO_AD_PREPARED:String = "hiroAdPrepared";
		public static const VIDEO_FINISHED_LOADING:String = "videoFinishedLoading";
		
		public var stillImageURL:String;
		public var CM8Target:String;
		public var videoFile:String;
		public var videoStartTime:String;
		public var clipDuration:Number;
		public var adURL:String;
		public var adClickURL:String;
		
		public function Nana10DataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{			
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var nana10DataEvent:Nana10DataEvent = new Nana10DataEvent(this.type,this.bubbles,this.cancelable);
			nana10DataEvent.stillImageURL = stillImageURL;
			nana10DataEvent.CM8Target = CM8Target;
			nana10DataEvent.videoFile = videoFile;
			nana10DataEvent.videoStartTime = videoStartTime;
			nana10DataEvent.clipDuration = clipDuration;
			nana10DataEvent.adURL = adURL;
			nana10DataEvent.adClickURL = adClickURL;
			return nana10DataEvent;
		}
	}
}