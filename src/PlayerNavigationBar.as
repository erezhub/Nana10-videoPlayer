package
{
	import cinabu.HebrewTextHandling;
	
	import com.events.RequestEvents;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	import com.io.DataRequest;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.flash_proxy;
	
	[SWF (width=300,height=30)]
	public class PlayerNavigationBar extends Sprite
	{
		private var DATA_PATH:String;
		
		private var bg:Shape;
		private var btn:Sprite;
		private var _tf:TextField;
		private var itemID:int;
		private var link:String;
		private var reporet:String;
		private var dr:DataRequest;
		private var loadCounter:int;
				
		public function PlayerNavigationBar()
		{
			Debugging.printToConsole("--PlayerNavigationBar.20120902.1");
			HebrewTextHandling.actHTML = true;
			
			bg = ShapeDraw.drawSimpleRect(300,30,0x1E1E1E);
			addChild(bg);
			
			_tf = new TextField();
			_tf.autoSize = TextFieldAutoSize.CENTER;
			_tf.selectable = false;
			var fmt:TextFormat = new TextFormat("_sans",12,0xffffff);
			fmt.align = TextFormatAlign.CENTER;
			_tf.defaultTextFormat = fmt;
			addChild(_tf);
			
			btn = new Sprite();
			btn.addChild(ShapeDraw.drawSimpleRect(300,30,0,0));
			addChild(btn);
			
			//if (parent == stage) loadData("pid48.channels.sid169.cat210155","MASA_Age=2&CG=3&MASA_DayOfMonth=27&MASA_MonthOfYear=8&MASA_Refresh_Phase=0&MASA_ServiceBrowsingHistory=126,120,127,169,123,142,276,267,216,278,34,160,247,214&ticket=515F574A25F03DEE6E3B35BB82284E13961XO5D040107000A05161C18621C0D0E0F6163626B666C67686D7197D05112AC91D6B317EE79A53F59C271E76C3BDBD10F487E6C778301E02A052");
		}
		
		public function loadData(target:String,profile:String = ""):void
		{
			Debugging.printToConsole("--PlayerNavigationBar.loadData",target,profile);
			DATA_PATH = "http://nana10.checkm8.com/adam/inline?cat=" + target + "&format=TextLink_Player_1&ml=xml_multi_select&" + profile//"http://nana10.checkm8.com/adam/inline?cat="+target+"&format="+profile+"&attr1=ABC&attr2=XYZ&ml=....";//"http://images" + environment + ".nana10.co.il/Upload/XML/s" + serviceID + "/PlayerTextAd.xml";
			//DATA_PATH = "http://pda1.checkm8.com/adam/inline?cat=ILSites.test1&format=Count&ml=logiagrouptext";
				
			dr = new DataRequest();
			dr.addEventListener(RequestEvents.DATA_READY,onLoaded);
			dr.addEventListener(RequestEvents.DATA_ERROR,onError);
			dr.load(DATA_PATH);
		}
		
		private function onLoaded(event:RequestEvents):void
		{
			try
			{
				var xml:XML = event.xmlData;
				if (xml && xml.length() && xml.child("ad").length())
				{
					Debugging.printToConsole("--PlayerNavigatorBar.onLoaded",xml.length(),xml.child("ad").length());
					var xmlList:XMLList = xml.child("ad");
					//itemID = xmlList.@ItemID;
					link = xmlList.@click;
					text = xmlList.@text;
					var adPlay:String = xmlList.@adPlay;
					if (adPlay.length)
					{
						var reportLoader:URLLoader = new URLLoader();
						reportLoader.addEventListener(Event.COMPLETE       , new Function());
						reportLoader.addEventListener(IOErrorEvent.IO_ERROR, new Function());
						reportLoader.load(new URLRequest(adPlay));
					}
				}
				else
				{
					Debugging.printToConsole("--PlayerNavigationBar.onLoaded - empty");
					onError(null);
				}
			} catch (e:Error)
			{
				Debugging.printToConsole("--PlayerNavigationBar.onLoaded",e.errorID, e.message);
			}
		}
		
		private function onError(event:RequestEvents):void
		{
			Debugging.printToConsole("--PlayerNavigationBar.onError",loadCounter);
			/*if (loadCounter == 0)
			{
				loadCounter++;
				DATA_PATH = "http://images" + _environment + ".nana10.co.il/Upload/XML/s120/PlayerTextAd.xml";
				dr.load(DATA_PATH);
			}
			else
			{*/
				link = "https://www.facebook.com/nana10online";
				itemID = 4007860;
				text = "התקינו עכשיו את אפליקציית הפייסבוק שלנו";
			//}
		}
		
		private function set text(value:String):void
		{	
			if (value.length)
			{
				_tf.text = HebrewTextHandling.reverseString(value);
				DisplayUtils.align(bg,_tf);	
				btn.addEventListener(MouseEvent.CLICK,onClick);
				btn.buttonMode = true;
			}
		}
		
		private function onClick(event:MouseEvent):void
		{
			if (itemID) ExternalInterface.call("parent.cr",null,"ClickNavigate",itemID);
			navigateToURL(new URLRequest(link));
		}
	}
}