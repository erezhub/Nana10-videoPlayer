package com.ui.pannels.bugs
{
	import com.KeyboardShortcutsMangaer;
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.StringUtil;
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.data.Version;
	import com.events.Nana10PlayerEvent;
	import com.events.RequestEvents;
	import com.fxpn.display.ModalManager;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	import com.io.DataRequest;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequestMethod;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import resources.pannels.BugReportingVisuales;
	
	public class BugReporting extends BugReportingVisuales
	{
		private var closeTimer:Timer;
		
		public function BugReporting()
		{
			close_btn.addEventListener(MouseEvent.CLICK,onClose);
		}
		
		public function init():void
		{
			visible = true;
			ModalManager.setModal(this);
			KeyboardShortcutsMangaer.disableKeyboardShortcuts();
		}
		
		private function onClose(event:Event):void
		{
			visible = false;
			gotoAndStop(1);
			ModalManager.clearModal();
			KeyboardShortcutsMangaer.enableKeyboardShortcuts();
			if (closeTimer && closeTimer.running) closeTimer.stop();
			desc_txt.tabEnabled = mail_txt.tabEnabled = true;
			desc_txt.tabIndex = 1;
			mail_txt.tabIndex = 2;
		}
		
		private function onSend(event:MouseEvent):void
		{
			sendReport();
			gotoAndStop(2);
			if (closeTimer == null)
			{
				closeTimer = new Timer(5000,1);
				closeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onClose);
			}
			closeTimer.reset();
			closeTimer.start();			
		}
		
		public function sendReport(bugData:String = null):void
		{
			var dataRequest:DataRequest = new DataRequest();
			dataRequest.addEventListener(RequestEvents.DATA_READY,onDataSent);
			dataRequest.addEventListener(RequestEvents.DATA_ERROR,onDataError);
			var from:String = mail_txt.text;
			if (StringUtils.isStringEmpty(from) || StringUtils.isValidEmail(from) == false)
			{
				from = "VideoPlayer@nana10.net.il";
			}
			//dataRequest.requesetContentType = "application/json; charset=utf-8";
			var data:String = "<font face=\"Arial\"><u><b>Data generated from the player</b></u><br>";
			if (ExternalParameters.getInstance().DefaultNickName != undefined)
			{
				data = data.concat("<b>Nana10 UserName:</b>  " + unescape(ExternalParameters.getInstance().DefaultNickName) + "<br>");
			}
			data = data.concat("<b>User's mail:</b> " + (from == "VideoPlayer@nana10.net.il" ? "anonymous" : from) + "<br>");			
			if (bugData)
			{
				data = data.concat("<b>Bug description:</b><br>" + bugData + "<br>");	
			}
			else if (StringUtils.isStringEmpty(desc_txt.text) == false)
			{
				data = data.concat("<b>Bug description:</b><br>" + desc_txt.text + "<br>");
			}
			data = data.concat("embedded player:      " + Nana10PlayerData.getInstance().embededPlayer+"<br>");
			data = data.concat("live stream:          " + Nana10PlayerData.getInstance().isLive + "<br>");
			data = data.concat("share link:           " + unescape(ExternalParameters.getInstance().ShareLink) + "<br>");
			data = data.concat("title:				  " + ExternalParameters.getInstance().Title + "<br>");
			data = data.concat("OS:                   " + Capabilities.os+"<br>");
			data = data.concat("Flash Player type:    " + Capabilities.playerType + "<br>");
			data = data.concat("Flash Player version: " + Capabilities.version + "<br>");
			data = data.concat("Player version:       " + Version.VERSION + "<br>");
			data = data.concat("Player dimensions:    " + stage.stageWidth + " X " + stage.stageHeight + "<br>");
			data = data.concat("Screen Resolution:    " + Capabilities.screenResolutionX + " X " + Capabilities.screenResolutionY + "<br>");
			if (Nana10PlayerData.getInstance().embededPlayer == false)
			{
				try
				{
					data = data.concat("User's Browser: " + ExternalInterface.call("MediAnd.getBrowserDetails") + "<br>");						
				}
				catch (e:Error) {}
			}
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.GET_LOADING_SPEED));
			data = data.concat("-------------------<br>");
			data = data.concat("<b>Console Data:</b><br>");
			var console:String = Debugging.console;
			for (var i:int = 0; i < console.length; i++)
			{
				if (console.charCodeAt(i) == Keyboard.ENTER)
				{
					console = console.substr(0,i) + "<br>" + console.substr(i);
					i+=4;
				}
			}
			data = data.concat(console + "<br>");			
			
			
			// adding verification - encrypting the current time, and on the server-side making sure the request was made in the last 5 minutes
			var now:Date = new Date();
			var delta:int = now.hours - now.hoursUTC;
			now.hours+=delta;
			var nowArr:Array = String(now.time).split("");
			for (var j:int = 0; j < nowArr.length; j++)
			{
				nowArr[j] = 9 - parseInt(nowArr[j]);
			}
			dataRequest.requestData = "Data="+escape(data)+"&From="+from+"&Verification="+ nowArr.join("");
			dataRequest.requestMethod = URLRequestMethod.POST;
			dataRequest.load(CommunicationLayer.getInstance().actionsServer + "SendErrorReport");
			
			Debugging.printToConsole("sending bug report");
			StatsManagers.updatePlayerStats(StatsManagers.BugReport,desc_txt.text);
		}
		
		private function onDataSent(event:RequestEvents):void
		{
			if (String(event.xmlData.ActionSucceeded).toLocaleLowerCase() == "true")
			{
				Debugging.printToConsole("bug report sent successfully",event.xmlData.ActionSucceeded);
			}
			else
			{
				Debugging.printToConsole("bug report failed",event.xmlData.ErrorDescription);
			}
		}
		
		private function onDataError(event:RequestEvents):void
		{
			Debugging.printToConsole("bug report error",event.errorMessage);
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (value)
			{				
				send_btn.addEventListener(MouseEvent.CLICK,onSend);
			}
		}
	}
}