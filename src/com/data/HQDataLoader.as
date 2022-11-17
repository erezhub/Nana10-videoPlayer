package com.data
{
	import com.fxpn.util.Debugging;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class HQDataLoader extends EventDispatcher
	{
		private var timer:Timer;
		
		public function HQDataLoader()
		{
			Debugging.printToConsole("--HQDataLoader");			
			timer = new Timer(15000,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeout);
		}
		
		public function loadHQData():void
		{
			// loading the path to the HQ video files
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onHQDataReady);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onHQDataError);
			urlLoader.load(new URLRequest(Nana10DataRepository.getInstance().videoLinkHQ + "&curettype=1"));
			
			timer.reset();
			timer.start();
		}
		
		private function onHQDataReady(event:Event):void
		{
			Debugging.printToConsole("--HQDataLoader.onHQDataReady");
			timer.stop();
			if (Nana10DataRepository.getInstance().videoLinkHQ.indexOf("gmpl.aspx") == -1)
			{
				CastUpXMLParser.setHQLinks(event.target.data);
			}
			else
			{
				CastUpXMLParser.parseXML(new XML(event.target.data),0,true);
			}
			dispatchEvent(event.clone());
		}
		
		private function onHQDataError(event:IOErrorEvent):void
		{
			Debugging.printToConsole("--HQDataLoader.onHQDataError");
			timer.stop();
			dispatchEvent(event.clone());	
		}
		
		private function onTimeout(event:TimerEvent):void
		{
			Debugging.printToConsole("--HQDataLoader.onTimeout");
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
	}
}