package com.data.cm8
{
	import com.checkm8.advantage.video.delegation.player.api.IPlugin;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Plugin extends EventDispatcher implements IPlugin
	{
		private var _wrapee:*;
		
		
		public function Plugin(wrapee:*) {
			_wrapee = wrapee;
		}
		
		public function initialize(delegate:*, 
								   channel:String = null, 
								   profile:String = null, 
								   playerID:String = null, 
								   configuration:String = null):void {
			_wrapee.initialize(delegate, channel, profile, playerID, configuration);
		}
		
		public function set channel(channel:String):void {
			_wrapee.channel = channel;
		}
		
		public function invokeAd(format:String):int {
			return _wrapee.invokeAd(format);
		}
		
		public function revokeAd(adID:int):void {
			_wrapee.revokeAd(adID);
		}
		
		public function terminateRunningAds():void
		{
			_wrapee.terminateRunningAds();
		}
		
		override public function addEventListener(type:String, 
												  listener:Function, 
												  useCapture:Boolean = false, 
												  priority:int = 0, 
												  useWeakReference:Boolean = false):void {
			_wrapee.addEventListener(type, listener, useCapture, priority, useWeakReference);	
		}
		
		override public function removeEventListener(type:String, 
													 listener:Function, 
													 useCapture:Boolean = false):void {
			_wrapee.removeEventListener(type, listener, useCapture);
		}
	}
}