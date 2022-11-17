/**
* this class servers as a preloader for the Nana10 player 
*/
package
{
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.system.Security;
	
	import resources.LoadingAnimation;
	
	
	[SWF (backgroundColor=0xffffff)]
	public class Nana10Preloader extends Sprite
	{
		private var loadingAnimation:LoadingAnimation;
		private var url:String;
		
		public function Nana10Preloader()
		{
			stage.frameRate = 30;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			Security.allowDomain("*")
			addEventListener(Event.ENTER_FRAME, onInit);			
		}
		
		private function onInit(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onInit);
			
			// add the loading animation to the stage
			loadingAnimation = new LoadingAnimation();
			addChild(loadingAnimation);
			DisplayUtils.align(stage,loadingAnimation);
			
			// find out the path to the current swf
			url = loaderInfo.url;
			var i:int = url.lastIndexOf("/");
			url = url.substr(0,i);
			
			// get the path to the player through the FlashVars
			var pathToSWF:String = loaderInfo.parameters.PlayerSWFPath;
			if (pathToSWF == null)
			{	// if not available it means the player is playing in embed mode - load the version file
				loadVersion();
			} 
			else
			{	// load the player
				loadPlayer(pathToSWF);
			}
			
		}
		
		// the version.txt file, found next to the prelaoder, contains only the number of the playear's recent version.
		// the version.txt isn't loaded from the cache, so its data is relyable
		private function loadVersion():void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onVersionLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onVersionError);
			var versionURL:String = url + "/Version.txt?r=" + Math.random(); // load it using random parameter, thus avoiding cache
			urlLoader.load(new URLRequest(versionURL));
		}
		
		// get the current player's version from the txt file and load that player
		private function onVersionLoaded(event:Event):void
		{	
			var playerPath:String = url + "/Nana10Player.swf?Version=" + event.target.data;
			loadPlayer(playerPath);
		}
		
		// version.txt can't be loaded - load the player without a version number (might be loaded from cache)
		private function onVersionError(event:IOErrorEvent):void
		{
			var playerPath:String = url + "/Nana10Player.swf";
			loadPlayer(playerPath);
		}
		
		// load the recent player
		private function loadPlayer(path:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(new URLRequest(path));	
		}
		
		// update the numbers in the loading animation
		private function onProgress(event:ProgressEvent):void
		{
			if (event.bytesTotal)
			{
				loadingAnimation.progress_txt.text = Math.round(100 * event.bytesLoaded / event.bytesTotal) + "%";
			}
		}
		
		// player is loaded
		private function onLoaded(event:Event):void
		{
			var player:DisplayObject = event.target.content as DisplayObject;
			addChild(player);
			removeChild(loadingAnimation);
		}
		
		// player can't be loaded
		private function onError(event:IOErrorEvent):void
		{
			Debugging.alert("שגיאה בטעינת הנגן \n" + event.text);
		}		
		
	}
	
	
}