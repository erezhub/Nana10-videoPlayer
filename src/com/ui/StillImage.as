package com.ui
{
	import com.data.ExternalParameters;
	import com.data.stats.StatsManagers;
	import com.data.Version;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	

	public class StillImage extends Sprite
	{
		private var stillImageLoader:Loader;
		private var imageURL:String;
		private var imageWidth:Number;
		private var imageHeight:Number;
		private var _locked:Boolean;
		
		public function StillImage()
		{
			stillImageLoader = new Loader();
			stillImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onStillImageLoaded);
			stillImageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onStillImageError)
			imageURL = ExternalParameters.getInstance().StillImageUrl;
			if (imageURL != null && imageURL.length)
			{
				loadImage(imageURL);
			} 
		}
		
		public function loadImage(url:String, locked:Boolean = false):void
		{
			if (_locked) return;
			stillImageLoader.unload();
			stillImageLoader.load(new URLRequest(url),new LoaderContext(true));
			_locked = locked;
		}
		
		// adding still image to the stage
		private function onStillImageLoaded(event:Event):void
		{
			try
			{
				var image:DisplayObject = event.target.content as DisplayObject
			}
			catch (e:Error)
			{
				Debugging.printToConsole("StillImage - error loading image: ", e.message);
				StatsManagers.updatePlayerStats(StatsManagers.StillImageError,"error loading still image. " + e.message+": "+ imageURL + " "+Version.VERSION + "(StillImage.onStillImageLoaded)");
				return;
			}
			if (numChildren) removeChildAt(0); // remove previous still image (relevant when video ends and selecting another one)
			addChild(image);
			Debugging.printToConsole("StillImage.onStillImageLoaded");
			this.x = this.y = 0;
			DisplayUtils.resize(this,imageWidth,imageHeight,true,true,true);
			//visible = true;
		}
		
		private function onStillImageError(event:IOErrorEvent):void
		{
			Debugging.printToConsole("StillImage - error loading image: ", event.text);
			StatsManagers.updatePlayerStats(StatsManagers.StillImageError,"error loading still image. "+event.text+": "+imageURL + " "+Version.VERSION +" (StillImage.onStillImageError)");
		}
		
		public function setDimensions(width:Number, height:Number):void
		{
			imageWidth = width;
			imageHeight = height;
		}
		
	}
}