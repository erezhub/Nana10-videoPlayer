/**
 * the ad-strip is displayed above the video at the top of the screen while ads are running, and also 3 seconds before they start running.
 * it is also used to display error messages to the user 
*/
package com.ui.ads
{
	import com.data.CommunicationLayer;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	
	import resources.AdStripVisuals;

	public class AdStrip extends AdStripVisuals 
	{
		private var countdown:Timer;
		private var _preAd:Boolean;
		private var _duration:int;
		private var fading:Boolean;
		private var flashTimer:Timer;
		private var currentText:DisplayObject;
		
		//public var videoPlayer:MediandVideoPlayer;
		
		public function AdStrip()
		{
			visible = false;
			closeBtn.addEventListener(MouseEvent.CLICK, onClose);
			flashTimer = new Timer(500,16); // flash no more than 8 seconds
			flashTimer.addEventListener(TimerEvent.TIMER,onFlash);
			flashTimer.addEventListener(TimerEvent.TIMER_COMPLETE,removePreAdMessage);
			//countdown = new Timer(1000);
			//countdown.addEventListener(TimerEvent.TIMER, onCountdown);						
		}
		
		private function onClose(event:MouseEvent):void
		{
			visible = false;
			//countdown.stop();
		}
		
		private function onFlash(event:TimerEvent):void
		{
			currentText.visible = !currentText.visible;
		}
		
		private function onCountdown(event:TimerEvent):void
		{
			/*if (_preAd)
			{   // countdown till the ad begins
				if (_duration > 1)
				{
					message_txt.text = "...יוצאים להפסקה קלה בעוד "+ (_duration--) +" שניות";
				}
				else if (_duration == 1)
				{
					message_txt.text = "...יוצאים להפסקה קלה בעוד שניה"
				}
				else
				{
					countdown.stop();
					visible = false;
				}
			}
			else if (CommunicationLayer.getInstance().videoPlayer.name == "mainPlayer")
			{
				countdown.stop();
				visible = false;
			}
			else
			{   // countdown till the ad ends
				_duration = CommunicationLayer.getInstance().videoDuration - CommunicationLayer.getInstance().playheadTime;
				if (_duration > 1)
				{
					message_txt.text = "...ההפסקה תסתיים בעוד "+ (_duration) +" שניות";
				}
				else if (_duration == 1)
				{
					message_txt.text = "...ההפסקה תסתיים בעוד שניה";
					_duration;
				}
				else
				{
					countdown.stop();
					fadeOut();	
				}
			}*/
		}
		
		private function fadeOutComplete():void
		{
			visible = false;
			alpha = 1;
			fading = false;
		}
		
		public function fullScreenToggle():void
		{
			width = stage.stageWidth;
		}
		
		// display the ad-strip and start count-down
		public function displayPreAdMessage(duration:int):void
		{			
			if (duration)
			{
				text_mc.duration_txt.text = String(duration);
				text_mc.visible = true;
				message_txt.visible = false;
				currentText = text_mc;
			}
			else
			{
				text_mc.visible = false;
				message_txt.visible = true;
				message_txt.text = "מיד יוצאים להפסקת פרסומת";
				currentText = message_txt;
			}
			DisplayUtils.align(bg,currentText);
			if (!visible)
			{						
				TweenLite.from(this,0.3,{alpha: 0});
				visible = true;
			}
			flashTimer.reset();
			flashTimer.start();
			/*_preAd = preAd;
			if (preAd)
			{ 
				_duration = 3;
				
			}
			else
			{
				TweenLite.to(this,0.3,{alpha: 0, onComplete: fadeOutComplete});
			}
			countdown.reset();
			//countdown.start();
			//onCountdown(null);*/
			CommunicationLayer.getInstance().enableSeek = false;
		}
		
		public function removePreAdMessage(event:TimerEvent = null):void
		{
			flashTimer.stop();
			visible = false;
			if (event) CommunicationLayer.getInstance().enableSeek = true;
		}
				
		/**
		 * display error message 
		 * @param text message to display
		 * @param remove when true strip is removed after 3 seconds
		 * 
		 */		
		public function error(text:String = "שגיאה בטעינת הפרסומת", remove:Boolean = true):void
		{
			message_txt.text = text;
			visible = true;
			text_mc.visible = false;
			message_txt.visible = true;			
			currentText = message_txt;
			DisplayUtils.align(bg,currentText);
			if (remove)
			{
				TweenLite.to(this,0.3,{alpha: 0, onComplete: fadeOutComplete, delay: 3});
				fading = true;
			}
			else
			{
				closeBtn.visible = false;
			}
			flashTimer.stop();
			//countdown.stop();
		}
		
		// pause the countdown
		public function pause():void
		{
			if (visible)
			{ 
				//countdown.stop();
			}
		}
		
		// resume the countdown
		public function resume():void
		{
			if (visible) {
				//countdown.start();
			}
		}
		
		public function fadeOut():void
		{
			if (!fading) TweenLite.to(this,1,{alpha: 0, onComplete: fadeOutComplete});
		}
		
		override public function set width(value:Number):void
		{
			bg.width = value;
			DisplayUtils.align(bg,currentText);
		}
		
	}
}