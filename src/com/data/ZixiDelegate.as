/**
 * this class is obsolte.
 * it was used by the player to load a backup link for live-stream, using a proxy installed on the client-side.
 * if the proxy isn't found (and the user is reluctant to install it), using a different back-up link.
 * 
 * anyhow, the third party which supplied this solution isn't availabel at this time
 */ 
package com.data
{
	import com.events.Nana10PlayerEvent;
	import com.events.RequestEvents;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.MathUtils;
	import com.io.DataRequest;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	
	public class ZixiDelegate extends EventDispatcher
	{
		public function ZixiDelegate()
		{
			
		}
		
		public function isProxyInstalled():void
		{
			Debugging.printToConsole("--ZixiDelegate.isProxyInstalled");
			var versionRequest:DataRequest = new DataRequest();
			versionRequest.addEventListener(RequestEvents.DATA_ERROR,onProxyMissing);
			versionRequest.addEventListener(RequestEvents.DATA_READY,onProxyFound);
			versionRequest.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onProxyMissing);
			versionRequest.load("http://127.0.0.1:4500/version.htm");
		}
		
		private function onProxyFound(event:RequestEvents):void
		{
			Debugging.printToConsole("--ZixiDelegate.onProxyFound");
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.ZIXI_PROXY_FOUND));
		}
		
		private function onProxyMissing(event:Event):void
		{
			Debugging.printToConsole("--ZixiDelegate.onProxyMissing");
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.ZIXI_PROXY_MISSING));	
		}
		
		public function get userData():String
		{
			var output:String = "FLV_";
			var identifier:String;
			var index:int;
			try
			{
				var so:SharedObject = SharedObject.getLocal("zx");
				if (so.data.guid == null)
				{
					so.data.guid = identifier = ExternalParameters.getInstance().SessionID;
					so.data.index = index = 1;
				}
				else
				{
					identifier = so.data.guid;
					index = so.data.index + 1;
					so.data.index = index;
				}
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--ZixiDelegate.userData error",e.message);
				identifier = ExternalParameters.getInstance().SessionID;
				index = MathUtils.randomInteger(1000,1000000);
			}
			return output + identifier + "_" + index;
		}
		
	}
}