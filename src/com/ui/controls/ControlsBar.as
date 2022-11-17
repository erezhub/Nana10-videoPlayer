package com.ui.controls
{
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.GemiusDelegate;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.events.Nana10PlayerEvent;
	import com.events.VideoControlsEvent;
	import com.events.VideoPlayerEvent;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	import com.fxpn.util.MathUtils;
	import com.fxpn.util.StringUtils;
	import com.ui.Nana10VideoPlayer;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;
	
	import gs.TweenLite;
	
	import resources.controls.FullScreenToggle;
	import resources.controls.HDtoggle;
	import resources.controls.PlayPauseBtn;

	[Event (name="play", type="com.events.VideoPlayerEvent")]
	[Event (name="pause", type="com.events.VideoPlayerEvent")]
	[Event (name="gotoFrame", type="com.events.VideoPlayerEvent")]
	[Event (name="reachedKeyframe", type="com.events.VideoPlayerEvent")]
	[Event (name="loadComments", type="com.events.Nana10PlayerEvent")]
	[Event (name="detachComments", type="com.events.Nana10PlayerEvent")]
	[Event (name="closeFloatingComments", type="com.events.Nana10PlayerEvent")]
	[Event (name="addComment", type="com.events.Nana10PlayerEvent")]
	[Event (name="deleteComment", type="com.events.Nana10PlayerEvent")]
	[Event (name="switchQualityHigh", type="com.events.Nana10PlayerEvent")]
	[Event (name="swtichQualityNormal", type="com.events.Nana10PlayerEvent")]
	[Event (name="volumeChanged", type="com.events.Nana10PlayerEvent")]
	[Event (name="commentsClosed", type="com.events.Nana10PlayerEvent")]	
	[Event (name="commentsOpened", type="com.events.Nana10PlayerEvent")]	
	public class ControlsBar extends Sprite
	{
		private var dataRepository:Nana10DataRepository;
		private var communicationLayer:CommunicationLayer;
		private var _videoPlayer:Nana10VideoPlayer;
		private var volumeControl:VolumeControl;
		private var playPauseBtn:PlayPauseBtn;
		private var fullScreenBtn:FullScreenToggle;
		private var hdToggle:HDtoggle;
		private var progressBar:ProgressBar;
		private var bg:Shape;
		private var controlsTimer:Timer;
		private var updateBuffer:Boolean;
		private var currentItemIndex:int;
		private var _startTime:Number;
		private var _playFirstClick:Boolean;
		private var hideTimer:Timer;
		private var hideTween:TweenLite;
		private var hidden:Boolean;
		private var _movieEnded:Boolean;
		private var _movieStarted:Boolean;
		private var _timelineHeight:Number;
		private var allowFullscreen:Boolean = true;
		private var isLive:Boolean;
		private var _stageWidth:Number;
		private var itemsGap:int;
		
		public function ControlsBar(stageWidth:Number)
		{
			dataRepository = Nana10DataRepository.getInstance();
			communicationLayer = CommunicationLayer.getInstance();
			_startTime = 0;
			if (Nana10PlayerData.getInstance().autoPlay == false) _playFirstClick = true;
			mouseChildren = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			communicationLayer.addEventListener(VideoControlsEvent.GO_TO_FRAME, onGotoFrame);
			
			isLive = Nana10PlayerData.getInstance().isLive;
			_stageWidth = stageWidth;			
			itemsGap = stageWidth < 400 ?  2 + 10*(Math.sin(MathUtils.degreesToRadians((stageWidth-220)/2))) : 12;
		}
			
		private function onAddedToStage(event:Event):void
		{			
			playPauseBtn = new PlayPauseBtn();
			addChild(playPauseBtn);
			playPauseBtn.addEventListener(MouseEvent.CLICK,onToggleVideo);
			
			bg = ShapeDraw.drawSimpleRect(_stageWidth - playPauseBtn.width - (itemsGap*3),32,0x172322,0.8,9);
			bg.scale9Grid = new Rectangle(10,10,bg.width - 20,bg.height - 20);
			addChild(bg);
				
			volumeControl = new VolumeControl();
			hdToggle = new HDtoggle();
			fullScreenBtn = new FullScreenToggle();
			
			progressBar = new ProgressBar(bg.width - (volumeControl.width + hdToggle.width + fullScreenBtn.width + itemsGap*5));
			progressBar.addEventListener(VideoControlsEvent.GO_TO_FRAME, onGotoFrame);
			addChild(progressBar);
						
			addChild(volumeControl);
			volumeControl.addEventListener(VideoControlsEvent.CHANGE_VOLUME, onVolumeChanged);
			volumeControl.init();
			
			hdToggle.addEventListener(MouseEvent.CLICK,onToggleHQ);
			addChild(hdToggle);
						
			addChild(fullScreenBtn);
			fullScreenBtn.addEventListener(MouseEvent.CLICK,onToggleFullscreen);
		
			
			controlsTimer = new Timer(50);
			controlsTimer.addEventListener(TimerEvent.TIMER, onTimer);
			
			hideTimer = new Timer(7000,1);
			hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onHideTimer);
			
			setItemsLocations();			
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function setItemsLocations():void
		{			
			bg.x = playPauseBtn.x + playPauseBtn.width + itemsGap;
			DisplayUtils.spacialAlign(playPauseBtn,bg,null,NaN,DisplayUtils.BOTTOM);
			DisplayUtils.spacialAlign(bg,progressBar,DisplayUtils.LEFT,itemsGap,DisplayUtils.TOP,10);
			volumeControl.x = progressBar.x + progressBar.width + itemsGap;
			hdToggle.x = volumeControl.x + volumeControl.width + itemsGap;
			fullScreenBtn.x = hdToggle.x + hdToggle.width + itemsGap;
			volumeControl.y = hdToggle.y = fullScreenBtn.y = bg.y + 10;
		}
				
		private function onVolumeChanged(event:VideoControlsEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onRollOverButton(event:MouseEvent):void
		{
			(event.target as MovieClip).alpha = 1;
		}
		
		private function onRollOutButton(event:MouseEvent):void
		{
			(event.target as MovieClip).alpha = 0;
		}
		
		private function onToggleVideo(event:MouseEvent):void
		{
			Debugging.printToConsole("--UserAction: toggled video",StringUtils.turnNumberToTime(communicationLayer.playheadTime,true,true,true));
			toggleVideo(true);	
		}
		
		public function toggleVideo(fromButton:Boolean = false):void
		{
			/*if (playPauseBtn.disabled.visible) return; // when called from the KeyboardShortcuts manager while the button is disabled*/
			if (playPauseBtn.currentLabel == "play")
			{
				if (fromButton) dispatchEvent(new VideoControlsEvent(VideoControlsEvent.PLAY));
				if (_playFirstClick)
				{
					_playFirstClick = false;
					if (fromButton) return;
				}
				if (fromButton) StatsManagers.updatePlayerStats(StatsManagers.PlayClick);
				play(fromButton);				
			}
			else
			{
				StatsManagers.updatePlayerStats(StatsManagers.PauseClick);
				pause();
			}			
		}
		
		public function play(reportStats:Boolean = true):void
		{
			playPauseBtn.gotoAndStop("pause");
			if (CommunicationLayer.getInstance().state == CommunicationLayer.PLAYER && reportStats) StatsManagers.updatePlayerStats(StatsManagers.MoviePlay);
			//TooltipFactory.getInstance().changeMessage(playPauseBtn,"(עצור (מקש רווח");
			if (CommunicationLayer.getInstance().state == CommunicationLayer.PLAYER)
			{
				if (isLive && _videoPlayer.source)
				{
					_videoPlayer.resumeLiveStream();
				}
				else if (!_movieEnded)
				{
					_videoPlayer.play();
				}
			}

			if (_movieEnded)
			{
				communicationLayer.scenesGaps = 0;
				var event:VideoControlsEvent = new VideoControlsEvent(VideoControlsEvent.GO_TO_FRAME,0);
				onGotoFrame(event);
				updateBuffer = true;
				_movieEnded = false;
				return;
			}
		}
		
		public function pause():void
		{
			if (CommunicationLayer.getInstance().state == CommunicationLayer.PLAYER) StatsManagers.updatePlayerStats(StatsManagers.MoviePause);
			playPauseBtn.gotoAndStop("play");
			//TooltipFactory.getInstance().changeMessage(playPauseBtn,"(נגן (מקש רווח");
			if (CommunicationLayer.getInstance().state == CommunicationLayer.PLAYER)
			{
				if (isLive)
				{
					_videoPlayer.pauseLiveStream();
				}
				else
				{
					_videoPlayer.pause();					
				}
			}
			else
			{
				progressBar.pause();
			}
			dispatchEvent(new VideoControlsEvent(VideoControlsEvent.PAUSE));
		}
		
		private function onToggleHQ(event:MouseEvent):void
		{
			toggleHQ();	
		}
		
		public function toggleHQ():void
		{
			if (hdToggle.mouseChildren && hdToggle.mouseEnabled)
			{
				Debugging.printToConsole("--UserAction: toggleHQ");
				if (ExternalParameters.getInstance().HQSlideShow)
				{
					dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.HQ_DOWNLOAD_WINDOW_OPENED));
				}
				else if (hdToggle.currentLabel == "on")
				{
					hdToggle.gotoAndStop("off");
					//TooltipFactory.getInstance().changeMessage(hdToggle,"(H) שנה לאיכות נמוכה");
					StatsManagers.updatePlayerStats(StatsManagers.HQOff);
					dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.SWTICH_QUALITY_NORMAL));
				}
				else
				{
					hdToggle.gotoAndStop("on");
					//TooltipFactory.getInstance().changeMessage(hdToggle,"(H) שנה לאיכות גבוהה");
					StatsManagers.updatePlayerStats(StatsManagers.HQOn);
					dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.SWITCH_QUALITY_HIGH));
				}
			}
		}
		
		public function resetHQ():void
		{
			hdToggle.gotoAndStop("on");
			//TooltipFactory.getInstance().changeMessage(hqButton,"(H) שנה לאיכות גבוהה");
		}
				
		public function onToggleFullscreen(event:MouseEvent = null):void
		{
			if (fullScreenBtn.mouseChildren && fullScreenBtn.mouseEnabled)
			{
				Debugging.printToConsole("--UserAction: full-screen toggle", stage.displayState,StringUtils.turnNumberToTime(communicationLayer.playheadTime,true,true,true));
				if (fullScreenBtn.currentLabel == "off")
				{
					try
					{
						stage.displayState = StageDisplayState.FULL_SCREEN;
					}
					catch (e:Error)
					{
						//TooltipFactory.getInstance().dispalyTooltip("לא ניתן להציג במסך מלא",fullscreenBtn);  // for some reason it doesn't work
						fullScreenBtnEnabled = false;
						allowFullscreen = false;
						return;
					}
					fullScreenBtn.gotoAndStop("on");
					//TooltipFactory.getInstance().changeMessage(fullscreenBtn,"(ESC) סגור מסך מלא");										
				}
				else
				{
					fullScreenBtn.gotoAndStop("off");
					stage.displayState = StageDisplayState.NORMAL;
					//TooltipFactory.getInstance().changeMessage(fullscreenBtn,"(F) מסך מלא");
				}
			}
		}	
		
		public function changeVolume(direction:Boolean):void
		{
			volumeControl.changeVolume(direction);			
		}
		
		private function onGotoFrame(event:VideoControlsEvent):void
		{
			var totalItems:int = dataRepository.totalItems;
			var expectedTimeCode:Number = findSeekPoint(event.timeCode)
			for (var i:int = 0; i < totalItems; i++)
			{				
				if (dataRepository.getItemByIndex(i).timeCode >= expectedTimeCode)
				{					
					if (i+1 < dataRepository.totalItems && dataRepository.getItemByIndex(i+1).timeCode == event.timeCode)
					{
						// this is usefull when jumping to a chapter, but there's a seek point prior to the chapter, but still we need that chapter's
						// index (and not its proceeding end-of-segment) to be the current item index
						i++;
					}
					break;
				}
				if (dataRepository.getItemByIndex(i).type == Nana10ItemData.MARKER && 
					dataRepository.getItemByIndex(i).markerType == Nana10MarkerData.AD &&
					dataRepository.getItemByIndex(i).timeCode + CommunicationLayer.MINS_BETWEEN_MIDROLLS*60 > expectedTimeCode) event.skippedMidrollTimeCode = dataRepository.getItemByIndex(i).timeCode;
			}
			currentItemIndex = i;
			if (!isNaN(event.skippedMidrollTimeCode))
			{	// if skipped midroll - making sure we're not too close (less than 1min) to the next midroll
				for (var j:int = currentItemIndex + 1; j < totalItems; j++)
				{
					if (dataRepository.getItemByIndex(j).type == Nana10ItemData.MARKER)
					{
						if (dataRepository.getItemByIndex(j).timeCode < expectedTimeCode + 60)
						{
							event.skippedMidrollTimeCode = NaN;
						}
						break;
					}
				}
			}
			if ((event.timeCode - communicationLayer.currentStartTime) / _videoPlayer.duration > _videoPlayer.howMuchLoaded)
			{
				controlsTimer.stop();
			}
			else if (controlsTimer.running == false && !_movieEnded)
			{
				Debugging.printToConsole("--ControlsBar.onGotoFrame");
				controlsTimer.start();
			}
			if (_movieEnded)
			{
				playPauseBtn.gotoAndStop("pause");
				event.videoEnded = true;
			}
			dispatchEvent(event);
			event.stopPropagation();			
			GemiusDelegate.seekingStarted();
		}
		
		private function findSeekPoint(timeCode:Number):Number
		{
			var array:Array = communicationLayer.videoSeekPointsArray;
			if (array == null) return timeCode;
			var b:int = 0;//bottom search index
			var t:int = array.length-1;//top search index
			
			while (b <= t)//as long as the indexes have not crossed
			{
				var index:uint = (b+t)/2//search the middle of the indexes
				
				if (array[index] <= timeCode && array[index+1]>timeCode)//have you found the value?
				{
						return array[index];
				}
				else if (array[index] < timeCode)//if the value checked is lower than the search term, it will check the higher portion
				{
					b = index+1;
				}
				else//otherwise it will check the lower portion
				{
					t = index-1;
				}
			}
			if (b > t)
			{
				return array[t];
			}
			return array[0];
		}
				
		private function onTimer(event:TimerEvent):void
		{
			progressBar.updateProgress();
			if (currentItemIndex < dataRepository.totalItems && (communicationLayer.playheadTime + communicationLayer.scenesGaps) > dataRepository.getItemByIndex(currentItemIndex).timeCode)
			{						
				reachedKeyframe(_videoPlayer.playheadTime - communicationLayer.videoStartOffset > dataRepository.getItemByIndex(currentItemIndex).timeCode + 1);					
			}
			
			if (updateBuffer)
			{
				progressBar.updateBuffer(_videoPlayer.howMuchLoaded);
				if (_videoPlayer.howMuchLoaded == 1)
				{
					updateBuffer = false;
					//_videoPlayer.loadingDone();
				}
			}
		}
		
		private function reachedKeyframe(skipped:Boolean):void
		{
			if (!skipped)
			{
				var event:VideoPlayerEvent = new VideoPlayerEvent(VideoPlayerEvent.REACHED_KEYFRAME,currentItemIndex++)
				event.skippedKeyframe = skipped; 
				dispatchEvent(event);
			}
		}
		
		public function setCurrentTime(value:Number):void
		{
			progressBar.updateProgress(value);
		}
		
		public function onDisplayStateChanged(event:FullScreenEvent):void
		{
			_stageWidth = stage.stageWidth;
			itemsGap = _stageWidth < 400 ?  2 + 10*(Math.sin(MathUtils.degreesToRadians((_stageWidth-220)/2))) : 12;
			if (event.fullScreen)
			{
				try
				{
					ExternalInterface.call("MediAnd.toggleBanners",true);
				}
				catch (e:Error) {}
				StatsManagers.updatePlayerStats(StatsManagers.FullScreenOn);
				bg.width = 600;
			}
			else
			{
				fullScreenBtn.gotoAndStop("off");
				//TooltipFactory.getInstance().changeMessage(fullscreenBtn,"(F) מסך מלא");
				Mouse.show();
				StatsManagers.updatePlayerStats(StatsManagers.FullScreenOff);
				if (movieStarted) showControls();
				bg.width = _stageWidth - playPauseBtn.width - (itemsGap*3);
			}
			progressBar.width = bg.width - (volumeControl.width + hdToggle.width + fullScreenBtn.width + itemsGap*5)
			setItemsLocations();
		}
		
		private function setHideTimer():void
		{
			if (hideTimer.running == false)
			{
				hideTimer.start();
			}
		}		
		
		private function onHideTimer(event:TimerEvent):void
		{
			if (!hidden)
			{
				hide();
			}
		}
		
		public function hide():void
		{
			if (communicationLayer.state == CommunicationLayer.PLAYER)
			{
				//Debugging.printToConsole("hide",hideTimer.delay);
				if (hideTween != null && hideTween.active) hideTween.complete(true);
				hideTween = new TweenLite(this,0.5,{alpha: 0});
				if (stage.displayState == StageDisplayState.FULL_SCREEN) Mouse.hide();
				hidden = true;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onShowControls);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onShowControls);
				stage.addEventListener(KeyboardEvent.KEY_DOWN,onShowControls);
				dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.HIDE_CONTROLS));
			}
		}
				
		private function onShowControls(event:Event):void
		{
			showControls(event.target != stage);	
		}
		
		public function showControls(notFromStage:Boolean = true):void
		{			
			hideTimer.reset();
			hideTimer.start();
			if (hidden && notFromStage)
			{
				//Debugging.printToConsole("showControls");
				if (hideTween != null && hideTween.active) hideTween.complete(true);
				hideTween = new TweenLite(this,0.5,{alpha: 1});
				Mouse.show();
				hidden = false;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onShowControls);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onShowControls);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,onShowControls);
				dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.SHOW_CONTROLS));
			}
		}
			
		public function start():void
		{
			Debugging.printToConsole("--ControlsBar.start");
			progressBar.ratio = communicationLayer.videoNetDuration;
			updateBuffer = true;
			if (isLive)
			{
				progressBar.hideProgress();
				progressBar.mouseChildren = false;
			}
			else
			{
				progressBar.mouseChildren = true;				
				controlsTimer.start();
				if (Nana10PlayerData.getInstance().hqAvailable)
				{
					hdToggle.mouseChildren = true;
					hdToggle.buttonMode = true;
				}				
			}
			playPauseBtn.mouseEnabled = playPauseBtn.mouseChildren = true;
			progressBar.adMode = false;
			_videoPlayer.init();
			_videoPlayer.play();
			currentItemIndex = 0;
			_movieEnded = false;
			_movieStarted = true;
			setHideTimer();
		}

		// pausing for video ad
		public function hold(adLength:Number = NaN):void
		{
			//if (!isNaN(adLength) && adLength <= 0) return;
			Debugging.printToConsole("--ControlsBar.hold",adLength);
			progressBar.tweenPlayhead = false;
			progressBar.adMode = true;
			progressBar.ratio = adLength;
			controlsTimer.stop();		
			hdToggle.mouseChildren = hdToggle.buttonMode = false;
			playPauseBtn.mouseEnabled = playPauseBtn.mouseChildren = true;
			hideTimer.reset();
			hideTimer.delay = 5000;
			setHideTimer();
			//showControls();
		}
		
		// video ad ended
		public function resume():void
		{
			progressBar.tweenPlayhead = false;
			hideTimer.reset();
			hideTimer.delay = 7000;
			if (!movieStarted || _movieEnded)
			{
				start();
				return;
			}
			Debugging.printToConsole("--ControlsBar.resume");
			progressBar.adMode = false;	
			setHideTimer();
			if (isLive)
			{
				progressBar.hideProgress();
				progressBar.mouseChildren = false;
			}
			else
			{
				progressBar.ratio = communicationLayer.videoNetDuration;
				controlsTimer.start();
				updateBuffer = true;
				if (Nana10PlayerData.getInstance().hqAvailable)
				{
					hdToggle.mouseChildren = true;
					hdToggle.buttonMode = true;
				}
			}			
		}
		
		public function holdTimer():void
		{
			controlsTimer.stop();
		}
		
		public function resumeTimer():void
		{
			Debugging.printToConsole("--ControlsBar.resumeTimer");
			controlsTimer.start();
		}
		
		public function resetTimer():void
		{
			_movieEnded = _movieStarted = false;
			progressBar.resetBuffer(0);
			progressBar.updateProgress(0);
		}
		
		public function videoEnded():void
		{
			closeAllPannel();
			controlsTimer.stop();
			playPauseBtn.gotoAndStop("play");
			//TooltipFactory.getInstance().changeMessage(playPauseBtn,"(נגן (מקש רווח");
			_movieEnded = true;
			//timelineControl.enabled = true;
			//timelineControl.updateTimeline();
		}
		
		public function set videoPlayer(value:Nana10VideoPlayer):void
		{
			_videoPlayer = value;
			if (isNaN(value.fps) == false) controlsTimer.delay = 1;
		}
				
		public function closeAllPannel(butComments:Boolean = false):MovieClip
		{
			var currentOpenPannel:MovieClip;
			return currentOpenPannel;
		}
		
		public function enablePreMovieButtons(embededPlayer:Boolean):void
		{
			Debugging.printToConsole("--ControlsBar.enablePremovieButtons");
			mouseChildren = true;
			progressBar.mouseChildren = false;
			playPauseBtn.mouseEnabled = playPauseBtn.mouseChildren = !Nana10PlayerData.getInstance().autoPlay;
			if (!isLive) progressBar.dispalyTotalTime();
			if (Nana10PlayerData.getInstance().hqAvailable == false) hdToggle.mouseChildren = false;
	
			if (dataRepository.previewGroupID == 0)
			{
				//fullscreenBtn.addEventListener(MouseEvent.CLICK,onToggleFullscreen);
				//TooltipFactory.getInstance().addSubscriber(fullscreenBtn,"(F) מסך מלא");
				fullScreenBtnEnabled = true;
			}
		}
				
		public function set loadingVideo(value:Boolean):void
		{
			fullScreenBtnEnabled = !value; 
		}
		
		public function set fullScreenBtnEnabled(value:Boolean):void
		{
			if (allowFullscreen)
			{
				fullScreenBtn.mouseChildren = fullScreenBtn.mouseEnabled = value;
			}
		}
		
		public function set startTime(value:Number):void
		{
			_startTime = value;
		}
		
		public function reset(resetPoint:Number):void
		{
			Debugging.printToConsole("--ControlsBar.reset");
			progressBar.resetBuffer(resetPoint / communicationLayer.videoNetDuration);
			if (communicationLayer.state == CommunicationLayer.PLAYER) controlsTimer.start();
			_startTime = resetPoint;
			_movieEnded = false;
		}	
		
		public function dispose():void
		{
			if (hideTimer && hideTimer.running) hideTimer.stop();
			if (controlsTimer.running) controlsTimer.stop();
		}
		
		public function displayLoadingSpeed():void
		{
			Debugging.printToConsole("video loading speed",_videoPlayer.loadingSpeed,"Kb/sec");
		}
		
		public function get isPaused():Boolean
		{	
			return playPauseBtn.currentLabel == "play";
		}
		
		override public function set width(value:Number):void
		{
			//bg.width = value;
			//if (timelineControl != null) timelineControl.width = value;
			//setButtonsLocation();
		}
		
		override public function get width():Number
		{
			return playPauseBtn.x + playPauseBtn.width + itemsGap + bg.width;
		}
				
		public function get timelineHeight():Number
		{
			return _timelineHeight;
		}

		public function get movieEnded():Boolean
		{
			return _movieEnded;
		}

		public function get playFirstClick():Boolean
		{
			return _playFirstClick;
		}

		public function updateCurrentItemIndex(value:int):void
		{
			currentItemIndex-=value;
		}	

		public function get movieStarted():Boolean
		{
			return _movieStarted;
		}
	}
}