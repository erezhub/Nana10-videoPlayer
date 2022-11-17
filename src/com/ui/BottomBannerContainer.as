package com.ui
{
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	public class BottomBannerContainer extends Sprite
	{
		private var loader:Loader;
		public function BottomBannerContainer()
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			//addChild(loader);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{	
			var exParams:ExternalParameters = ExternalParameters.getInstance();
			Debugging.printToConsole("--BottomBannerContainer.onAddedToStage",exParams.AdUrl);
			var banner:String = exParams.AdUrl == undefined ? "http://f"+CommunicationLayer.getInstance().environment+".nanafiles.co.il/Common/Flash/PlayerNavigationBar.swf?r=" + getTimer() : exParams.AdUrl;
			loader.load(new URLRequest(banner))	
		}
		
		private function onLoaded(event:Event):void
		{
			Debugging.printToConsole("--BottomBannerContainer.onLoaded");
			var NavBarClass:Class = event.target.applicationDomain.getDefinition("PlayerNavigationBar") as Class;
			var navBar:Object = new NavBarClass();
			var cm8Profile:String = Nana10PlayerData.getInstance().embededPlayer ? "" : ExternalParameters.getInstance().CM8Profile;
			navBar.loadData(ExternalParameters.getInstance().CM8Target,cm8Profile);
			addChild(navBar as DisplayObject);
			DisplayUtils.align(stage,this,true,false);
		}
		
		private function onError(event:IOErrorEvent):void
		{
			Debugging.printToConsole("--BottomBannerContainer.onError",event.text);
		}
	}
}