// the volume control is made of 2 elements: the mute toggle button, and the volume-level slider.  once rolling over the button the slider appears.
package com.ui.controls
{
	import com.events.Nana10PlayerEvent;
	import com.events.VideoControlsEvent;
	import com.fxpn.display.TooltipFactory;
	import com.ui.Nana10VideoPlayer;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	
	import gs.TweenLite;
	import gs.easing.Circ;
	import gs.easing.Cubic;
	
	import mx.events.MoveEvent;
	
	import resources.controls.VolumeControlsVisuals;
	
	[Event (name="volumeChanged", type="com.events.Nana10PlayerEvent")]		
	public class VolumeControl extends VolumeControlsVisuals
	{		
		private var _muteBtn:MovieClip;
		private var _volumeSlider:MovieClip;
		private var _sliderMask:MovieClip;
		private var _videoPlayer:Nana10VideoPlayer;
		private var volumeDragRect:Rectangle;
		private var volumeLevelSO:SharedObject;
		private var volumeSliderTween:TweenLite;
		private var tweenDuration:Number = 0.4;
		private var ease:Function = Cubic.easeIn;
		private var draggingVolume:Boolean;
		private var origVolumeY:Number;
		private var premuteVolumeLevel:Number;
		
		public function VolumeControl()
		{
			for (var i:int = 1; i < 6; i++)
			{
				var bar:MovieClip = volumeBar["bar" + i]; 
				bar.buttonMode = true;
				bar.addEventListener(MouseEvent.ROLL_OVER,onOverBar);
				bar.addEventListener(MouseEvent.CLICK,onClickBar);
			}
			muteBtn.addEventListener(MouseEvent.CLICK,onToggleMute);
		}
		
		public function init():void
		{
			try
			{
				volumeLevelSO = SharedObject.getLocal("vl");
			}
			catch (e:Error) {}
			var index:int;
			if (volumeLevelSO == null || volumeLevelSO.data.l == undefined)
			{
				index = 3;
			}
			else
			{
				index = volumeLevelSO.data.l / 0.2;
			}
			for (var j:int = 1; j <= index; j++)
			{
				volumeBar["bar" + j].gotoAndStop("on");
			}
			updateVolume(index);
		}
		
		private function onOverBar(event:MouseEvent):void
		{
			var scale:Number = 2.2 - parseInt((event.target.name as String).charAt(3))*0.2;
			TweenLite.to(event.target,0.3,{scaleY: scale, onComplete: resetBar, onCompleteParams: [event.target as MovieClip], ease: ease});
		}
		
		private function resetBar(bar:MovieClip):void
		{
			TweenLite.to(bar,0.3,{scaleY: 1, ease: ease});
		}
		
		private function onClickBar(event:MouseEvent):void
		{
			var bar:MovieClip = event.target as MovieClip;
			var index:int = parseInt(bar.name.charAt(3));
			if (bar.currentLabel == "off")
			{
				for (var i:int = 1; i <= index; i++)
				{
					volumeBar["bar" + i].gotoAndStop("on");
				}
				muteBtn.gotoAndStop("off");
			}
			else
			{
				for (var j:int = 5; j >= index; j--)
				{
					volumeBar["bar" + j].gotoAndStop("off");
				}
				index = j;
			}
			updateVolume(index);
		}		
		
		private function onToggleMute(event:MouseEvent):void
		{
			var index:int;
			if (muteBtn.currentLabel == "on")
			{   // mute 
				for (var i:int = 1; i <= 5; i++)
				{
					if (volumeBar["bar" + i].currentLabel == "on") premuteVolumeLevel = i*0.2;
					volumeBar["bar" + i].gotoAndStop("off");
				};
				index = 0;
			}
			else
			{   // unmute
				for (var j:int = 1; j <= 5; j++)
				{
					if (isNaN(premuteVolumeLevel) || j <= premuteVolumeLevel/0.2)
					{
						volumeBar["bar" + j].gotoAndStop("on");
						index = j;
					}
				}
			}
			updateVolume(index);
		}
				
		// changing the volume (can be called from the key-board shortcuts manager - thus public)
		public function changeVolume(direction:Boolean):void
		{
			var index:int;
			if (direction) // up
			{
				index = 5;
				for (var i:int = 1; i <= 5; i++)
				{
					if (volumeBar["bar" + i].currentLabel == "off")
					{
						volumeBar["bar" + i].gotoAndStop("on");
						index = i;
						break;
					}
				}
			}
			else // down
			{
				for (var j:int = 5; j >= 1; j--)
				{
					if (volumeBar["bar" + j].currentLabel == "on")
					{
						volumeBar["bar" + j].gotoAndStop("off");
						index = Math.max(0,j-1);
						break;
					}
				}
			}
			updateVolume(index);
		}
		
		private function updateVolume(barIndex:int):void
		{
			if (volumeLevelSO) volumeLevelSO.data.l = barIndex * 0.2;
			if (barIndex == 0)
			{	// if slider is close to the bottom - display 'mute' icon
				muteBtn.gotoAndStop("off");
			}
			else
			{
				muteBtn.gotoAndStop("on");
			}
			var videoControlsEvent:VideoControlsEvent = new VideoControlsEvent(VideoControlsEvent.CHANGE_VOLUME);
			videoControlsEvent.volumeLevel = volumeLevelSO ?  volumeLevelSO.data.l : barIndex*0.2;
			dispatchEvent(videoControlsEvent);
		}
				
		private function displayVolumeTooltip():void
		{
			TooltipFactory.getInstance().dispalyTooltip("(עוצמת קול (מקשי החיצים למעלה/מטה",this);
		}
	}
}