package com.events
{
	import flash.events.Event;

	public class Nana10PlayerEvent extends Event
	{
		public static const LOAD_COMMENTS:String = "loadComments";
		public static const ADD_COMMENT:String = "addComment";
		public static const DELETE_COMMENT:String = "deleteComment";
		public static const DETACH_COMMENTS:String = "detachComments";
		public static const REATTACH_COMMENTS:String = "reattachComments";
		public static const CLOSE_COMMENTS:String = "closeComments";
		public static const SWITCH_QUALITY_HIGH:String = "switchQualityHigh";
		public static const SWTICH_QUALITY_NORMAL:String = "swtichQualityNormal";
		public static const REPLACE_VIDEO:String = "replaceVideo";
		public static const REPLAY_VIDEO:String = "resetVideo";
		public static const END_OF_VIDEO_ERROR:String = "endOfVideoError";
		public static const LOAD_VIDEO:String = "loadVideo";
		public static const AD_BEGINS:String = "adBegins";
		public static const AD_ENDS:String = "adEnds";
		public static const AD_ERROR:String = "adError";
		public static const FORM_CLOSED:String = "formClosed";
		public static const VOLUME_CHANGED:String = "volumeChanged";
		public static const HQ_DOWNLOAD_WINDOW_OPENED:String = "hqDownloadWindowOpened";
		public static const HQ_DOWNLOAD_WINDOW_CLOSED:String = "hqDownloadWindowClosed";
		public static const COMMENTS_CLOSED:String = "commentsClosed";
		public static const COMMENTS_OPENED:String = "commnetsOpned";
		public static const QPAY:String = "qpay";
		public static const GET_LOADING_SPEED:String = "getLoadingSpeed";
		public static const SEND_BUG_REPORT:String = "sendBugReport";
		public static const OVERLAY_CLICKED:String = "overlayClicked";
		public static const OVERLAY_READY:String = "overlayReady";
		public static const OVERLAY_ERROR:String = "overlayError";
		public static const ADSENSE_CLICKED:String = "adsenseClicked";
		public static const EMBED:String = "embed";
		public static const HIDE_CONTROLS:String = "hideControls";
		public static const SHOW_CONTROLS:String = "showControls";
		public static const RESUME_FROM_START:String = "resumeFromStart";
		public static const RESUME_FROM_LAST:String = "resumeFromLast";
		public static const ZIXI_PROXY_FOUND:String = "zixiProxyFound";
		public static const ZIXI_PROXY_MISSING:String = "zixiProxyMissing";
		public static const ZIXI_CONTINUE:String = "zixiContinue";
		
		public var videoId:int;
		public var articleId:int;
		public var adError:Boolean;
		public var volumeLevel:Number;
		public var hiddenReport:Boolean;
		public var bugReportData:String;
		
		public function Nana10PlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var nana10PlayerEvent:Nana10PlayerEvent = new Nana10PlayerEvent(this.type,this.bubbles,this.cancelable);
			nana10PlayerEvent.videoId = videoId;
			nana10PlayerEvent.articleId = articleId;
			nana10PlayerEvent.volumeLevel = volumeLevel;
			nana10PlayerEvent.hiddenReport = hiddenReport;
			nana10PlayerEvent.bugReportData = bugReportData;
			return nana10PlayerEvent;
		}
		
	}
}