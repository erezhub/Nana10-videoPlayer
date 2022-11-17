package com.ui.pannels
{
	import com.data.ZixiDelegate;
	import com.events.Nana10PlayerEvent;
	import com.fxpn.display.ModalManager;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import resources.ZixiVisuals;
	
	public class ZixiDownload extends ZixiVisuals
	{
		private var zixiDelegate:ZixiDelegate;
		private var installTimer:Timer;
		
		public function ZixiDownload()
		{
			Debugging.printToConsole("--ZixiDownload");
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			close_btn.addEventListener(MouseEvent.CLICK,onClose);
			continue_btn.addEventListener(MouseEvent.CLICK,onClose);
			install_btn.addEventListener(MouseEvent.CLICK,onInstall);
		}
		
		private function onAddedToStage(event:Event):void
		{
			DisplayUtils.align(stage,this);
			ModalManager.setModal(this);
		}
		
		private function onInstall(event:MouseEvent):void
		{
			Debugging.printToConsole("--ZixiDownload.onInstall");
			gotoAndStop(2);
			zixiDelegate = new ZixiDelegate();
			zixiDelegate.addEventListener(Nana10PlayerEvent.ZIXI_PROXY_FOUND,onZixiProxyFound);
			installTimer = new Timer(10000);
			installTimer.addEventListener(TimerEvent.TIMER,onInstallTimer);
			installTimer.start();
			
			navigateToURL(new URLRequest("http://software.nana10.co.il/Software/?SoftwareID=8973"),"_blank");
		}
		
		private function onInstallTimer(event:TimerEvent):void
		{
			zixiDelegate.isProxyInstalled();
		}
		
		private function onZixiProxyFound(event:Nana10PlayerEvent):void
		{
			Debugging.printToConsole("--ZixiDownload.onZixiProxyFound");
			installTimer.stop();
			visible = false;
			ModalManager.clearModal();
			dispatchEvent(event);
		}
		
		private function onClose(event:MouseEvent):void
		{
			Debugging.printToConsole("--ZixiDownload.onClose");
			visible = false;
			ModalManager.clearModal();
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.ZIXI_CONTINUE));
		}
		
		public function clear():void
		{
			gotoAndStop(1);
			if (installTimer)
			{
				if (installTimer.running) installTimer.stop();
				installTimer.removeEventListener(TimerEvent.TIMER,onInstallTimer);
				installTimer = null;
			}
			visible = false;
			ModalManager.clearModal();
		}
	}
}