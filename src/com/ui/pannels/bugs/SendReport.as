package com.ui.pannels.bugs
{
	import com.events.Nana10PlayerEvent;
	import com.fxpn.display.ModalManager;
	
	import flash.events.MouseEvent;
	
	import resources.pannels.SendReportVisuals;
	
	public class SendReport extends SendReportVisuals
	{
		public function SendReport()
		{
			close_btn.addEventListener(MouseEvent.CLICK,onClose);
			noBtn.addEventListener(MouseEvent.CLICK,onClose);
			yesBtn.addEventListener(MouseEvent.CLICK,onSend);
		}
		
		private function onSend(event:MouseEvent):void
		{			
			visible = false;
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.SEND_BUG_REPORT));
		}
		
		private function onClose(event:MouseEvent):void
		{			
			visible = false;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (value)
			{
				ModalManager.setModal(this);
			}
			else
			{
				ModalManager.clearModal();
			}
		}
	}
}