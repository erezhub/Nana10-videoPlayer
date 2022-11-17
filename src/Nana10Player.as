package {
	import com.KeyboardShortcutsMangaer;
	import com.adobe.utils.ArrayUtil;
	import com.checkm8.advantage.video.delegation.player.api.event.PlayerEvent;
	import com.checkm8.advantage.video.delegation.player.api.event.PluginEvent;
	import com.data.CastUpXMLParser;
	import com.data.CheckVideoLinkChange;
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.GemiusDelegate;
	import com.data.HQDataLoader;
	import com.data.ImageSnapper;
	import com.data.Nana10DataParser;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.data.Version;
	import com.data.WatchedVideoData;
	import com.data.ZixiDelegate;
	import com.data.cm8.CM8PluginDelegate;
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.data.items.player.Nana10CommentData;
	import com.data.items.player.Nana10SegmentEndData;
	import com.demonsters.debugger.MonsterDebugger;
	import com.events.Nana10DataEvent;
	import com.events.Nana10PlayerEvent;
	import com.events.RequestEvents;
	import com.events.VideoControlsEvent;
	import com.events.VideoPlayerEvent;
	import com.fxpn.display.ModalManager;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.display.TooltipFactory;
	import com.fxpn.util.ContextMenuCreator;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	import com.fxpn.util.StringUtils;
	import com.google.ads.instream.api.*;
	import com.io.DataRequest;
	import com.ui.BottomBannerContainer;
	import com.ui.Nana10VideoPlayer;
	import com.ui.StillImage;
	import com.ui.ads.AdSenseContainer;
	import com.ui.ads.AdStrip;
	import com.ui.ads.AdsContainer;
	import com.ui.ads.OverlayContainer;
	import com.ui.controls.ControlsBar;
	import com.ui.pannels.DownloadToolbarMessage;
	import com.ui.pannels.EndOfVideoDisplay;
	import com.ui.pannels.OpeningForm;
	import com.ui.pannels.ResumeVideoWindow;
	import com.ui.pannels.ShareButtons;
	import com.ui.pannels.ShareWindow;
	import com.ui.pannels.ZixiDownload;
	import com.ui.pannels.bugs.BugReporting;
	import com.ui.pannels.bugs.SendReport;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;
	import flash.utils.getTimer;
	
	import gs.TweenLite;
	
	import mx.utils.ObjectUtil;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import resources.LoadingAnimation;
	import resources.Logo;
			
	public class Nana10Player extends Sprite
	{
		protected var dataRepository:Nana10DataRepository; // instance of the DataRepository singleton
		protected var communicationLayer:CommunicationLayer; // instance of the CommunicationLayer singleton
		protected var nana10PlayerData:Nana10PlayerData;
		protected var externalParams:ExternalParameters;
		protected var cm8Delegate:CM8PluginDelegate;
		
		private var background:Shape;
		protected var videoPlayer:Nana10VideoPlayer;
		private var controls:ControlsBar;
		protected var screenCover:Shape;
		private var nana10Logo:Logo;
		private var endOfVideoDispaly:EndOfVideoDisplay;
		protected var stillImage:StillImage;
		private var adStrip:AdStrip;
		private var loadingAnimation:LoadingAnimation;
		private var openingForm:OpeningForm;
		private var shareButtons:ShareButtons;
		private var shareWindow:ShareWindow;
		private var bugReporting:BugReporting; // this is the bug reporting form
		private var bugReportingRightClick:Sprite; // this is used when the 'report bug' option is selected in the context-menu (more details when instansiated)
		private var sendReport:SendReport; // this is the yes/no prompt box opened when a show-stopper error is detected
		protected var cm8PlaceHolder:Sprite; // an empty sprite used by the CM8 plugin to display the ads
		private var bottomBanner:BottomBannerContainer;
		private var resumeVideoWindow:ResumeVideoWindow;
		private var zixiDownloadWindow:ZixiDownload;
		
		private var videoStarted:Boolean;
		private var videoInitialized:Boolean;
		private var videoAlreadyEnded:Boolean;		
		protected var videoFile:String;
		private var videoFileNormal:String;	
		private var adBreak:Boolean;
		protected var firstTime:Boolean;
		private var seek:Boolean;
		private var pausedBeforeSeek:Boolean;
		private var seekToPoint:Number;
		protected var seekStartoffset:Number;
		private var replayVideo:Boolean;
		private var initiallyPaused:Boolean;
		protected var delayedStartTimer:Timer;
		private var resetVolume:Number;
		private var postPrerollVideoTime:Number;
		private var stuckDelta:Number = 0;
		protected var offsetTimer:Timer;
		private var offsetTimeCounter:int;
		protected var offsetVolume:Number;
		protected var seekSegmentOffset:Number;	
		private var videoLoadTime:int;
		private var videoLoadTimer:Timer;
		private var timeoutsCounter:int;
		private var videoNotFound:Boolean;
		protected var cm8AdLength:Number;
		protected var cm8CurrentAdID:int;
		protected var cm8AdLengthDict:Dictionary;
		protected var cm8Postroll:Boolean;
		protected var cm8WorkplanComplete:Boolean;
		protected var cm8HasPreroll:Boolean;
		private var cm8adRunning:Boolean;
		private var cm8LinearAd:*; // not using boolean, for when the value isn't set yet, want to make sure its undefined (and not false)
		private var bufferEvents:int;
		private var buffering:Boolean;
		private var liveStreamSwitch:Boolean;
		protected var hqDataLoader:HQDataLoader;
		private var reportVideoWatched:Boolean;
		private var bufferingPlayheadTime:Number = 0;
		private var runCheckForResume:Boolean = true;
		private var bufferTimer:Timer;
		private var zixiDelegate:ZixiDelegate;
		
		public function Nana10Player()
		{
			Debugging.printToConsole("--Nana10Player");
			Security.allowDomain("*");			
			dataRepository = Nana10DataRepository.getInstance();
			communicationLayer = CommunicationLayer.getInstance();	
			nana10PlayerData = Nana10PlayerData.getInstance();			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
			seekStartoffset = seekToPoint = 0;			
			com.demonsters.debugger.MonsterDebugger.initialize(this);
		}
		
		private function onAddedToStage(event:Event):void
		{	
			if (parent == stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}			      
			Debugging.setOnScreenDisplay(stage);// adding debugging console above the stage    
			Debugging.onScreen = false;
			externalParams = ExternalParameters.getInstance(); // keeping all the FlashVars in the ExternalParameters dynamic class
			nana10PlayerData.init(stage);
			StatsManagers.init(loaderInfo.url.indexOf("localhost") > -1 || loaderInfo.url.indexOf("file://") > -1 || StringUtils.isStringEmpty(externalParams.Environment) == false);
			GemiusDelegate.init();
		}
		
		// using EnterFrame event instead of the AddedToStage, since in IE it would cause problems when refreshing the browser
		protected function onEnterFrame(event:Event):void
		{
			if (stage == null) return;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame)
			
			firstTime = true;
			tabChildren = false;
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onDisplayStateChanged);
			var stageHeight:Number; 
			var stageWidth:Number;
			if (parent == stage || parent is Nana10Preloader)
			{
				stageHeight = stage.stageHeight;
				stageWidth = stage.stageWidth;
			}
			else
			{
				stageHeight = parent.height;
				stageWidth = parent.width;
			}
			if (stageHeight % 2 == 0) stageHeight+=1;						
			
			// adding the controls
			controls = new ControlsBar(stageWidth);
			controls.addEventListener(VideoControlsEvent.PLAY, onVideoPlayed);
			controls.addEventListener(VideoControlsEvent.PAUSE, onVideoPaused);
			controls.addEventListener(VideoPlayerEvent.REACHED_KEYFRAME, onReachedKeyframe);
			controls.addEventListener(VideoControlsEvent.GO_TO_FRAME, onSeek);
			controls.addEventListener(Nana10PlayerEvent.SWITCH_QUALITY_HIGH, onSwitchQuality);
			controls.addEventListener(Nana10PlayerEvent.SWTICH_QUALITY_NORMAL, onSwitchQuality);
			controls.addEventListener(VideoControlsEvent.CHANGE_VOLUME, onVolumeChanged);
			if (nana10PlayerData.isLive == false) 
			{
				controls.addEventListener(Nana10PlayerEvent.HIDE_CONTROLS,onHideShare);
				controls.addEventListener(Nana10PlayerEvent.SHOW_CONTROLS,onShowShare);
			}
			
			//controls.x = 10;
			controls.width = stageWidth;
			controls.visible = false;
			
			// adding the main background
			background = ShapeDraw.drawSimpleRect(stageWidth,stageHeight,0x1e1e1e);
			
			// adding the main video player
			videoPlayer = new Nana10VideoPlayer(stageWidth,stageHeight - 30,true,true,0, false,true);
			videoPlayer.name = "mainPlayer";
			videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_DATA_READY, onVideoDataReady);
			videoPlayer.addEventListener(VideoPlayerEvent.NOT_FOUND, onStreamNotFound);
			if (nana10PlayerData.isLive == false) videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_ENDED, onVideoEnded);
			videoPlayer.addEventListener(VideoPlayerEvent.CANNOT_SEEK, onSeek);
			videoPlayer.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClickVideo);
			videoPlayer.addEventListener(VideoPlayerEvent.BUFFER_EMPTY, onVideoBufferEmpty);
			videoPlayer.addEventListener(VideoPlayerEvent.BUFFER_LOADING, onVideoBuffering);
			videoPlayer.addEventListener(VideoPlayerEvent.BUFFER_FULL, onSeekComplete);
			videoPlayer.addEventListener(VideoPlayerEvent.START,onVideoStart);
			videoPlayer.addEventListener(VideoPlayerEvent.STREAM_ERROR,onLivestreamFailure);
			videoPlayer.addEventListener(VideoPlayerEvent.FINISHED_LOADING,onVideoFinishedLoading);
			videoPlayer.addEventListener(VideoPlayerEvent.REACHED_CUEPOINT,onReachedQuePoint);
			videoPlayer.doubleClickEnabled = true;
			videoPlayer.smoothing = nana10PlayerData.smoothing;
			controls.videoPlayer = communicationLayer.videoPlayer = videoPlayer;
						
			// adding the screen cover
			screenCover = ShapeDraw.drawSimpleRect(videoPlayer.width, videoPlayer.height);
			screenCover.alpha = 0.5;
			
			// adding the strip at the top of the screen for displaying data regarding ads and errors
			adStrip = new AdStrip();
			adStrip.width = stageWidth;
			
			// adding the loading animation
			loadingAnimation = new LoadingAnimation();
			DisplayUtils.align(videoPlayer,loadingAnimation);
			
			// adding nana10 logo at the bottom left corner
			nana10Logo = new Logo();
			nana10Logo.alpha = 0.5;
			DisplayUtils.spacialAlign(stage,nana10Logo,DisplayUtils.RIGHT,3,DisplayUtils.TOP,3);
			
			// adding and loading the still image 
			stillImage = new StillImage();
			stillImage.setDimensions(videoPlayer.width,videoPlayer.height);
			
			// adding the end-of-video screen
			endOfVideoDispaly = new EndOfVideoDisplay();
			endOfVideoDispaly.visible = false;
			endOfVideoDispaly.height = videoPlayer.height;
			endOfVideoDispaly.addEventListener(Nana10PlayerEvent.REPLACE_VIDEO, onReplaceVideo);
			endOfVideoDispaly.addEventListener(Nana10PlayerEvent.END_OF_VIDEO_ERROR,onEndOfVideoError);
			endOfVideoDispaly.addEventListener(Nana10PlayerEvent.REPLAY_VIDEO, onResetVideo);
			
			if (dataRepository.previewGroupID == 0) openingForm = new OpeningForm();
						
			/* this sprite is used for catching context-menu click event.
				to be more presice:  the context menu now includes a 'report bug' item, which opens a form for reporting a bug.
				however, it seems to be a known bug that over a video object, when a context menu item is clicked the event is fired.
				thus, the context menu is also attached to this transparent sprite, so the select event is fired prpoerly.
				but since this sprite now covers the ads' player, when its clicked it informs the ads' player which opens the relevant URL
			*/
			bugReportingRightClick = new Sprite();
			bugReportingRightClick.addChild(ShapeDraw.drawSimpleRect(videoPlayer.width,videoPlayer.height,0,0));
			bugReportingRightClick.x = videoPlayer.x;
			bugReportingRightClick.y = videoPlayer.y;
			bugReportingRightClick.addEventListener(MouseEvent.CLICK,onClickAd);
			
			// initialzing the KeyboardShortcutsManager class
			KeyboardShortcutsMangaer.stage = stage;
			KeyboardShortcutsMangaer.controls = controls;
			KeyboardShortcutsMangaer.enableKeyboardShortcuts();
			
			cm8PlaceHolder = new Sprite(); // this sprite will contain all of CM8's ads - linears and overlays
						
			shareButtons = new ShareButtons();
			shareButtons.x = 7;
			shareButtons.y = 9;
			shareButtons.visible = false;
			shareButtons.addEventListener(Nana10PlayerEvent.EMBED,onOpenShareWindow);
			
			shareWindow = new ShareWindow();
			DisplayUtils.align(videoPlayer,shareWindow);
			shareWindow.visible = false;
			
			// bottom banner container is used for displaying permanent textual ads below the player
			bottomBanner = new BottomBannerContainer();
			bottomBanner.y = videoPlayer.height;
						
			// adding all the visual elements		
			addChild(background);
			addChild(videoPlayer);
			addChild(stillImage);
			// not adding the logo when a certain clip is embedded in Melingo's website
			if (!nana10PlayerData.embededPlayer && externalParams.ArticleID!=833505) addChild(nana10Logo);
			addChild(screenCover);
			addChild(cm8PlaceHolder);
			addChild(bugReportingRightClick);
			if (!nana10PlayerData.isLive)
			{
				addChild(shareButtons);
				addChild(shareWindow);
			}
			addChild(endOfVideoDispaly);
			addChild(controls);		
			addChild(adStrip);			
			addChild(loadingAnimation);			
			
			controls.y = stageHeight - controls.height - 36;
			DisplayUtils.align(videoPlayer,controls,true,false);
			
			// adding the version and the 'report bug' items to the context menu
			var cm:ContextMenu = ContextMenuCreator.setContextMenu("Nana10 Player Version " + Version.VERSION,loaderInfo.url.indexOf("http://") == -1);
			ContextMenuCreator.addContextMenuItem(cm,"דווח על תקלה",onOpenBugReporting);			
			contextMenu = bugReportingRightClick.contextMenu = cm;
			
			if (externalParams.Preview == 1)
			{	// in preview mode - adding image snapping functionality
				var imageSnapper:ImageSnapper = new ImageSnapper(videoPlayer);
				ContextMenuCreator.addContextMenuItem(cm,"צילום מסך",imageSnapper.saveImage);
				KeyboardShortcutsMangaer.imageSnapper = imageSnapper;
			}
			
			addToolTip();
			var nudnik:Boolean = true; // when false - not nagging the user with ads, forms and blocking when toolbar is missing
			var checkForToolbar:Boolean = false;
			var local:String = loaderInfo.url.indexOf("http") == -1 ? "" : "parent.";  // easy access to JS functions
			try
			{
				nudnik = ExternalInterface.call(local + "RequestQueryString","WNB") != 1;
				checkForToolbar = ExternalInterface.call(local + "RequestQueryString","checkForToolbar") == 1;
			}
			catch (e:Error) {};
			if ((checkForToolbar || (externalParams.checkForToolbar == 1 && nudnik)) && Capabilities.os.indexOf("Windows") == 0)
			{	// check for nana's toolbar existance (only on WIN) by calling a JS function.  if not found - display a message
				try
				{
					if (local.length) local = "MediAnd.";
					if (ExternalInterface.call(local + "IsToolbarInstalledAndDisplayed") == false)
						addChild(new DownloadToolbarMessage(stage.stageWidth,stage.stageHeight));
					else
						setPlayerData();
				}
				catch (e:Error)
				{
					Debugging.printToConsole("IsToolbarInstalledAndDisplayed error",e.message);
					setPlayerData();
				}
			}
			else
			{
				setPlayerData();
			}
		}
		
		// adding a global tool-tip component
		private function addToolTip():void
		{
			addChild(TooltipFactory.getInstance())
			TooltipFactory.setDisplayStyle(TooltipFactory.GRAPHIC_BACKGROUND,0xeeeeee,0xBDBCB7,"Arial",10,0,1,null,TooltipFactory.ALIGN_CENTER,true);
		}
						
		protected function setPlayerData():void
		{
			Debugging.printToConsole("--Nana10Player.setPlayerData");
			if (nana10PlayerData.autoPlay) StatsManagers.updatePlayerStats(StatsManagers.ContentInit);
			addRemoveFromStageFunctionality();
			nana10PlayerData.addEventListener(Nana10DataEvent.DATA_READY,onMetaDataReady);
			nana10PlayerData.addEventListener(Nana10DataEvent.LOAD_VIDEO, onLoadVideo);
			nana10PlayerData.addEventListener(Nana10DataEvent.VIDEO_NOT_FOUND, onVideoNotFound);
			nana10PlayerData.addEventListener(Nana10DataEvent.SHARED_DATA_READY, onSharedVideoDataReady);
			nana10PlayerData.addEventListener(Nana10DataEvent.LOAD_STILL_IMAGE, onLoadStillImage);
			nana10PlayerData.addEventListener(RequestEvents.DATA_ERROR,onDataError);
			nana10PlayerData.addEventListener(Nana10PlayerEvent.SEND_BUG_REPORT,onReportBug);
			communicationLayer.addEventListener(Nana10DataEvent.DATA_READY,onMetaDataReady);
			if (dataRepository.previewGroupID == 0)
			{
				if (nana10PlayerData.isLive == false)
				{
					nana10PlayerData.prepareData();
					if (nana10PlayerData.embededPlayer) nana10Logo.gotoAndStop("big");
				}
				else
				{
					var local:String = loaderInfo.url.indexOf("http") == -1 ? "" : "parent."; 
					try
					{
						if (ExternalInterface.call(local + "RequestQueryString","zixi"))
						{
							externalParams.VideoLink = "http://127.0.0.1:4500/channel.flv?url=zixi://80.244.172.10/nana500";
						}
					}
					catch (e:Error) {};
				}
				if (isContentBlocked == false) checkOpeningForm();
				if (nana10PlayerData.embededPlayer == false) addChild(bottomBanner);
			}
			else // no need to load data when previewing from the tagger
			{
				preview(true);
			}
		}
		
		private function onLoadStillImage(event:Nana10DataEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onLoadStillImage",event.stillImageURL);
			stillImage.loadImage(event.stillImageURL);
		}
		
		// checking if the player is displayed outside of nana10 domains and wasn't embedded properly.
		// if isn't embedded propertly (i.e. - the entire iFrame is embedded, and not only the player) - blocking the player
		private function get isContentBlocked():Boolean
		{
			Debugging.printToConsole("--Nana10Player.isContentBlocked");
			var blocked:Boolean;
			if (nana10PlayerData.embededPlayer && (externalParams.EnableEmbed == "0" || nana10PlayerData.isLive))
			{
				blocked = true;
			}
			else if (!nana10PlayerData.embededPlayer)
			{
				try
				{
					var href:String = ExternalInterface.call("top.location.href.toString");
					var windowHref:String = ExternalInterface.call("window.location.href.toString");
					Debugging.printToConsole("href",href);
					Debugging.printToConsole("windowHref",windowHref);
					if ((StringUtils.isStringEmpty(href) || href.indexOf(".nana10.co.il") == -1) && windowHref.indexOf(".nana10.co.il") == -1 && windowHref.indexOf(".nana10.net.il") == -1 && windowHref.indexOf(".nana10.tv") == -1 && (StringUtils.isStringEmpty(href) || href.indexOf("mana.co.il") == -1) && loaderInfo.url.indexOf("localhost") == -1 && loaderInfo.url.indexOf("inetpub/wwwroot/") == -1)
					{
						blocked = true;
					}
					Debugging.printToConsole(blocked);
				}
				catch (e:Error)
				{
					Debugging.printToConsole("error",e.message);
					blocked = true;
				}
			}
			if (blocked)
			{
				displayErrorMessage("http://f.nau.co.il/partner48/Common/Images/VideoPlayer/UI/VideoBlocked.jpg");
			}
			return blocked;
		}
		
		private function checkOpeningForm(makeDataRequest:Boolean = false):void
		{
			if (!nana10PlayerData.embededPlayer && openingForm && openingForm.checkDisplay(stage))
			{
				addChild(openingForm);
				ModalManager.setModal(openingForm);
				DisplayUtils.align(stage,openingForm);	
				openingForm.addEventListener(Nana10PlayerEvent.FORM_CLOSED, onFormClosed);
			}
			else
			{
				openingForm = null;
				controls.visible = shareButtons.visible = true;
				if (nana10PlayerData.embededPlayer == false || makeDataRequest)
				{
					checkVideoLink();
				}
			}
		}
		
		private function onFormClosed(event:Nana10PlayerEvent):void
		{
			ModalManager.clearModal();
			removeChild(openingForm);
			openingForm.removeEventListener(Nana10PlayerEvent.FORM_CLOSED, onFormClosed);
			openingForm = null;
			controls.visible = shareButtons.visible = true;
			checkVideoLink();
		}
		
		protected function checkVideoLink():void
		{
			if (nana10PlayerData.checkVideoLink())
			{				
				onMetaDataReady(null);
			}
			else if (nana10PlayerData.isLive && externalParams.VideoLink) 
			{
				nana10PlayerData.getVideoFile(externalParams.VideoLink + "&curettype=1");
			}
		}		
		
		// data for embeded player is loaded
		private function onSharedVideoDataReady(event:Nana10DataEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onSharedDataReady");
			if (nana10PlayerData.embededPlayer && !StringUtils.isStringEmpty(externalParams.ShareLink) && externalParams.ArticleID!=833505) // no click on the melingo content
			{
				bugReportingRightClick.addEventListener(MouseEvent.CLICK, onClickVideo);
			}
			else if (bugReportingRightClick && bugReportingRightClick.hasEventListener(MouseEvent.CLICK))
			{
				bugReportingRightClick.removeEventListener(MouseEvent.CLICK, onClickVideo);
			}
			nana10PlayerData.prepareData(false); // load the real data
			addChild(bottomBanner);
			GemiusDelegate.playerID = externalParams.SessionID;
			GemiusDelegate.setCritertions(externalParams.ServiceName);
			if (isContentBlocked == false) checkOpeningForm(true);
		}
		
		protected function onDataError(evt:RequestEvents):void
		{
			Debugging.printToConsole("--Nana10Player.onDataError", timeoutsCounter);
			if (evt.errorMessage.indexOf("Error #1085") == -1)
			{	
				if (adStrip) adStrip.error("שגיאה בטעינת המידע",false);
				if (dataRepository.previewGroupID == 0)
				{
					reportBug();
					StatsManagers.updatePlayerStats(StatsManagers.DataFailure);
					if (nana10PlayerData.autoPlay == false) StatsManagers.updatePlayerStats(StatsManagers.ContentInit);
				}
				hideLoadingAnimation();	
			}
			else
			{   // data is blocked for outside-of-israel users - display a message - TEMP
				displayErrorMessage("http://f.nanafiles.co.il/Common/Flash/GeoBlock_Regular.jpg");
			}
		}
		
		protected function onVideoNotFound(event:Nana10DataEvent):void
		{
			if (liveStreamSwitch && dataRepository.videoWMVStreamingPath)
			{
				liveStreamSwitch = false;
				try
				{
					ExternalInterface.call("MediAnd.ChangePlayerType",dataRepository.videoWMVStreamingPath , 0, 1, 1);
				}
				catch (e:Error) 
				{
					Debugging.printToConsole("MediAnd.ChangePlayerType ERROR");	
				}
			}
			else if (cm8Delegate && cm8Delegate.isRunning)
			{	// if this event is dispathed while the ad is playing - display the error message only when its done
				videoNotFound = true;
			}
			else
			{
				if (adStrip) adStrip.error("שגיאה בטעינת המידע",false);
				reportBug();			
				hideLoadingAnimation();
			}
			if (delayedStartTimer && delayedStartTimer.running) delayedStartTimer.stop();			
		}
		
		// tagger/castup raw data is ready
		protected function onMetaDataReady(event:Nana10DataEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onMetaDataReady");
			if (event && event.videoFile)
			{
				videoFile = dataRepository.videoLink = event.videoFile;	
			}
			else
			{
				videoFile = dataRepository.videoLink;				
				if (videoPlayer.source && videoPlayer.source.indexOf("castup") > -1 && videoFile.indexOf("zixi") > -1 && videoPlayer.isPlaying)
				{
					liveStreamSwitch = true;
				}
				else if (videoFile.indexOf("zixi") > -1 && videoPlayer.isPlaying == false)
				{
					CheckVideoLinkChange.playingZixi = true;
				}
			}

			if (videoFile.indexOf("90103a_en.wmv")>-1 || videoFile.indexOf("90101a_en.wmv")>-1)
			{	// showing message for expired content in case the video file contains the latter string
				displayErrorMessage("http://f.nanafiles.co.il/Common/Flash/content_removed.jpg");
				if (shareButtons) shareButtons.visible = false;
				return;
			}
			if (videoFile.indexOf("90104a_en.wmv") > -1)
			{	// data is blocked for outside-of-israel users - display a message
				displayErrorMessage("http://f.nanafiles.co.il/Common/Flash/GeoBlock_Regular.jpg");
				if (shareButtons) shareButtons.visible = false;
				return;
			}
			try
			{	// for testing a specific cast-up server - using a query string
				var testServer:String = ExternalInterface.call("parent.RequestQueryString","CUS");
				if (testServer)
				{
					var currentServer:String = videoFile.substr(7,5);
					videoFile = videoFile.replace(currentServer,testServer);
				}
			}
			catch (e:Error) {
				Debugging.printToConsole("failed to call RequestQueryString",e.message);
			}
			StatsManagers.updatePlayerStats(StatsManagers.KeepAlive,"0");
			timeoutsCounter = 0;
			if (liveStreamSwitch)
			{
				if (videoFile.indexOf("zixi") == -1)
				{
					playVideo();
				}
				else
				{
					checkForZixi();
				}
			}
			else if (nana10PlayerData.showAds)
			{
				if (cm8Delegate == null)
				{
					setM8PDelegate();
				}
				else if (cm8Delegate.pluginLoaded)
				{
					cm8Delegate.loadWorkplan();
				}
				else
				{
					cm8Delegate.loadPlugin();
				}
			}
			else if (nana10PlayerData.autoPlay)
			{
				controls.enablePreMovieButtons(nana10PlayerData.embededPlayer);
				StatsManagers.updatePlayerStats(StatsManagers.AutoPlay);
				playVideo();
			}
			else
			{
				hideLoadingAnimation();// hide and reset the loading animation
				controls.enablePreMovieButtons(nana10PlayerData.embededPlayer); // enable the pre-movie buttons in the controls
			}
		}
		
		private function displayErrorMessage(msgURL:String):void
		{
			stillImage.loadImage(msgURL,true);
			stillImage.visible = true;
			screenCover.visible = loadingAnimation.visible = nana10Logo.visible = controls.visible = false;
			hideLoadingAnimation();
			if (shareButtons) shareButtons.visible = false;
		}
		
		protected function setM8PDelegate():void
		{
			cm8Delegate = new CM8PluginDelegate(cm8PlaceHolder,controls,loaderInfo.url);
			cm8Delegate.addEventListener(PluginEvent.VIDEO_WORKPLAN,onCM8DataReady);
			cm8Delegate.addEventListener(PluginEvent.AD_METADATA,onCM8AdReady);
			cm8Delegate.addEventListener(PluginEvent.AD_RESOLVE,onCM8AdReady);
			cm8Delegate.addEventListener(PluginEvent.AD_START,onCM8AdBegan);
			cm8Delegate.addEventListener(PluginEvent.AD_PROGRESS,onCM8AdProgress);
			cm8Delegate.addEventListener(PluginEvent.AD_COMPLETE,onCM8AdEnded);
			cm8Delegate.addEventListener(PluginEvent.WORKPLAN_COMPLETE,onCM8WorkplanComplete);
			cm8Delegate.addEventListener(PluginEvent.PLUGIN_LOADED,onCM8PluginLoaded);
			cm8Delegate.addEventListener(PluginEvent.PLUGIN_LOAD_ERROR,onCM8DataReady);
			cm8Delegate.addEventListener(PluginEvent.ERROR,onCM8DataReady);
			//cm8Delegate.addEventListener(PlayerEvent.DISABLE_CONTROLS,onCM8DisableControls);
			cm8Delegate.addEventListener(PlayerEvent.ENABLE_CONTROLS,onCM8EnableControls);
			cm8Delegate.addEventListener(PluginEvent.RESUME,onCM8resumed);
			cm8Delegate.loadPlugin();
			cm8AdLengthDict = new Dictionary();
			communicationLayer.cm8Deleage = cm8Delegate;
		}
		
		protected function onCM8PluginLoaded(event:PluginEvent):void
		{
			cm8Delegate.loadWorkplan();
			cm8WorkplanComplete = false;
		}		
				
		private function onLoadVideo(event:Nana10DataEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onLoadVideo");
			videoFile = event.videoFile ? event.videoFile : dataRepository.videoLink;
			loadVideo();
		}
			
		protected function loadVideo():void
		{
			Debugging.printToConsole("--Nana10Player.loadVideo");
			videoPlayer.source = videoFile + videoStart;//start;
			
			if (!isNaN(resetVolume)) videoPlayer.volume = resetVolume;
		}
				
		// the video meta-data is available			
		protected function onVideoDataReady(event:VideoPlayerEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onVideoDataReady");
			if (firstTime || nana10PlayerData.isLive) // first time main video is ready
			{
				firstTime = false;
				
				if (isNaN(communicationLayer.videoGrossDuration) || communicationLayer.videoGrossDuration == 0) communicationLayer.videoGrossDuration = videoPlayer.duration;
				if (isNaN(communicationLayer.videoNetDuration) || communicationLayer.videoNetDuration == 0) communicationLayer.videoNetDuration = videoPlayer.duration;
								
				// calculating the scene start offset...
				// since a video can playing only from a seek-point (internal keyframe), and the request can be to a time-code without
				// a seek-point, the video will actually start playing from the nearest previous seek-point, and this offset is calculated
				// here.
				// for example, the requested video should begin playing at 0:10, but thre's a seek-point only at 0:08.  so if the total
				// duration of the video is 1:00, the anticipated video length is 0:50, however the actuall video length will be 0:52.
				// by substracting one from the other, the offset is found to be -0:02. 
				communicationLayer.videoStartOffset = communicationLayer.videoStartPoint > 0 ? videoPlayer.duration - (dataRepository.videoDuration - communicationLayer.videoStartPoint) : 0;
				if (communicationLayer.videoStartPoint) nana10PlayerData.updateDataRepository(communicationLayer.videoStartPoint,0);// communicationLayer.videoStartOffset);
				
				// adding marker for preloading end-of-video data, 10 secs before the video ends
				var markerData:Nana10MarkerData = new Nana10MarkerData(0,Nana10ItemData.PRELOAD_END_OF_VIDEO);
				markerData.timeCode = communicationLayer.videoGrossDuration - 10;
				dataRepository.addItem(markerData);
				
				dataRepository.sortOnTimeCode();
				communicationLayer.videoStartPoint-=communicationLayer.videoStartOffset;
				videoPlayer.setSize(videoPlayer.height);
				if (!isNaN(videoPlayer.fps) && videoPlayer.fps > 12)
				{
					stage.frameRate = videoPlayer.fps;
				}
				// saving the original seekpoints array, for if/when seeking to an unloaded section of the video, this array is overwritten
				communicationLayer.videoSeekPointsArray = ArrayUtil.copyArray(videoPlayer.seekPoints);
			
				if (!nana10PlayerData.showAds || !cm8Delegate.isRunning)
				{	
					startPlayingVideo();
				}
				GemiusDelegate.setVideoData(externalParams.VideoID,communicationLayer.videoNetDuration,externalParams.ServiceID);
			}
			else if (seek) // meta-data is ready after a seek was preformed
			{
				seek = false;
				postPrerollVideoTime = NaN;
				// calculating the offset - same as 'sceneStartOffset'
				seekStartoffset = videoPlayer.duration - (dataRepository.videoDuration - (communicationLayer.videoStartPoint + seekToPoint));// - communicationLayer.videoStartOffset));
				communicationLayer.offset = seekStartoffset;
				communicationLayer.currentStartTime = seekToPoint;				
				controls.reset(seekToPoint - seekStartoffset - communicationLayer.scenesGaps);
				if (pausedBeforeSeek)
				{
					videoPlayer.pause();
					hideLoadingAnimation();
				}
				else if (cm8Delegate && !cm8Delegate.isRunning) 
				{
					if (seekStartoffset > 0 && !isNaN(seekSegmentOffset))
					{
						if (offsetTimer == null)
						{
							offsetTimer = new Timer(10);
						}
						else
						{
							offsetTimer.removeEventListener(TimerEvent.TIMER,startPlayingVideo);
						}
						showLoadingAnimation();
						videoPlayer.visible = false;
						controls.mouseChildren = false;
						if (isNaN(offsetVolume)) offsetVolume = videoPlayer.volume;
						videoPlayer.mute = true;
						offsetTimer.addEventListener(TimerEvent.TIMER,onSegmentSeekDelay);
						offsetTimer.start();
					}
					videoPlayer.play();
				}
				if (replayVideo) controls.resume();
				replayVideo = false;
				seekSegmentOffset = NaN;
			}
		}
		
		protected function startPlayingVideo():void
		{	
			Debugging.printToConsole("--Nana10Player.startPlayingVideo, videoStartOffset ",communicationLayer.videoStartOffset);
			videoPlayer.play();
			WatchedVideoData.addTiming(0);
			if (communicationLayer.videoStartOffset > 0)
			{
				if (offsetTimer == null)
				{
					offsetTimer = new Timer(10);
					offsetTimer.addEventListener(TimerEvent.TIMER,onOffsetTimer);
				}
				offsetTimer.start();
				stillImage.visible = true;
				showLoadingAnimation();
				if (controls) controls.mouseChildren = false;
				if (isNaN(offsetVolume)) offsetVolume = videoPlayer.volume;
				videoPlayer.mute = true;
			}
			else
			{
				displayVideo();	
			}
			if (nana10PlayerData.isLive)
			{
				if (videoPlayer.hasNetStream)
				{
					WatchedVideoData.startTimer();
					//if (nana10PlayerData.checkForLinkChange) CheckVideoLinkChange.init();
				}
				else
				{	// failed to load the stream - try again
					switchToAlternativeVideo(VideoPlayerEvent.NOT_FOUND);
					showLoadingAnimation();
				}
			}
			else
			{
				setDelayTimer();
			}
		}
		
		protected function displayVideo():void
		{
			Debugging.printToConsole("--Nana10Player.displayVideo",videoPlayer.bufferLoaded);
			if (!nana10PlayerData.embededPlayer)
			{
				try
				{
					ExternalInterface.call("MediAnd.OnPlay");					
				}
				catch (e:Error) {}
			}
			if (reportVideoWatched == false)
			{
				reportVideoWatched = true;
				try
				{
					var dataToReport:Object = ObjectUtil.clone(stage.loaderInfo.parameters);					
					for (var i:String in videoPlayer.videoInfo)
					{
						dataToReport[i] = videoPlayer.videoInfo[i];
					}
					ExternalInterface.call("MediAnd.reportVideoWatched",dataToReport);	
				}
				catch (e:Error) {}
			}
			;
			if (controls && !nana10PlayerData.isLive)
			{
				controls.start();
				controls.mouseChildren = true;
			}
			if (initiallyPaused)
			{ 
				videoPlayer.pause();
			}
			else
			{
				StatsManagers.updatePlayerStats(StatsManagers.MoviePlay,(nana10PlayerData.embededPlayer ? "Embed=True" : "Embed=False"));
			}			
			KeyboardShortcutsMangaer.allowAllKeybaordShortcuts = true;
			communicationLayer.enableSeek = true;
			hideLoadingAnimation();
			stillImage.visible = false;	
			if (!isNaN(offsetVolume))
			{
				videoPlayer.volume = offsetVolume;
				offsetVolume = NaN;
			}
			if (offsetTimer)
			{
				offsetTimer.stop();
			}
			if (nana10PlayerData.isLive)
			{
				GemiusDelegate.setVideoData(externalParams.VideoID,-1,externalParams.ServiceID);
				if (!videoPlayer.isPlaying) showLoadingAnimation()
			}
			GemiusDelegate.playing();			
		}
		
		private function onVideoStart(event:VideoPlayerEvent):void
		{	
			if (videoStarted) return;
			Debugging.printToConsole("--Nana10Player.onVideoStart");
			if (nana10PlayerData.isLive)
			{
				if (!cm8adRunning) startPlayingVideo();
			}
			//else
			//{
				StatsManagers.updatePlayerStats(StatsManagers.VideoInitLoadTime,String(getTimer() - videoLoadTime));
			//}	
			if (!videoInitialized) StatsManagers.updatePlayerStats(StatsManagers.VideoInit);
			if (adStrip) adStrip.removePreAdMessage();
			if (sendReport) sendReport.visible = false;
			if (videoLoadTime && videoLoadTimer.running) videoLoadTimer.stop();
			videoStarted = videoInitialized = true;
			hideLoadingAnimation();
		}
		
		private function setLoadTime(timeout:int = 10000):void
		{
			Debugging.printToConsole("--Nana10Player.setLoadTime",timeout/1000);
			if (videoLoadTimer == null)
			{
				videoLoadTimer = new Timer(timeout,1);
				videoLoadTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onVideoLoadTimeout);
			}
			else
			{
				videoLoadTimer.delay = timeout
				videoLoadTimer.reset();
			}
			StatsManagers.videoStartPoint = videoPlayer.source.indexOf("&start=") > -1 ? videoPlayer.source.split("&start=")[1] : "";
			videoLoadTime = getTimer();
			videoLoadTimer.start();
			videoStarted = false;
		}
		
		private function onVideoLoadTimeout(event:TimerEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onVideoLoadTimeout");
			StatsManagers.updatePlayerStats(StatsManagers.VideoInitLoadTimeout);
			switchToAlternativeVideo(VideoPlayerEvent.VIDEO_LOAD_TIMEOUT);
		}
		
		private function onOffsetTimer(event:TimerEvent):void
		{
			if (videoPlayer.playheadTime == 0) return;
			// have no idea why, but the delay shouldn't be based on the start-offset.  the start-offset can be either 3.5, 0.8 or 0.5 sec - 
			// i found out that in any case waiting for 1.3sec is the optimal delay.  should be more investigated, with more examples. 
			if (videoPlayer.playheadTime >= (communicationLayer.videoStartOffset))// > 0.5 ? 1.3 : communicationLayer.videoStartOffset))
			{
				//trace((getTimer() - tempTimer)/1000.0, stage.frameRate);
				displayVideo();
				offsetTimer.stop();
			}
		}
		
		protected function switchToAlternativeVideo(type:String):void
		{
			Debugging.printToConsole("--Nana10Player.switchToAlternativeVideo",type);
			if (!cm8adRunning) showLoadingAnimation();
			var newVideoFile:String = nana10PlayerData.alternateVideoURL;
			if (newVideoFile != null || (type == VideoPlayerEvent.BUFFER_EMPTY && nana10PlayerData.isLive == false) || (type == VideoPlayerEvent.VIDEO_LOAD_TIMEOUT && timeoutsCounter < 2))//(newVideoFile.indexOf("Error") == 0)
			{
				if (type == VideoPlayerEvent.VIDEO_LOAD_TIMEOUT || type == VideoPlayerEvent.BUFFER_EMPTY)
				{
					timeoutsCounter++;
					if (newVideoFile == null)
					{
						newVideoFile = videoFile;
						setLoadTime(20000*timeoutsCounter);
					}
					else
					{
						setLoadTime();
					}
				}
				else
				{
					setLoadTime();
				}
				videoFile = dataRepository.videoLink = newVideoFile;
				if (seek)
				{
					videoPlayer.source = videoFile + "&start=" + Math.round(seekToPoint + communicationLayer.videoStartPoint);
				}
				else
				{
					if (nana10PlayerData.isLive) videoPlayer.dispose();
					videoPlayer.source = videoFile + (communicationLayer.videoStartPoint || bufferingPlayheadTime ? "&start=" + (bufferingPlayheadTime + communicationLayer.videoStartPoint - communicationLayer.videoStartOffset) : "");
				}
				videoPlayer.pausedAtStart = false;
				videoPlayer.startLoading();
				return;
			}
			else if (nana10PlayerData.isLive)
			{				
				if (dataRepository.MediaStockVideoIDBackup)
				{	// in live stream originated from the CMS (not nile) - trying to switch to a backup stream
					liveStreamSwitch = true;
					dataRepository.reset();
					externalParams.MediaStockVideoItemGroupID = dataRepository.MediaStockVideoIDBackup.toString();
					dataRepository.resetMediaStockVideoIDBackup();
					nana10PlayerData.prepareData(false);
					nana10PlayerData.makeDataRequest();
					return;
				}
				else
				{
					//StatsManagers.updatePlayerStats(StatsManagers.LiveStreamFailure);
					//checkForZixi();
					//return;
					liveStreamSwitch = true;
					CastUpXMLParser.reset();
					nana10PlayerData.resetAlternateVideoIndex();
					nana10PlayerData.getVideoFile(externalParams.VideoLink + "&curettype=1");
					return;
				}
			}
			if (type != VideoPlayerEvent.VIDEO_LOAD_TIMEOUT)
			{
				//StatsManagers.updatePlayerStats(StatsManagers.GeneralError,"Error loading video file (Nana10Player.onSwitchToAlternateVideo)");				
				StatsManagers.updatePlayerStats(StatsManagers.VideoFailure);
				if (videoLoadTimer) videoLoadTimer.stop();
				onVideoNotFound(null);
			}			
		}
		
		private function checkForZixi():void
		{
			zixiDelegate = new ZixiDelegate();
			zixiDelegate.addEventListener(Nana10PlayerEvent.ZIXI_PROXY_FOUND,onZixiProxyFound);
			zixiDelegate.addEventListener(Nana10PlayerEvent.ZIXI_PROXY_MISSING,onZixiProxyMissing);
			zixiDelegate.isProxyInstalled();
		}
		
		private function onZixiProxyFound(event:Event):void
		{			
			videoPlayer.dispose(true);
			videoPlayer.source = dataRepository.videoLink = "http://127.0.0.1:4500/channel.flv?url=zixi://80.244.172.10/nana500";
		}
		
		private function onZixiProxyMissing(event:Nana10PlayerEvent):void
		{
			zixiDelegate.removeEventListener(Nana10PlayerEvent.ZIXI_PROXY_FOUND,onZixiProxyFound);
			zixiDelegate.removeEventListener(Nana10PlayerEvent.ZIXI_PROXY_MISSING,onZixiProxyMissing);			
			zixiDownloadWindow = new ZixiDownload();
			zixiDownloadWindow.addEventListener(Nana10PlayerEvent.ZIXI_CONTINUE,onDontInstallZixi);
			zixiDownloadWindow.addEventListener(Nana10PlayerEvent.ZIXI_PROXY_FOUND,onZixiProxyFound);
			addChild(zixiDownloadWindow);
			hideLoadingAnimation();
		}		
		
		private function onDontInstallZixi(event:Nana10PlayerEvent):void
		{
			showLoadingAnimation();
			videoPlayer.dispose(true);
			videoPlayer.source = dataRepository.videoLink = "http://80.244.172.10/nana500.flv?user=" + zixiDelegate.userData;
			videoPlayer.startLoading();
		}
		
		private function onStreamNotFound(event:VideoPlayerEvent):void
		{
			StatsManagers.updatePlayerStats(StatsManagers.VideoStreamNotFound);
			if (videoLoadTimer && videoLoadTimer.running) videoLoadTimer.stop();
			switchToAlternativeVideo(event.type);
		}
		
		private function onLivestreamFailure(event:VideoPlayerEvent):void
		{
			StatsManagers.updatePlayerStats(StatsManagers.LiveStreamFailure);
			switchToAlternativeVideo(event.type);
		}
		
		private function onVideoFinishedLoading(event:VideoPlayerEvent):void
		{
			if (nana10PlayerData.isLive) return;
			var speed:String = int(videoPlayer.loadingSpeed).toString()
			Debugging.printToConsole("--Nana10Player.onVideoFinishedLoading",speed);
			StatsManagers.updatePlayerStats(StatsManagers.VideoLoadSpeed,speed);
			StatsManagers.updatePlayerStats(StatsManagers.LoadComplete);
		}
		
		protected function playVideo():void
		{
			Debugging.printToConsole("--Nana10Player.onPlayVideo");
			showLoadingAnimation();
			if (nana10PlayerData.showAds && !nana10PlayerData.isLive)
			{
				cm8Delegate.videoStart();
			}
			canPlayVideo();
			report2Taboola();
			stage.addEventListener(MouseEvent.MOUSE_OUT,onHideControls);
		}
		
		// user clicked the play button in the controls
		private function onVideoPlayed(event:VideoControlsEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onVideoPlayed");
			if (firstTime && nana10PlayerData.autoPlay == false && (!nana10PlayerData.isLive || controls.playFirstClick) && (!nana10PlayerData.showAds || !cm8Delegate.isRunning))
			{				
				StatsManagers.updatePlayerStats(StatsManagers.ContentInit);
				showLoadingAnimation();
				playVideo();
				initiallyPaused = false;
			}
			else
			{
				screenCover.visible = false;
				adStrip.resume();
				endOfVideoDispaly.visible = false;
				if (communicationLayer.videoPlayer.playheadTime == 0 && seekToPoint == 0 && communicationLayer.state == CommunicationLayer.PLAYER)
				{ 
					showLoadingAnimation();
				}
				if (communicationLayer.videoPlayer == videoPlayer && communicationLayer.state == CommunicationLayer.PLAYER)
				{
					WatchedVideoData.startTimer();
					if (nana10PlayerData.isLive)
					{
						if (nana10PlayerData.checkForLinkChange) CheckVideoLinkChange.resume();
						//if (cm8Delegate) cm8Delegate.videoResumed();
					}
					if (cm8Delegate) cm8Delegate.revokeAd();
					GemiusDelegate.playing();
				}
				/*else*/ if (cm8Delegate && nana10PlayerData.showAds)
				{
					cm8Delegate.videoResumed();
				}
			}
		}
		
		// user clicked the pause buttons in the controls
		private function onVideoPaused(event:VideoControlsEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onVideoPaused");
			adStrip.pause();			
			if (communicationLayer.videoPlayer == videoPlayer && communicationLayer.state == CommunicationLayer.PLAYER) 
			{
				if (firstTime) initiallyPaused = true;
				if (nana10PlayerData.showAds && (resumeVideoWindow == null || resumeVideoWindow.visible == false))
				{
					if (cm8Delegate)
					{
						cm8Delegate.invokeAd();
					}
				}
				WatchedVideoData.pauseTimer();
				if (nana10PlayerData.isLive)
				{
					if (nana10PlayerData.checkForLinkChange) CheckVideoLinkChange.hold();
					//if (cm8Delegate) cm8Delegate.videoPaused();
				}
				GemiusDelegate.paused();
			}
			/*else*/ if (cm8Delegate && nana10PlayerData.showAds)
			{
				cm8Delegate.videoPaused();
			}
		}

		protected function onVideoEnded(event:VideoPlayerEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onVideoEnded");
			if (adBreak)
			{				
				videoPlayer.source = dataRepository.videoLink;				
				adBreak = false;
			}
			else
			{
				videoEnded();
			}
		}
				
		protected function onCM8DataReady(event:Event):void
		{
			if (event.type == PluginEvent.PLUGIN_LOAD_ERROR || event.type == PluginEvent.ERROR) cm8WorkplanComplete = true;
			if (!firstTime) return;
			Debugging.printToConsole("--Nana10Player.onCM8DataReady");
			if (nana10PlayerData.autoPlay)
			{
				if (!nana10PlayerData.isLive) controls.enablePreMovieButtons(nana10PlayerData.embededPlayer);
				StatsManagers.updatePlayerStats(StatsManagers.AutoPlay);
				playVideo();
			}
			else
			{
				hideLoadingAnimation();// hide and reset the loading animation
				controls.enablePreMovieButtons(nana10PlayerData.embededPlayer); // enable the pre-movie buttons in the controls
			}
		}
		
		// all meta-data is ready - video can be played
		protected function canPlayVideo():void
		{
			Debugging.printToConsole("--Nana10Player.canPlayVideo");

			if (nana10PlayerData.isLive && nana10PlayerData.checkForLinkChange)
			{
				CheckVideoLinkChange.init();					
			}				
			loadVideo();
			videoPlayer.startLoading();
			setLoadTime();
			if (cm8Delegate == null || (cm8Delegate && !cm8Delegate.isRunning)) videoPlayer.pausedAtStart = false;
			if (!liveStreamSwitch) controls.play(false);
			liveStreamSwitch = false;
			screenCover.visible = false;
		}		
				
		public function set screenCoverVisible(value:Boolean):void
		{
			screenCover.visible = value;
		}
				
		// playhead reached a keyframe
		protected function onReachedKeyframe(event:VideoPlayerEvent):void
		{
			var itemData:Nana10MarkerData = dataRepository.getItemByIndex(event.frameIndex);
			Debugging.printToConsole("--Nana10Player.onReachedKeyframe",itemData.typeName,StringUtils.turnNumberToTime(communicationLayer.playheadTime));						
			switch (itemData.type)
			{
				case Nana10ItemData.MARKER:					
					break;
				case Nana10ItemData.SEGMENT_END:
					var nextSegment:Nana10MarkerData = dataRepository.getItemById((itemData as Nana10SegmentEndData).nextSegmentID);
					if (nextSegment)
					{
						Debugging.printToConsole(videoPlayer.playheadTime);
						communicationLayer.scenesGaps+= nextSegment.timeCode - itemData.timeCode;
						seekSegmentOffset = nextSegment.timeCode;
						communicationLayer.seek(nextSegment.timeCode);
						communicationLayer.currentSegmentId = nextSegment.id;
					}
					break;
				case Nana10ItemData.VIDEO_END:
					videoPlayer.pause();
					videoEnded();
					break;
				case Nana10ItemData.PRELOAD_END_OF_VIDEO:
					endOfVideoDispaly.loadData();
					break;
			}
		}
		
		protected function removeViewedAd(index:int):void
		{
			var removed:int = 1;
			dataRepository.removeItemByIndex(index);
			// also removing its preload and pre-ad items
			for (var i:int = index-1; i > 0; i--)
			{
				if (dataRepository.getItemByIndex(i).type == Nana10ItemData.PRE_AD)
				{
					dataRepository.removeItemByIndex(i);
					removed++;
					index--;
				}
				else if (dataRepository.getItemByIndex(i).type == Nana10ItemData.PRELOAD_AD)
				{
					dataRepository.removeItemByIndex(i);
					removed++;
					break;
				}
			}
			controls.updateCurrentItemIndex(removed);
		}
		
		protected function onVolumeChanged(event:VideoControlsEvent):void
		{
			videoPlayer.volume = event.volumeLevel;			 
			if (cm8Delegate)
			{
				cm8Delegate.volumeChanged(event.volumeLevel);
			}				
		}
		
		protected function onCM8AdReady(event:PluginEvent):void
		{
			var adLength:Number = event.type == PluginEvent.AD_METADATA ? event.data.adData.duration as Number : event.data.duration as Number;
			if (adLength > 0)
			{
				//cm8AdLength = adLength;
				// this is for cases where there's more than one ad during the break.  in such cases the onReady event can take place not in the same order as the onBegan event.
				// thus, writing the length into a dictionary object, where the key is the ad's id, so when the ad is display, knowing its length according to its id.
				// however, in many cases the ad doesn't have id, so this mechanism fails.  solution should come from CM8 support.
				cm8AdLengthDict[event.data.id] = adLength;
				Debugging.printToConsole("Nana10Player.onCM8AdReady " + StringUtils.turnNumberToTime(communicationLayer.playheadTime), adLength,event.data.id);
				if (videoPlayer.playheadTime > CommunicationLayer.SECS_BEFORE_AD_MESSAGE && adStrip != null && nana10PlayerData.isLive == false) adStrip.displayPreAdMessage(adLength);
				if (communicationLayer.playheadTime < 1) cm8HasPreroll = true;
				communicationLayer.enableSeek = false;
			}
		}
		
		protected function onCM8AdBegan(event:PluginEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onCM8AdBegan", StringUtils.turnNumberToTime(communicationLayer.playheadTime),cm8HasPreroll,cm8Postroll, event.data.isLinear,event.data.id);
			cm8LinearAd = event.data.isLinear;
			if (event.data.isLinear)
			{
				communicationLayer.state = CommunicationLayer.MIDROLL;
				hideLoadingAnimation();
				
				if (!cm8HasPreroll && !cm8Postroll && communicationLayer.playheadTime > 30 && !nana10PlayerData.isLive)
				{
					WatchedVideoData.pauseTimer();
					if (!isNaN(seekToPoint) && seekToPoint + communicationLayer.videoStartPoint + 10 < communicationLayer.playheadTime)
					{
						videoPlayer.gotoFrame(videoPlayer.playheadTime - 5); // going back 5 secs, though not after seek
					}
					StatsManagers.updatePlayerStats(StatsManagers.MoviePause);
					StatsManagers.updatePlayerStats(StatsManagers.MidRollPlay);
				}
				else if (cm8HasPreroll)
				{
					if (delayedStartTimer && delayedStartTimer.running) delayedStartTimer.stop();
					StatsManagers.updatePlayerStats(StatsManagers.PreRollPlay);
				}
				if (videoPlayer.isPlaying) videoPlayer.pause();
				cm8adRunning = true;
				cm8CurrentAdID = event.data.id;
				
				var adLength:Number = cm8AdLengthDict[cm8CurrentAdID];
				if (!isNaN(adLength) && (!nana10PlayerData.isLive || cm8HasPreroll)) controls.hold(adLength);
				//if (!isNaN(cm8AdLength)) controls.hold(cm8AdLength);
				//controls.holdTimer();
				adStrip.removePreAdMessage();
				bugReportingRightClick.visible = false;
				if (cm8HasPreroll) videoPlayer.pausedAtStart = true;
				if (shareButtons) shareButtons.visible = false;
			}
			else
			{
				if (bugReportingRightClick) bugReportingRightClick.visible = false;
			}
		}
		
		protected function onCM8AdProgress(event:PluginEvent):void
		{			
			if ((!isNaN(event.data as Number) && (event.data as Number) < 0) || !cm8adRunning || (nana10PlayerData.isLive && !cm8HasPreroll)) return;
			var adLength:Number = cm8AdLengthDict[cm8CurrentAdID];
			if (isNaN(adLength))
			{
				adLength = event.data as Number;
				if (adLength > 2 && (!nana10PlayerData.isLive || cm8HasPreroll)) controls.hold(adLength);
			}
			if (adLength >= 0) controls.setCurrentTime(event.data as Number);			
		}
		
		private function onCM8resumed(event:PluginEvent):void
		{
			if (videoStarted && firstTime)
			{
				startPlayingVideo();
			}	
		}
		
		protected function onCM8DisableControls(event:PlayerEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onCM8DisableControls");
			var adLength:Number = cm8AdLengthDict[cm8CurrentAdID];
			if (!isNaN(adLength) && (!nana10PlayerData.isLive || cm8HasPreroll)) controls.hold(adLength);
			//if (!isNaN(cm8AdLength)) controls.hold(cm8AdLength);
			//controls.holdTimer();
			adStrip.removePreAdMessage();
			bugReportingRightClick.visible = false;
			if (cm8HasPreroll) videoPlayer.pausedAtStart = true;
			if (shareButtons) shareButtons.visible = false;
		}
		
		protected function onCM8EnableControls(event:PlayerEvent):void
		{
			if (cm8LinearAd == false) return;
			Debugging.printToConsole("--Nana10Player.onCM8EnableControls");
			if (videoNotFound)
			{
				if (adStrip) adStrip.error("שגיאה בטעינת המידע",false);
				reportBug();			
				hideLoadingAnimation();
				return;
			}	
			if (videoStarted && !videoAlreadyEnded)
			{
				controls.resume();
				if (shareButtons) shareButtons.visible = true;
				communicationLayer.enableSeek = true;
				if (!cm8adRunning) startPlayingVideo();
			}
			
			//controls.resumeTimer();
		}
		
		protected function onCM8AdEnded(event:PluginEvent):void
		{
			if (cm8LinearAd == false) return;
			Debugging.printToConsole("--Nana10Player.onCM8AdEnded");
			communicationLayer.state = CommunicationLayer.PLAYER;
			if (controls && nana10PlayerData.isLive == false) controls.resumeTimer();
			cm8AdLength = NaN;
			if (cm8Postroll)
			{
				//cm8Postroll = false;
				videoAlreadyEnded = false;
				videoEnded();
				return;
			}
			else if (cm8HasPreroll)// && delayedStartTimer)
			{
				if (videoNotFound)
				{	// while the preroll was playing - there was an error loading the content
					if (adStrip) adStrip.error("שגיאה בטעינת המידע",false);
					reportBug();			
					hideLoadingAnimation();
					return;
				}				
				//if (controls) controls.start();
				//delayedStartTimer.start();
				if (videoStarted)
				{
					startPlayingVideo();
				}
				else
				{
					showLoadingAnimation();
				}
				if (nana10PlayerData.isLive && controls) controls.resume();
			}
			else if (nana10PlayerData.isLive)
			{
				//startPlayingVideo();
			}
			else
			{
				WatchedVideoData.startTimer();
				if (controls) controls.resume();
				if (!videoPlayer.isPlaying) videoPlayer.play();
				communicationLayer.enableSeek = true;
			}
			if (bugReportingRightClick) bugReportingRightClick.visible = true;
			cm8HasPreroll = cm8adRunning = false;
			cm8AdLengthDict[cm8CurrentAdID] = null;
			cm8CurrentAdID = 0;
			//commentsControls.visible = true;
		}	
		
		private function onCM8WorkplanComplete(event:Event):void
		{
			Debugging.printToConsole("--Nana10Player.onCM8WorkplanComplete",videoPlayer.playheadTime);
			cm8WorkplanComplete = true;
			if (cm8Postroll)
			{
				videoAlreadyEnded = false;
				videoEnded();
			}
		}
		
		// when a commercials break begins or end during live stream - a net-status event is thrown, thus notifing cm8 plugin to start or end ads' break inside the player
		private function onReachedQuePoint(event:VideoPlayerEvent):void
		{
			if (nana10PlayerData.isLive)
			{
				if (event.cuePointData.parameters.LiveAdsBreak == "AdBreakStart" && videoPlayer.isPlaying)
				{
					cm8Delegate.reachedCuePoint(1000);
				}
				else if (event.cuePointData.parameters.LiveAdsBreak == "AdBreakStop" && !cm8HasPreroll)
				{	// terminating the ad break, unless during preroll
					cm8Delegate.terminateRunningAds();
				}
			}
		}

		private function setDelayTimer():void
		{
			if (delayedStartTimer == null)
			{
				delayedStartTimer = new Timer(500);
				delayedStartTimer.addEventListener(TimerEvent.TIMER, checkVideoBegan);
				showLoadingAnimation();
			}
			delayedStartTimer.start();
			communicationLayer.enableSeek = false;
		}
		
		// for unknown reason - sometimes when the pre-roll ends the video won't start playing. so after the pre-roll ended, waiting for half a second
		// and if the video hasn't started to play by then (although it began downloading) - moving it 0.1 second forward
		private function checkVideoBegan(event:TimerEvent):void
		{
			if (cm8adRunning) return;
			Debugging.printToConsole("--Nana10Player.checkVideoBegan. loading speed (Kb/sec):" + videoPlayer.loadingSpeed, "buffer loaded (%):" + Math.round(videoPlayer.bufferLoaded));
			if (videoPlayer.playheadTime > 0.1)
			{ 
				if (isNaN(postPrerollVideoTime))
				{					
					Debugging.printToConsole("checkVideoBegan - clear to go. (is video playing - "+videoPlayer.isPlaying+")",videoPlayer.playheadTime);
					/*if (videoPlayer.isPlaying == false)*/ videoPlayer.play();					
					postPrerollVideoTime = videoPlayer.playheadTime;
					dataRepository.sortOnTimeCode();
				}
				else if (videoPlayer.playheadTime > postPrerollVideoTime + 0.4)
				{
					Debugging.printToConsole("playheadTime:", videoPlayer.playheadTime, "postPrerollVideoTime:", postPrerollVideoTime);
					delayedStartTimer.stop();
					if (offsetTimer == null || offsetTimer.running == false)
					{
						hideLoadingAnimation();
					}
					communicationLayer.enableSeek = true;
					WatchedVideoData.startTimer();
					checkForResume();
				}
				else
				{
					videoPlayer.gotoFrame(postPrerollVideoTime + 0.1);
					delayedStartTimer.stop();
					hideLoadingAnimation();
					WatchedVideoData.startTimer();
					communicationLayer.enableSeek = true;
					Debugging.printToConsole("was double stuck!")
					checkForResume();
				}
			}
			else if (videoPlayer.howMuchLoaded > 0)
			{
				Debugging.printToConsole("was stuck!",stuckDelta, "loaded - ",videoPlayer.howMuchLoaded);
				showLoadingAnimation(false);
				if (videoPlayer.bufferLoaded == 100 && nana10PlayerData.isLive == false)
				{
					videoPlayer.gotoFrame(0.1 + stuckDelta);
					stuckDelta+=0.1
				}
			}
		}
		
		private function checkForResume():void
		{	
			if (runCheckForResume)
			{
				try
				{
					var so:SharedObject = SharedObject.getLocal("lt_" + externalParams.VideoID);
					Debugging.printToConsole("--Nana10Player.checkForResume",so.data.lt);
					if (so.data.lt && so.data.lt < communicationLayer.videoNetDuration - 120 && so.data.lt > 20)
					{	// prompting the user to resume from the last time-code, in case it was more than 20 seconds, or more than 2 minutes before its end
						resumeVideoWindow = new ResumeVideoWindow(so.data.lt);
						resumeVideoWindow.addEventListener(Nana10PlayerEvent.RESUME_FROM_START,onResumeFromStart);
						resumeVideoWindow.addEventListener(Nana10PlayerEvent.RESUME_FROM_LAST,onResumeFromLast);
						controls.pause();
						addChild(resumeVideoWindow);
					}
				}
				catch (e:Error) 
				{
					Debugging.printToConsole("--Nana10Player.checkForResume - error",e.message);	
				};
				runCheckForResume = false;
			}
		}
		
		private function onResumeFromLast(event:Nana10PlayerEvent):void
		{
			var lastTimecode:Number = SharedObject.getLocal("lt_" + externalParams.VideoID).data.lt;
			WatchedVideoData.closeTiming(communicationLayer.playheadTime);
			WatchedVideoData.addTiming(lastTimecode);
			onResumeFromStart(null);
			communicationLayer.seek(lastTimecode);
		}
		
		private function onResumeFromStart(event:Nana10PlayerEvent):void
		{
			controls.play(false);
			onVideoPlayed(null);
		}		
				
		protected function videoEnded(resume:Boolean = false):void
		{
			if (videoAlreadyEnded) return;
			Debugging.printToConsole("--Nana10Player.videoEnded");		
			videoAlreadyEnded = true;
			var duration:Number = communicationLayer.videoNetDuration;
			if (nana10PlayerData.showAds)
			{
				if (cm8Delegate && !cm8WorkplanComplete)
				{
					cm8Postroll = true;
					cm8Delegate.videoEnded();
					return;
				}
			}
			cm8Postroll = false;
			if (adStrip.visible && adStrip.alpha == 1) adStrip.fadeOut();
			if (resume) controls.resume();
			controls.videoEnded();
			hideLoadingAnimation();
			// fade-in the screen-cover
			screenCover.visible = true;
			screenCover.alpha = 0;
			TweenLite.to(screenCover,0.5,{alpha: 0.2});
			WatchedVideoData.pauseTimer();	
			try
			{
				StatsManagers.updatePlayerStats(StatsManagers.KeepAlive,(WatchedVideoData.getTotalTiming()*1000).toString());
			}
			catch (e:Error) {};
			StatsManagers.updatePlayerStats(StatsManagers.MovieEnd);//.movieEnded();			
			// move to next video automatically (except for certain PR content)
			/*if (externalParams.VideoID == 160290)
			{
				onSeek(new VideoControlsEvent(VideoControlsEvent.GO_TO_FRAME,0));
			}
			else*/ if (dataRepository.previewGroupID == 0 && externalParams.CategoryID != 500485 && externalParams.CategoryID != 500487 && externalParams.ArticleID != 932714)
			{
				endOfVideoDispaly.visible = true;
				controls.visible = false;				
			}
			GemiusDelegate.complete();
			try {
				ExternalInterface.call("MediAnd.taboola_videoEnded");
			}
			catch (e:Error)
			{
				Debugging.printToConsole("error calling JS function taboola_videoEnded",e.message);
			}
		}
		
		// user dragged the playehead/clicked the arrow buttons
		private function onSeek(event:VideoControlsEvent):void
		{
			Debugging.printToConsole("--Nana10Player.onSeek");
			endOfVideoDispaly.visible = adStrip.visible = false;
			screenCover.visible = false;
			controls.closeAllPannel();
			videoAlreadyEnded = false;

			var timeCode:Number = event.timeCode + communicationLayer.videoStartOffset;
			if (((timeCode - communicationLayer.currentStartTime) / (communicationLayer.videoGrossDuration - communicationLayer.currentStartTime) > videoPlayer.howMuchLoaded || 
				  timeCode < communicationLayer.currentStartTime) && 
				  (videoFile != null && (videoFile.indexOf(".flvs") > -1 || videoFile.indexOf(".mp4") > -1)) || firstTime)
			{   // requested time-code wasn't loaded yet - send a request to the server
				doSeek(timeCode);
			}
			else
			{  // requested time-code is loaded - jump to that point
				videoPlayer.gotoFrame(timeCode - communicationLayer.currentStartTime);
				loadingAnimation.visible = videoPlayer.isPlaying;
				loadingAnimation.visible ? loadingAnimation.play() : loadingAnimation.stop();
				if (replayVideo || event.videoEnded)
				{
					controls.resume();
					videoPlayer.play();
				}
				replayVideo = false;				
			}
		}
		
		// making a seek-request to the server
		private function doSeek(timeCode:Number):void
		{
			Debugging.printToConsole("--Nana10Player.doSeek");
			seek = true;
			pausedBeforeSeek = !videoPlayer.isPlaying && !endOfVideoDispaly.visible && !replayVideo;
			//videoPlayer.pause();
			videoPlayer.toggleCover(true);
			//seekSegmentOffset = timeCode - communicationLayer.videoStartOffset //+ communicationLayer.videoStartPoint
			videoPlayer.source = videoFile + "&start=" + Math.round(timeCode + communicationLayer.videoStartPoint);// - communicationLayer.videoStartOffset);
			videoPlayer.startLoading();
			setLoadTime();
			communicationLayer.currentStartTime = seekToPoint = timeCode;
			showLoadingAnimation();
			
			controls.loadingVideo = true;
		}
		
		// seek action is complete and/or video buffer is full
		protected function onSeekComplete(event:VideoPlayerEvent):void
		{		
			Debugging.printToConsole("--Nana10Player.onSeekComplete");
			videoPlayer.toggleCover(false);	
			if (sendReport && nana10PlayerData.isLive) sendReport.visible = false; // in case the live stream resumes - remove the 'sendReport' windoe
			if (offsetTimer == null || offsetTimer.running == false)
			{
				loadingAnimation.visible = stillImage.visible = false;
				loadingAnimation.stop();
			}
			if (communicationLayer.videoPlayer == videoPlayer) 
			{
				if (!isNaN(seekSegmentOffset) && seekSegmentOffset - videoPlayer.getRelativePrevSeekPoint(seekSegmentOffset) + communicationLayer.currentStartTime > 0.1 && cm8Delegate.isRunning == false)
				{	// this condition is for cases where there a delta (of at least 0.1sec) between the time-code which was seeked and the one actually reached.
					// in such cases - wait till the playhead reaches the desired timecode (by using a timer)
					seekStartoffset = seekSegmentOffset - (videoPlayer.getRelativePrevSeekPoint(seekSegmentOffset) + communicationLayer.currentStartTime);
					onSegmentSeekDelay();
					seekSegmentOffset = NaN;
				}
				controls.loadingVideo = false;			
				//isBuffering = false;
				communicationLayer.enableSeek = true;
			}	
			if (nana10PlayerData.isLive)
			{
				controls.start();
				controls.mouseChildren = true;
				if	(nana10PlayerData.showAds && cm8Delegate) cm8Delegate.videoStart();
				adStrip.visible = false;
				if (zixiDownloadWindow) zixiDownloadWindow.clear();
			}
			GemiusDelegate.playing(true);
			if (buffering) WatchedVideoData.startTimer();
			buffering = false;
			if (bufferTimer && bufferTimer.running) bufferTimer.stop();
		}
		
		protected function onSegmentSeekDelay(event:TimerEvent = null):void
		{
			if (event)
			{
				var currentTime:int = getTimer();
				if (offsetTimeCounter == 0)
				{
					offsetTimeCounter = currentTime;
				}
				else if (currentTime - offsetTimeCounter > seekStartoffset * 1000)
				{
					videoPlayer.visible = true;
					videoPlayer.volume = offsetVolume;
					offsetVolume = NaN;
					offsetTimeCounter = 0;
					offsetTimer.stop();	
					loadingAnimation.visible = stillImage.visible = false;
					loadingAnimation.stop();
					if (controls)
					{
						controls.mouseChildren = true;
						controls.resumeTimer();
					}
				}
			}
			else
			{
				Debugging.printToConsole("--Nana10Player.onSegemtnSeekDelay");
				if (offsetTimer == null)
				{
					offsetTimer = new Timer(10);
				}
				else
				{
					offsetTimer.removeEventListener(TimerEvent.TIMER,onOffsetTimer);
				}
				offsetTimer.addEventListener(TimerEvent.TIMER,onSegmentSeekDelay);
				offsetTimeCounter = 0;
				offsetTimer.start();
				showLoadingAnimation();
				videoPlayer.visible = false;
				if (controls)
				{
					controls.mouseChildren = false;
					controls.holdTimer();
				}
				stillImage.visible = true;				
				if (isNaN(offsetVolume)) offsetVolume = videoPlayer.volume;
				videoPlayer.mute = true;
				videoPlayer.play();
			}
		}
		
		// toggling video's quality		
		private function onSwitchQuality(event:Nana10PlayerEvent):void
		{		
			Debugging.printToConsole("--Nana10Player.onSwitchQuality");
			adStrip.visible = false;
			if (event.type == Nana10PlayerEvent.SWITCH_QUALITY_HIGH)
			{	
				if (nana10PlayerData.hqAvailable)
				{
					if (CastUpXMLParser.hqVideo == null)
					{	// first time the user clicked the HQ button - requesting the HQ data from the server
						if (hqDataLoader == null)
						{
							hqDataLoader = new HQDataLoader();
							hqDataLoader.addEventListener(Event.COMPLETE, onHQDataReady);
							hqDataLoader.addEventListener(IOErrorEvent.IO_ERROR, onHQDataError);
						}
						hqDataLoader.loadHQData();
						showLoadingAnimation();
						return;
					}
					else
					{
						showHQVideo();
					}
				}
			}
			else
			{
				if (videoFileNormal != null) videoFile = videoFileNormal;
				videoPlayer.isHQ = nana10PlayerData.showHQ = false;
				videoPlayer.smoothing = nana10PlayerData.smoothing; // smoothing in LQ is set from the FlashVars
				
			}
			if (firstTime || endOfVideoDispaly.visible)
			{	// making the switch before the video begins playing or after its done
				videoPlayer.source = videoFile + videoStart;
				setLoadTime();
			}
			else
			{
				doSeek(communicationLayer.playheadTime);
			}
		}
		
		protected function onHQDataReady(event:Event):void
		{
			Debugging.printToConsole("--Nana10Player.onHQDataReady");
			showHQVideo();
			if (nana10PlayerData.startWithHQ)
			{
				nana10PlayerData.startWithHQ = false;
			} 
			else if (firstTime || endOfVideoDispaly.visible)
			{	// making the switch before the video begins playing or after its done
				videoPlayer.source = videoFile + videoStart;//(communicationLayer.videoStartPoint ? "&start=" + communicationLayer.videoStartPoint : "");
				setLoadTime();
				hideLoadingAnimation();
			}
			else
			{
				doSeek(communicationLayer.playheadTime + communicationLayer.scenesGaps);
			}
		}
		
		protected function onHQDataError(event:IOErrorEvent):void
		{
			adStrip.error("שגיאה בטעינת המידע");
			reportBug();
			controls.resetHQ();
			hideLoadingAnimation();
		}
		
		protected function showHQVideo():void
		{
			Debugging.printToConsole("--Nana10Player.showHQVideo");
			videoFileNormal =  videoFile;
			videoFile = CastUpXMLParser.hqVideo;
			videoPlayer.isHQ = nana10PlayerData.showHQ = true;
			videoPlayer.smoothing = true; // smoothing is always on on HQ videos
		}
				
		protected function onVideoBufferEmpty(event:VideoPlayerEvent):void			
		{	// video is buffering, at least 500ms before the video's end
			Debugging.printToConsole("--Nana10Player.onVideoBufferEmpty",bufferEvents);
			if (nana10PlayerData.isLive || (event.target as Nana10VideoPlayer).playheadTime + 0.5 < (event.target as Nana10VideoPlayer).duration)
			{
				if (communicationLayer.videoPlayer == videoPlayer)
				{					
					//isBuffering = true;
					// sending an error message to the server
					StatsManagers.updatePlayerStats(StatsManagers.BufferEmpty);
					communicationLayer.enableSeek = false;
					bufferEvents++;
					if (bufferEvents > 5)
					{
						onBufferTimer(null);
					}
					else
					{
						if (bufferTimer == null)
						{
							bufferTimer = new Timer(20000,1);
							bufferTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onBufferTimer);
						}
						bufferTimer.reset();
						bufferTimer.start();
					}
					if (nana10PlayerData.showAds == false || (cm8Delegate && !cm8Delegate.isRunning)) showLoadingAnimation();
					WatchedVideoData.pauseTimer();
					buffering = true;
				}
			}
			GemiusDelegate.buffering();			
		}
		
		// updating the loading animation's message
		protected function onVideoBuffering(event:VideoPlayerEvent):void
		{
			if (isNaN(event.bufferLoaded) == false)
			{
				loadingAnimation.progress_txt.text = Math.round(event.bufferLoaded) + "%";
			}
		}
		
		private function onBufferTimer(event:TimerEvent):void
		{
			bufferEvents = 0;
			if (!nana10PlayerData.isLive)
			{
				seekToPoint = communicationLayer.playheadTime;
				seek = true;
			}
			switchToAlternativeVideo(VideoPlayerEvent.BUFFER_EMPTY);
		}
		
		// after video has ended - other video was selected in the end-of-video window
		protected function onReplaceVideo(event:Nana10PlayerEvent):void
		{
			Debugging.printToConsole("--onReplaceVideo", event.videoId, event.articleId);
			GemiusDelegate.closeStream();
			var currentSessionID:String = externalParams.SessionID;
			var environment:String = externalParams.Environment;
			externalParams.reset();
			externalParams.VideoID = event.videoId;
			externalParams.ArticleID = event.articleId;
			externalParams.SessionID = currentSessionID;
			externalParams.Environment = environment;
			if (endOfVideoDispaly) endOfVideoDispaly.visible = false;
			
			videoPlayer.dispose();
			screenCover.alpha = 1;
			showLoadingAnimation();
			dataRepository.reset();
			CastUpXMLParser.reset();
			communicationLayer.reset();
			if (controls)
			{
				controls.resetTimer();
				controls.visible = true;
				controls.mouseChildren = false;
			}
			nana10PlayerData.reset();
			firstTime = true;
			resetVolume = videoPlayer.volume;
			seekToPoint = seekStartoffset = timeoutsCounter = bufferEvents = 0;
			videoAlreadyEnded = reportVideoWatched = videoStarted = runCheckForResume = videoInitialized = false;
			postPrerollVideoTime = NaN;
			WatchedVideoData.init(false);
			nana10PlayerData.resetAlternateVideoIndex();
			StatsManagers.reset(loaderInfo.url.indexOf("localhost") > -1 || loaderInfo.url.indexOf("file://") > -1 || StringUtils.isStringEmpty(externalParams.Environment) == false);
			StatsManagers.updatePlayerStats(StatsManagers.ContentInit);
			nana10PlayerData.prepareData(false);
		}
		
		private function onEndOfVideoError(event:Nana10PlayerEvent):void
		{
			controls.mouseChildren = controls.visible = true;
			controls.showControls();
			endOfVideoDispaly.visible = false;
		}
		
		// after the video ended - user selects to re-play it
		private function onResetVideo(event:Nana10PlayerEvent):void
		{
			StatsManagers.updatePlayerStats(StatsManagers.PlayClick);
			controls.play();
		}
		
		protected function get videoStart():String
		{
			return communicationLayer.videoStartPoint ? "&start=" + communicationLayer.videoStartPoint : "";
		}
		
		protected function hideLoadingAnimation():void
		{
			loadingAnimation.visible = false;
			loadingAnimation.stop();
			loadingAnimation.progress_txt.text = "";
		}
		
		protected function showLoadingAnimation(resetText:Boolean = true):void
		{
			if (cm8adRunning) return;
			loadingAnimation.visible = true;
			loadingAnimation.play();
			if (resetText) loadingAnimation.progress_txt.text = "";
		}
		
		// stage's display state is toggled
		private function onDisplayStateChanged(event:FullScreenEvent):void
		{
			Debugging.printToConsole("--Nana10player.onDisplayStateChanged");
			//controls.y =  stage.stageHeight - 56;//controls.bg.height;
			controls.onDisplayStateChanged(event);
			DisplayUtils.spacialAlign(stage,controls,DisplayUtils.CENTER,0,DisplayUtils.BOTTOM,(event.fullScreen ? 26 : 36));
			//Debugging.firebug(controls.x,stage.stageWidth,controls.width);
			background.width = stage.stageWidth + 3;
			videoPlayer.width = stage.stageWidth;
			background.height = stage.stageHeight// - (event.fullScreen ? -2 : 30);
			videoPlayer.height = stage.stageHeight - (event.fullScreen ? 0 : 30);						
			videoPlayer.onDisplayStateChanged(event);

			adStrip.fullScreenToggle();
			screenCover.width = videoPlayer.width
			screenCover.height = videoPlayer.height;
			DisplayUtils.spacialAlign(stage,nana10Logo,DisplayUtils.RIGHT,3,DisplayUtils.TOP,3);
			if (stillImage.visible)
			{
				DisplayUtils.resize(stillImage,videoPlayer.width,videoPlayer.height,true,true,true);
				if (event.fullScreen == false) stillImage.x = stillImage.y = 0;
			}
			else
			{
				stillImage.setDimensions(videoPlayer.width,videoPlayer.height);
			}			
			endOfVideoDispaly.height = videoPlayer.height;
			DisplayUtils.align(videoPlayer,loadingAnimation);			
			bugReportingRightClick.x = videoPlayer.x;
			bugReportingRightClick.y = videoPlayer.y;
			bugReportingRightClick.width = videoPlayer.width;
			bugReportingRightClick.height = videoPlayer.height;
			if (bugReporting) DisplayUtils.align(stage,bugReporting);
			if (cm8Delegate)
			{
				try
				{
					cm8Delegate.videoResize(event.fullScreen);
				}
				catch (e:Error)
				{
					Debugging.printToConsole("error resizing CM8 plugin",e.message);
				}
			}
			if (shareWindow) DisplayUtils.align(videoPlayer,shareWindow);
			bottomBanner.visible = event.fullScreen == false;
		}

		private function onDoubleClickVideo(event:MouseEvent):void
		{
			Debugging.printToConsole("--UserAction: DoubleClicked video",StringUtils.turnNumberToTime(communicationLayer.playheadTime,true,true,true));
			controls.onToggleFullscreen();
		}
		
		private function onClickVideo(event:MouseEvent):void
		{
			if (communicationLayer.videoPlayer == videoPlayer)
			{
				Debugging.printToConsole("--UserAction: clicked videoPlayer",StringUtils.turnNumberToTime(communicationLayer.playheadTime,true,true,true));
				if (videoPlayer.isPlaying) controls.pause();
				navigateToURL(new URLRequest(unescape(externalParams.ShareLink)),"_blank");
			}
		}
		
		private function onClickAd(event:MouseEvent):void
		{
			return;
			if (nana10PlayerData.isLive && Capabilities.os.indexOf("Mac") != 0)
			{	// disabled on MAC, so its right-click isn't blocked
				navigateToURL(new URLRequest("http://213.8.137.51/Erate/LinkTo.asp?sTool=WATMBI&sType=2&URL=https://www.facebook.com/seretseret/app_440337806006705"),"_blank");
				var dr:DataRequest = new DataRequest();
				dr.load("http://213.8.137.51/Erate/EventReportQuery.asp?ToolId=WATMBI&EventType=2");
			}
		}
		
		private function onAdSenseClicked():void
		{
			if (videoPlayer.isPlaying) controls.pause();
		}
		
		private function onGetLoadingSpeed(event:Nana10PlayerEvent):void
		{
			controls.displayLoadingSpeed();
		}
		
		private function onHideShare(event:Nana10PlayerEvent):void
		{
			TweenLite.to(shareButtons,0.5,{alpha: 0});	
		}
		
		private function onShowShare(event:Nana10PlayerEvent):void
		{
			TweenLite.to(shareButtons,0.5,{alpha: 1});
		}
		
		private function onHideControls(event:MouseEvent):void
		{
			if (event.relatedObject == null) controls.hide();
		}
		
		private function onOpenShareWindow(event:Nana10PlayerEvent):void
		{
			shareWindow.visible = true;
		}
		
		// opening the bug reporting form
		private function onOpenBugReporting(event:Event):void
		{
			if (bugReporting == null)
			{
				bugReporting = new BugReporting();
				DisplayUtils.align(stage,bugReporting);
				bugReporting.addEventListener(Nana10PlayerEvent.GET_LOADING_SPEED,onGetLoadingSpeed);
			}
			if (event.type == Nana10PlayerEvent.SEND_BUG_REPORT && (event as Nana10PlayerEvent).hiddenReport)
			{
				bugReporting.sendReport((event as Nana10PlayerEvent).bugReportData);	
			}
			else
			{
				addChild(bugReporting);
				bugReporting.init();
				if (stage.displayState == StageDisplayState.FULL_SCREEN) stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		protected function reportBug():void
		{
			if (sendReport == null)
			{
				sendReport = new SendReport();
				DisplayUtils.align(stage,sendReport);
				sendReport.addEventListener(Nana10PlayerEvent.SEND_BUG_REPORT,onReportBug);
			}
			addChild(sendReport);
			sendReport.visible = true;
		}
		
		private function onReportBug(event:Nana10PlayerEvent):void
		{
			if (dataRepository.previewGroupID) return;
			onOpenBugReporting(event);
		}
		
		private function addRemoveFromStageFunctionality():void
		{
			try
			{
				if (ExternalInterface.available)
				{
					ExternalInterface.addCallback("removeFromStage",removeFromStage);
				}
			}
			catch (e:Error)
			{
				Debugging.printToConsole("error registering 'removeFromStage'",e.message);
			}
		}
		
		// this function is called from outside - when the HTML page wanst to remove the player
		public function removeFromStage():void
		{
			Debugging.printToConsole("--Nana10Player.removeFromStage");
			onRemovedFromStage(null);
			screenCover.visible = true;
			showLoadingAnimation();
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			videoPlayer.dispose();
			controls.dispose();
			if (cm8Delegate)
			{
				cm8Delegate.removeEventListener(PluginEvent.VIDEO_WORKPLAN,onCM8DataReady);
				cm8Delegate.removeEventListener(PluginEvent.AD_METADATA,onCM8AdReady);
				cm8Delegate.removeEventListener(PluginEvent.AD_RESOLVE,onCM8AdReady);
				cm8Delegate.removeEventListener(PluginEvent.AD_START,onCM8AdBegan);
				cm8Delegate.removeEventListener(PluginEvent.AD_PROGRESS,onCM8AdProgress);
				cm8Delegate.removeEventListener(PluginEvent.AD_COMPLETE,onCM8AdEnded);
				cm8Delegate.removeEventListener(PluginEvent.WORKPLAN_COMPLETE,onCM8WorkplanComplete);
				cm8Delegate.removeEventListener(PluginEvent.PLUGIN_LOADED,onCM8PluginLoaded);
				cm8Delegate.removeEventListener(PluginEvent.PLUGIN_LOAD_ERROR,onCM8DataReady);
				cm8Delegate.removeEventListener(PluginEvent.ERROR,onCM8DataReady);
				//cm8Delegate.removeEventListener(PlayerEvent.DISABLE_CONTROLS,onCM8DisableControls);
				cm8Delegate.removeEventListener(PlayerEvent.ENABLE_CONTROLS,onCM8EnableControls);
				cm8Delegate.removeEventListener(PluginEvent.RESUME,onCM8resumed);
				cm8Delegate.dispose();
				cm8Delegate = null;
			}
			stage.removeEventListener(MouseEvent.MOUSE_OUT,onHideControls);
			KeyboardShortcutsMangaer.disableKeyboardShortcuts();
		}
		
		private function report2Taboola():void
		{
			try
			{
				ExternalInterface.call("MediAnd.reportVideoPlay2Taboola",externalParams.VideoID);
				ExternalInterface.call("MediAnd.taboola_videoBegan",externalParams.VideoID);
			}
			catch (e:Error)
			{
				Debugging.printToConsole("failed to call 'reportVideoPlay2Taboolan");
			}
		}
		
		// this function is used only when previewing from the tagger
		public function preview(firstPreview:Boolean = false):void
		{	
			if (!firstPreview)
			{
				videoPlayer.dispose();
				screenCover.alpha = 1;
				communicationLayer.reset();
				controls.resetTimer();
				nana10PlayerData.reset();
				controls.pause();
				firstTime = true;
				KeyboardShortcutsMangaer.enableKeyboardShortcuts();
			}
			else
			{
				stillImage.loadImage("http://f.nanafiles.co.il//upload/mediastock/img/11/0/24/24316.jpg?rf=1306752337416&.jpg");
			}
			controls.visible = true;
			dataRepository.sortOnTimeCode();
			Nana10DataParser.parseData();
			externalParams.CM8Target = "pid48.channels.sid243.tagger"; 
			if (dataRepository.videoLink.indexOf("gm.asp") > -1)
			{
				nana10PlayerData.getVideoFile(dataRepository.videoLink + "&curettype=1");
			}
			else
			{
				onMetaDataReady(null);
			}	
		}
	}
}
