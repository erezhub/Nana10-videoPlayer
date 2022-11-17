package com.ui.pannels
{
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.events.Nana10PlayerEvent;
	import com.fxpn.display.ModalManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	
	import mx.messaging.AbstractConsumer;
	
	import resources.pannels.ShareWindowVisuals;
	
	public class ShareWindow extends ShareWindowVisuals
	{
		public function ShareWindow()
		{
			closeBtn.addEventListener(MouseEvent.CLICK, onCloseWindow);
			copyEmded.addEventListener(MouseEvent.CLICK, onCopyEmbed);
			copyLink.addEventListener(MouseEvent.CLICK, onCopyLink);
			
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			CommunicationLayer.getInstance().addEventListener(Nana10PlayerEvent.EMBED,onToggle);
		}
		
		private function onAddedToStage(event:Event):void
		{
			var params:ExternalParameters = ExternalParameters.getInstance();
			var videoId:int = parseInt(params.VideoID);
			var articleId:int = parseInt(params.ArticleID);
			var sectionID:int = parseInt(params.SectionID);
			var categoryID:int = parseInt(params.CategoryID);
			var hiroRatio:int = parseInt(params.HiroRatio);
			if (articleId == 0 && sectionID == 0 && categoryID == 0)
			{	// in order to display the embed code at least one of those id's is required
				embed_txt.text = "שגיאה בהצגת קוד";
				copyEmded.removeEventListener(MouseEvent.CLICK, onCopyEmbed);
			}
			else
			{
				var url:String = stage.loaderInfo.url
				var playerSWFPath:String = url.substr(0,url.lastIndexOf("/"));
				embed_txt.text = "<object width=\"448\" height=\"366\"><param name=\"movie\" value=\""+playerSWFPath+"/Nana10Preloader.swf\"/><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"flashvars\" value=\"VideoID="+videoId+"&ArticleID="+articleId+"&SectionID="+sectionID+"&CategoryID="+categoryID+"&HiroRatio="+hiroRatio+"\"/><embed src=\""+playerSWFPath+"/Nana10Preloader.swf\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"448\" height=\"366\" flashvars=\"VideoID="+videoId+"&ArticleID="+articleId +"&SectionID="+sectionID+"&CategoryID="+categoryID+"&HiroRatio="+hiroRatio+"\"/></object>";
			}		
			link_txt.text = unescape(params.ShareLink);
			
			embed_txt.addEventListener(MouseEvent.CLICK, onMarkText);
			link_txt.addEventListener(MouseEvent.CLICK, onMarkText);
		}
		
		private function onCloseWindow(event:MouseEvent):void
		{
			visible = false;
		}
		
		private function onCopyEmbed(event:MouseEvent):void
		{
			System.setClipboard(embed_txt.text);
		}
		
		private function onCopyLink(event:MouseEvent):void
		{
			System.setClipboard(link_txt.text);
		}		
		
		// mark the text for selection as the user clicks it
		private function onMarkText(event:MouseEvent):void
		{
			var tf:TextField = event.target as TextField; 
			tf.setSelection(0, tf.length); 
		}
		
		private function onToggle(event:Nana10PlayerEvent):void
		{
			visible = !visible;
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