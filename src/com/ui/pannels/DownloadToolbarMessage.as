package com.ui.pannels
{
	import com.adobe.utils.StringUtil;
	import com.data.stats.StatsManagers;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import resources.toolbarMessage.*;
	
	public class DownloadToolbarMessage extends Sprite
	{
		public function DownloadToolbarMessage(stageWidth:Number, stageHeight:Number)
		{
			var bg:Shape = ShapeDraw.drawGradiantRect(stageWidth,stageHeight,0xfdfdfd,0xd5d5d5);
			addChild(bg);
			
			var msg:Message = new Message();
			addChild(msg);
			DisplayUtils.align(bg,msg);
			
			var btn:DownloadBtn = new DownloadBtn();
			addChild(btn);
			DisplayUtils.align(bg,btn,true,false);
			btn.y = msg.height + msg.y + 30;
			if (btn.y + btn.height > stageHeight)
			{
				btn.y = stageHeight - btn.height - 20;
				msg.y = btn.y - msg.height - 20;
			}
			btn.addEventListener(MouseEvent.CLICK,onClick);	
			
			StatsManagers.updatePlayerStats(StatsManagers.ContentBlocked);
		}
		
		private function onClick(event:MouseEvent):void
		{
			var browser:String;
			var downloadURL:String = "http://CT3202343_Nana10.integration.download.conduit-services.com/Default.ashx?EnvironmentID=3";//"http://software.nana10.co.il/Software/DownloadIFrame.asp?SoftwareID=8760&LinkID=37662&isToInsert=1";
			/*try
			{
				browser = ExternalInterface.call((loaderInfo.url.indexOf("http") == -1 ? "" : "MediAnd.") + "getBrowserDetails");
				if (StringUtil.beginsWith(browser,"Chrome"))
				{
					downloadURL = "http://software.nana10.co.il/Software/DownloadIFrame.asp?SoftwareID=8760&LinkID=37664&isToInsert=1";
				}
				else if (StringUtil.beginsWith(browser,"Microsoft Internet Explorer "))
				{
					downloadURL = "http://software.nana10.co.il/Software/DownloadIFrame.asp?SoftwareID=8760&LinkID=37662&isToInsert=1";
				}
				else if (StringUtil.beginsWith(browser,"Firefox"))
				{
					downloadURL = "http://software.nana10.co.il/Software/DownloadIFrame.asp?SoftwareID=8760&LinkID=37663&isToInsert=1";
				}
				
			}
			catch (e:Error) {}*/
			navigateToURL(new URLRequest(downloadURL),"_top");
			StatsManagers.updatePlayerStats(StatsManagers.ToolbarDownloaded);
		}
	}
}