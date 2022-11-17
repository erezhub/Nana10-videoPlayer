package com.ui.pannels
{
	import com.data.ExternalParameters;
	import com.events.Nana10PlayerEvent;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import resources.pannels.ShareButtonsVisuals;
	
	public class ShareButtons extends ShareButtonsVisuals
	{
		public function ShareButtons()
		{
			facebookBtn.addEventListener(MouseEvent.CLICK,onFacebook);
			twitterBtn.addEventListener(MouseEvent.CLICK,onTwitter);
			if (ExternalParameters.getInstance().EnableEmbed == 1)
			{
				embedBtn.addEventListener(MouseEvent.CLICK,onEmbed);
				embedDisabled.visible = false;
			}
		}
		
		private function onFacebook(event:MouseEvent):void
		{
			share("facebook");
		}
		
		private function onTwitter(event:MouseEvent):void
		{
			share("twitter");
		}		
		
		private function share(site:String):void
		{
			var domain:String = loaderInfo.url.indexOf("nana10.co.il") == -1 ? "http://www.nana10.co.il" : "";
			navigateToURL(new URLRequest(domain + "/Video/?VideoID="+ExternalParameters.getInstance().VideoID+"&ServiceID="+ExternalParameters.getInstance().ServiceID+"&TypeID=12&ShareType=" + site),"_blank");	
		}
		
		private function onEmbed(event:MouseEvent):void
		{
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.EMBED));
		}
	}
}