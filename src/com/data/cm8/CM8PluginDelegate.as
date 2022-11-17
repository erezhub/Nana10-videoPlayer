/**
 * this class is in charge of all the interactions around displaying the ads - linear (pre/mid-rolls) and non-linears (overlays).
 * it does so by loading  'AdVantageVideo.swf' from CM8's servers, and interacting with it using its API, which is explained 'AdVantage Video API.pdf'
 */
package com.data.cm8
{
	import com.checkm8.advantage.video.delegation.player.api.IDelegate;
	import com.checkm8.advantage.video.delegation.player.api.businessobject.IVideo;
	import com.checkm8.advantage.video.delegation.player.api.businessobject.IVideoPosition;
	import com.checkm8.advantage.video.delegation.player.api.event.PlayerEvent;
	import com.checkm8.advantage.video.delegation.player.api.event.PluginEvent;
	import com.checkm8.advantage.video.util.logger.Log;
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.data.cm8.businessobject.Video;
	import com.data.cm8.businessobject.VideoCuePoint;
	import com.data.cm8.businessobject.VideoPosition;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	import com.ui.Nana10VideoPlayer;
	import com.ui.controls.ControlsBar;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;
	import flash.utils.getTimer;
	
	public class CM8PluginDelegate extends EventDispatcher implements IDelegate
	{
		private var _cm8PlaceHolder:DisplayObjectContainer;
		private var _controls:ControlsBar;
		private var video:Video;
		private var _videoPosition:VideoPosition;
		private var plugin:Plugin;
		private var pluginLoader:Loader;
		private var _hasPreroll:Boolean;
		private var _hasPostroll:Boolean;
		private var adPlaying:Boolean;
		private var timer:Timer;
		private var adStartTime:Number;
		private var _isRunning:Boolean;
		private var timeoutTimer:Timer;
		private var _videoStart:Boolean;
		private var invoedkAd:int;
		private var initialized:Boolean;
		private var pluginError:Boolean;
		private var eventListeners:Dictionary;
		private var _local:Boolean;
		private var _dev:Boolean;
		
		public function CM8PluginDelegate(cm8PlaceHolder:DisplayObjectContainer,controls:ControlsBar, swfURL:String = null)
		{
			Debugging.printToConsole("--CM8PluginDelegate");
			_cm8PlaceHolder = cm8PlaceHolder;
			_controls = controls;
			_local = swfURL ? swfURL.indexOf("file://") > -1 : false;
			_dev = swfURL ? swfURL.indexOf("-dev") > -1 : false;
			eventListeners = new Dictionary(true);
			
			timer = new Timer(250);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			
			timeoutTimer = new Timer(10000,1);
			timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeout);
						
			pluginLoader = new Loader();
			pluginLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPluginLoaded);
			pluginLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onPluginLoadError);			
		}
		
		public function loadPlugin():void
		{
			var pluginURL:String = StringUtils.isStringEmpty(ExternalParameters.getInstance().CM8Wrapper) ? "http://nana10digital.checkm8.com/modules/video/v2.0/plugin/AdVantageVideo.swf" : ExternalParameters.getInstance().CM8Wrapper; 
			var request:URLRequest = new URLRequest(pluginURL);
			pluginLoader.load(request);
			timeoutTimer.start();
		}
		
		//------ public functions called from the plugin itself ---------
		public function get version():String
		{
			return "2.0";
		}
		
		public function registerEventListener(type:String, listener:Function):void
		{
			addEventListener(type,listener);
			eventListeners[type] = listener;
		}
		
		public function unregisterEventListener(type:String, listener:Function):void
		{
			removeEventListener(type,listener);
		}
		
		public function notify(event:Event):void
		{
			if (event.type != PluginEvent.AD_PROGRESS) Debugging.printToConsole("--CM8PluginDelegate.nofity",event.type, StringUtils.turnNumberToTime(getTimer()/1000,false,false,true));
			var outgoingEvent:PluginEvent;
			switch (event.type)
			{
				case PluginEvent.VIDEO_WORKPLAN:
				case PluginEvent.ERROR:
				case PluginEvent.PLUGIN_LOAD_ERROR:
					timeoutTimer.stop();
					if (event.type != PluginEvent.VIDEO_WORKPLAN) pluginError = true;
					break;
				case PluginEvent.AD_COMPLETE:
					outgoingEvent = new PluginEvent(PluginEvent.AD_COMPLETE,(event as Object).data);
					timer.start();
					Debugging.printToConsole("CM8 timer start");
					break;
				case PluginEvent.AD_PROGRESS:
					if (!_isRunning) return;
					outgoingEvent = new PluginEvent(PluginEvent.AD_PROGRESS,(event as Object).data);
					break;
				case PluginEvent.AD_METADATA:
					outgoingEvent = new PluginEvent(PluginEvent.AD_METADATA,(event as Object).data);
					break;
				case PluginEvent.AD_START:
					outgoingEvent = new PluginEvent(PluginEvent.AD_START,(event as Object).data);
					if ((event as Object).data.isLinear)
					{
						timer.stop();
						Debugging.printToConsole("CM8 timer stopped");
						adStartTime = CommunicationLayer.getInstance().playheadTime;
					}
					break;	
				case PluginEvent.AD_RESOLVE:
					outgoingEvent = new PluginEvent(PluginEvent.AD_RESOLVE,(event as Object).data);
					break;
			}
			if (outgoingEvent) 
			{
				dispatchEvent(outgoingEvent);
			}
			else
			{
				dispatchEvent(event);	
			}
			if (event.type == PluginEvent.AD_COMPLETE) _hasPreroll = false;
		}
		
		public function get currentVideo():IVideo
		{
			if (video == null) video = new Video();
			return video;
		}
		
		public function addChild(child:DisplayObject):void
		{
			_cm8PlaceHolder.addChild(child);
		}
		
		public function removeChild(child:DisplayObject):void
		{
			_cm8PlaceHolder.removeChild(child);
		}
		
		public function get videoPosition():IVideoPosition
		{
			if (_videoPosition == null) _videoPosition = new VideoPosition();
			return _videoPosition;
		}
		
		public function get volume():Number
		{
			return CommunicationLayer.getInstance().videoPlayer.volume * 0.4;
		}
		
		// the ad begins - the plug-in pauses the video
		public function pause():void
		{
			Debugging.printToConsole("--CM8PluginDelegate.pause", StringUtils.turnNumberToTime(getTimer()/1000,false,false,true));
			var videoPlayer:Nana10VideoPlayer = CommunicationLayer.getInstance().videoPlayer;
			if (videoPlayer.isPlaying)
			{
				if (Nana10PlayerData.getInstance().isLive)
				{
					videoPlayer.pauseLiveStream();
				}
				else
				{
					videoPlayer.pause();
				}
			}
			timer.stop();
			Debugging.printToConsole("CM8 timer stopped");
			_isRunning = true;
		}
		
		// the ad ended - the video is resumded
		public function resume():void
		{
			Debugging.printToConsole("--CM8PluginDelegate.resume", StringUtils.turnNumberToTime(getTimer()/1000,false,false,true));			
			if (Nana10PlayerData.getInstance().isLive)
			{
				CommunicationLayer.getInstance().videoPlayer.resumeLiveStream();
			}
			else
			{
				CommunicationLayer.getInstance().videoPlayer.play();
			}
			timer.start();
			Debugging.printToConsole("CM8 timer start");
			_isRunning = false;
			dispatchEvent(new PluginEvent(PluginEvent.RESUME));
		}
				
		public function get disabledControls():Array
		{
			return null;
		}
		
		// the plugin calls this function either with an array of controls to be disabled, or an empty array meaning all controls should be enabled
		public function set disabledControls(controls:Array):void
		{
			if (pluginError) return;
			Debugging.printToConsole("--CM8PluginDelegate.disableControls", controls.length > 0, StringUtils.turnNumberToTime(getTimer()/1000,false,false,true));
			if (controls.length)
			{
				dispatchEvent(new PlayerEvent(PlayerEvent.DISABLE_CONTROLS));
			}
			else
			{
				dispatchEvent(new PlayerEvent(PlayerEvent.ENABLE_CONTROLS));
			}
		}
		
		//---- functions called from the player, used to dispatch events to the plugin
		public function videoLoaded():void
		{
			if (pluginError) return;
			Debugging.printToConsole("--CM8PluginDelegate.videoLoaded");
			dispatchEvent(new PlayerEvent(PlayerEvent.VIDEO_LOAD));
		}
		
		public function videoStart():void
		{
			if (!_videoStart && !pluginError)
			{
				Debugging.printToConsole("--CM8PluginDelegate.videoStart");
				dispatchEvent(new PlayerEvent(PlayerEvent.VIDEO_START));
				timer.start();
				Debugging.printToConsole("CM8 timer start");
				_videoStart = true;
			}
		}
		
		// user clicked the pause button
		public function videoPaused():void
		{
			if (pluginError) return;
			Debugging.printToConsole("--CM8PluginDelegate.videoPaused");
			dispatchEvent(new PlayerEvent(PlayerEvent.PAUSE));
			if (timer.running)
			{
				timer.stop();
				Debugging.printToConsole("CM8 timer stopped");
			}
		}
		
		// user clicked the play button
		public function videoResumed():void
		{
			if (pluginError) return;
			Debugging.printToConsole("--CM8PluginDelegate.videoResumed");
			dispatchEvent(new PlayerEvent(PlayerEvent.RESUME));
			if (_isRunning == false)
			{
				timer.start();
				Debugging.printToConsole("CM8 timer start");
			}
		}
		
		//when the video is paused - displaying an overlay
		public function invokeAd():void
		{
			if (pluginError) return;
			try
			{
				invoedkAd = plugin.invokeAd("DirectAd");
				Debugging.printToConsole("--CM8PluginDelegate.invokeAD",invoedkAd);
			}
			catch (e:Error) {
				Debugging.printToConsole("--CM8PluginDelegate.invokeAD failed",e.message);
			}
		}
		
		// when the video is resumed - removing the overlay
		public function revokeAd():void
		{
			if (pluginError) return;
			Debugging.printToConsole("--CM8PluginDelegate.revokeAD",invoedkAd);
			if (invoedkAd)
			{
				try
				{
					plugin.revokeAd(invoedkAd);
				}
				catch (e:Error)
				{
					Debugging.printToConsole("revokeAd failed",e.message);
				}
			}
			invoedkAd = 0;
		}
		
		// used to display midrolls during live-stream
		public function reachedCuePoint(timeCode:Number):void
		{
			if (pluginError) return;
			dispatchEvent(new PlayerEvent(PlayerEvent.CUE_POINT,new VideoCuePoint(null,timeCode)));
		}
		
		// used to stop midrolls during live-stream (when the stream's commercials break ends)
		public function terminateRunningAds():void
		{
			if (pluginError) return;
			plugin.terminateRunningAds();
		}
		
		public function videoResize(fullScreen:Boolean):void
		{
			Debugging.printToConsole("--CM8PluginDelegate.videoResize");			
			VideoPosition.fullScreen = fullScreen; 
			try
			{
				dispatchEvent(new PlayerEvent(PlayerEvent.RESIZE));
			}
			catch (e:Error){}
		}
		
		public function volumeChanged(volumeLevel:Number):void
		{
			Debugging.printToConsole("--CM8PluginDelegate.volumeChanged",volumeLevel*0.2);
			dispatchEvent(new PlayerEvent(PlayerEvent.VOLUME_CHANGE,volumeLevel*0.2));
		}
		
		public function videoEnded():void
		{
			Debugging.printToConsole("--CM8PluginDelegate.videoEnded");
			dispatchEvent(new PlayerEvent(PlayerEvent.VIDEO_COMPLETE));
			_hasPostroll = false;
		}
		//---------------------------------------
		
		
		private function onPluginLoaded(event:Event):void
		{
			Debugging.printToConsole("--CM8PluginDelegate.onPluginLoaded");
			// Setup wrapper around the loaded plug-in
			plugin = new Plugin(event.target.content);	
			timeoutTimer.stop();
			dispatchEvent(new PluginEvent(PluginEvent.PLUGIN_LOADED));
		}
		
		public function loadWorkplan():void
		{
			Debugging.printToConsole("--CM8PluginDelegate.loadWorkplan",initialized);
			video = null;
			if (!initialized)
			{
				timeoutTimer.reset();
				timeoutTimer.start();
				// Initialize and start advertising
				if ((Nana10PlayerData.getInstance().embededPlayer && ExternalParameters.getInstance().ArticleID!=833505 && !_local) 
					|| Nana10DataRepository.getInstance().previewGroupID)
				{	// except of a specific video embedded on Morfix, all other embedded players cannot use the echosphere
					plugin.initialize(this,ExternalParameters.getInstance().CM8Target,"nana10_playerID="+ExternalParameters.getInstance().PlayerID,null,"CM8Server=nana10.checkm8.com;CM8VideoIgnoreEcosphere=true");
				}
				else
				{
					plugin.initialize(this);
				}
			}
			videoLoaded();
			
			_videoStart = false;
			initialized = true;
		}
		
		
		private function onPluginLoadError(event:IOErrorEvent):void
		{
			var errorText:String = event ? event.text : "Timeout!";
			Debugging.printToConsole("--CM8PluginDelegate.onPluginLoadError",errorText);
			pluginError = true;
			StatsManagers.updatePlayerStats(StatsManagers.AdError,"Error loading CM8 plugin. "+errorText +" (CM8PluginDelegate.onPluginLoadError)");
			dispatchEvent(new PluginEvent(PluginEvent.PLUGIN_LOAD_ERROR));
			if (timeoutTimer.running) timeoutTimer.stop();
		}
		
		private function onTimeout(event:TimerEvent):void
		{
			onPluginLoadError(null);
		}
		
		// TODO: in live stream send the actuall timing from after the preroll ended, including buffering
		private function onTimer(event:TimerEvent):void
		{
			if (Nana10PlayerData.getInstance().isLive)
			{
				//if (_dev) Debugging.printToConsole("--CM8PluginDelegate.onProgress, 1000");
				dispatchEvent(new PlayerEvent(PlayerEvent.VIDEO_PROGRESS, 1000));
				return;
			}
			var currentTime:Number = Math.max(CommunicationLayer.getInstance().playheadTime,0);
			if (!isNaN(adStartTime) && currentTime < adStartTime) return; // after a midroll the player goes back 10 secs - making sure the midroll won't run again
			//if (_dev) Debugging.printToConsole("--CM8PluginDelegate.onProgress",currentTime * 1000);
			try
			{
				dispatchEvent(new PlayerEvent(PlayerEvent.VIDEO_PROGRESS, currentTime * 1000));
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--CM8PluginDelegate.onTimer error",e.message);
			}
		}
		
		public function dispose():void
		{
			if (_isRunning) videoPaused();
			timer.removeEventListener(TimerEvent.TIMER,onTimer);
			timer = null;
			timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeout);
			timeoutTimer = null;
			
			for (var type:String in eventListeners)
			{
				removeEventListener(type,eventListeners[type]);
			}
			pluginLoader.unloadAndStop(true);
			Debugging.printToConsole("--CM8PluginDelegate.dispose");
			try
			{
				while (_cm8PlaceHolder.numChildren)
				{
					_cm8PlaceHolder.removeChildAt(0);
				}
			}
			catch (e:Error)
			{
				Debugging.printToConsole("error:" + e.message);
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
		
		public function get isRunning():Boolean
		{
			return _isRunning;
		}

		public function get pluginLoaded():Boolean
		{
			return plugin != null;
		}
	}
}