package com.data
{
	import com.adobe.images.JPGEncoder;
	import com.fxpn.util.Debugging;
	import com.ui.MediandVideoPlayer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class ImageSnapper
	{
		private var vp:MediandVideoPlayer;
		private var fr:FileReference;
		private var vpWidth:Number;
		private var vpHeight:Number;
		
		public function ImageSnapper(videoPlayer:MediandVideoPlayer)
		{
			vp = videoPlayer;
			fr = new FileReference();
			fr.addEventListener(Event.COMPLETE,onSaved);
			fr.addEventListener(Event.CANCEL,onCancel);
			fr.addEventListener(IOErrorEvent.IO_ERROR,onError);
		}
		
		public function saveImage(event:Event):void
		{
			vpWidth = vp.width;
			vpHeight = vp.height;
			if (vp.width < vp.contentWidth || vp.height < vp.contentHeight)
			{
				vp.width = vp.contentWidth;
				vp.height = vp.contentHeight;
			}
			var sourceBmd:BitmapData = new BitmapData(vp.width,vp.height);			
			sourceBmd.draw(vp,new Matrix(vp.contentWidth/vpWidth,0,0,vp.contentHeight/vpHeight));
			var jpgEncoder:JPGEncoder = new JPGEncoder(80);
			var byteArray:ByteArray = jpgEncoder.encode(sourceBmd);
			try
			{
				fr.cancel();
				fr.save(byteArray,"posterImage.jpg");	
			}
			catch (e:Error)
			{
				Debugging.alert("תקלה בשמירת התמונה: ",e.message);
				resetVideo();		
			}			
		}
		
		private function onSaved(event:Event):void
		{
			Debugging.printToConsole("התמונה נשמרה בהצלחה");
			//var s:String = ExternalInterface.call("window.location.href.toString");
			ExternalInterface.call("VEP.editPosterImage");
			resetVideo();
		}
		
		private function onCancel(event:Event):void
		{
			resetVideo();
		}		
		
		private function onError(event:IOErrorEvent):void
		{
			Debugging.alert("תקלה בשמירת התמונה");
			resetVideo();
		}
		
		private function resetVideo():void
		{
			vp.width = vpWidth;
			vp.height = vpHeight;
		}
	}
}