/**
 * this class is used for cases where the user re-watches content which he/she didn't watch till its end.
 * in such cases - the user is prompted to keep watching from the point he/she left the content, or to start from the begining.
 * if user ignores it for 20 seconds, the content begins from start
 */ 
package com.ui.pannels
{	
	import com.events.Nana10PlayerEvent;
	import com.fxpn.display.ModalManager;
	import com.fxpn.util.DisplayUtils;
	import com.fxpn.util.StringUtils;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import resources.ResumeVideoVisuals;
	
	public class ResumeVideoWindow extends ResumeVideoVisuals
	{
		private var timer:Timer;
		
		public function ResumeVideoWindow(lastTimecode:Number)
		{
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			noBtn.addEventListener(MouseEvent.CLICK,onResumeFromStart);
			yesBtn.addEventListener(MouseEvent.CLICK,onResumeFromLast);
			lastTC_txt.text = StringUtils.turnNumberToTime(lastTimecode,true,true,false,false);
			
			timer = new Timer(20000,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
		}
		
		private function onAddedToStage(event:Event):void
		{
			DisplayUtils.align(stage,this);
			ModalManager.setModal(this);
			timer.start();
		}
		
		private function onResumeFromStart(event:MouseEvent):void
		{
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.RESUME_FROM_START));
			visible = false;
			ModalManager.clearModal();
			if (timer.running) timer.stop();
		}
		
		private function onResumeFromLast(event:MouseEvent):void
		{
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.RESUME_FROM_LAST));
			visible = false;
			ModalManager.clearModal();
			timer.stop();
		}
		
		private function onTimer(event:TimerEvent):void
		{
			onResumeFromStart(null);
		}
	}
}