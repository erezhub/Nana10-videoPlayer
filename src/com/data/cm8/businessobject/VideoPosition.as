package com.data.cm8.businessobject
{
	import com.checkm8.advantage.video.delegation.player.api.businessobject.IVideoPosition;
	import com.data.CommunicationLayer;
	import com.fxpn.util.Debugging;
	import com.ui.Nana10VideoPlayer;
	
	public class VideoPosition implements IVideoPosition
	{
		private static var _fullScreen:Boolean;
		private var _videoPlayer:Nana10VideoPlayer;
		
		public function VideoPosition()
		{
			_videoPlayer = CommunicationLayer.getInstance().videoPlayer;
		}
		
		public function get x():Number
		{
			return _videoPlayer.x;
		}
		
		public function get y():Number
		{
			return _videoPlayer.y;
		}
		
		public function get height():Number
		{
			return _videoPlayer.height;
		}
		
		public function get width():Number
		{
			return _videoPlayer.width;
		}
		
		public function get fullscreen():Boolean
		{
			return _fullScreen;
		}
		
		public static function set fullScreen(value:Boolean):void
		{
			_fullScreen = value;
		}
	}
}