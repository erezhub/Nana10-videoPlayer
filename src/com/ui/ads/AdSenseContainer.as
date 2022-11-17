package com.ui.ads
{
	import com.data.ExternalParameters;
	import com.events.Nana10PlayerEvent;
	import com.fxpn.util.Debugging;
	import com.google.ads.instream.api.AdError;
	import com.google.ads.instream.api.AdErrorEvent;
	import com.google.ads.instream.api.AdEvent;
	import com.google.ads.instream.api.AdSizeChangedEvent;
	import com.google.ads.instream.api.AdsLoadedEvent;
	import com.google.ads.instream.api.AdsLoader;
	import com.google.ads.instream.api.AdsManager;
	import com.google.ads.instream.api.AdsRequest;
	import com.google.ads.instream.api.AdsRequestType;
	import com.google.ads.instream.api.Demographics;
	import com.google.ads.instream.api.FlashAdsManager;
	import com.ui.pannels.OpeningForm;
	
	import flash.events.Event;
	
	public class AdSenseContainer extends AdsLoader 
	{
		private var flashAdsManager:FlashAdsManager;
		private var adsRequest:AdsRequest
		private var _pauseFunction:Function;
		private var adSlotWidth:Number;
		private var adSlotHeight:Number;
		private var hidden:Boolean;
		private var _state:String;
		
		public function AdSenseContainer(stageWidth:Number, stageHeight:Number, test:Boolean, pauseFunction:Function, adType:String)
		{
			super();			
			_pauseFunction = pauseFunction;
			addEventListener(AdsLoadedEvent.ADS_LOADED, onAdsLoaded);
			addEventListener(AdErrorEvent.AD_ERROR, onAdError);

			adsRequest = new AdsRequest();
			
			adsRequest.adSlotWidth = stageWidth;
			adsRequest.adSlotHeight = stageHeight;
			adsRequest.publisherId= "ca-video-pub-7699565714483996";//"ca-video-afvtest";//			
			adsRequest.adType = adType;//ExternalParameters.getInstance().textAd == 1 ? AdsRequestType.TEXT_OVERLAY : AdsRequestType.GRAPHICAL_OVERLAY;//adType;
			adsRequest.contentId = ExternalParameters.getInstance().VideoID;
			adsRequest.language = "he";
			adsRequest.adTest = test ? "on" : "off";
			//Debugging.alert("adType: "+adsRequest.adType, "language: "+ adsRequest.language);
			var gender:String = OpeningForm.SEX;
			if (gender == "f")
			{
				adsRequest.gender = Demographics.GENDER_FEMALE;
			}
			else if (gender == "m")
			{
				adsRequest.gender = Demographics.GENDER_MALE;
			}
			switch (OpeningForm.AGE)
			{
				case "1":
					adsRequest.age = Demographics.AGE_17_AND_UNDER;
					break;
				case "2":
					adsRequest.age = Demographics.AGE_18_TO_24;
					break;
				case "3":
					adsRequest.age = Demographics.AGE_25_TO_34;
					break;
				case "4":
					var r:Number = Math.random();
					if (r < 0.33)
					{;
						adsRequest.age = Demographics.AGE_35_TO_44;
					}
					else if (r < 0.66)
					{
						adsRequest.age = Demographics.AGE_45_TO_54;
					}
					else
					{
						adsRequest.age = Demographics.AGE_55_TO_64;
					}
					break;
				case "5":
					adsRequest.age = Demographics.AGE_65_AND_OVER;
					break;
			}
			hidden = true;
			Debugging.printToConsole("--AdSenseContainer. type=" + adsRequest.adType, "width=" + adsRequest.adSlotWidth);
		}
		
		private function onAdsLoaded(adsLoadedEvent:AdsLoadedEvent):void
		{
			//hidden = false;
			Debugging.printToConsole("--AdSenseContainer.onAdsLoaded");
			flashAdsManager = adsLoadedEvent.adsManager as FlashAdsManager;
			if (!hidden)
			{
				if (!isNaN(adSlotWidth))
				{
					flashAdsManager.adSlotWidth = adSlotWidth;
					flashAdsManager.adSlotHeight = adSlotHeight;
					adSlotHeight = adSlotWidth = NaN;
				}
				flashAdsManager.load(this);
				flashAdsManager.play(this);
				flashAdsManager.addEventListener(AdEvent.CLICK,onClicked);
				flashAdsManager.addEventListener(AdSizeChangedEvent.SIZE_CHANGED,onToggle);
				_state = AdSizeChangedEvent.CLOSED_STATE;
			}
		}
		
		private function onClicked(event:AdEvent):void
		{
			// calling the function directly instead of using event-dispatcher because for some reason its not possible to add event-listener to this
			// class's object (after adding 'addEventListener', the output for 'hasEventListner' is false)
			_pauseFunction.call();
		}
		
		private function onToggle(event:AdSizeChangedEvent):void
		{
			_state = event.state;
		}
		
		public function display():void
		{
			Debugging.printToConsole("--AdSenseContainer.display",hidden,Debugging.GetStackInfo(true));
			if (hidden) requestAds(adsRequest);
			hidden = false;
		}
		
		public function hide():void
		{
			Debugging.printToConsole("--AdSenseContainer.hide",flashAdsManager);
			if (flashAdsManager) 
			{
				flashAdsManager.unload();
			}
			hidden = true;
		}
		
		private function onAdError(adErrorEvent:AdErrorEvent):void
		{
			var error:AdError = adErrorEvent.error;
			Debugging.printToConsole("AdSense Error: " + adErrorEvent.text,"\nerrorCoce: " + error.errorCode,"\nerrorMessage: "+error.errorMessage,"\nerrorType: "+error.errorType);
		}
		
		public function displayStateChanged(stageWidth:Number,stageHeight:Number):void
		{
			if (flashAdsManager)
			{
				flashAdsManager.adSlotWidth = stageWidth;
				flashAdsManager.adSlotHeight = stageHeight;
			}
			else
			{
				adSlotWidth = stageWidth;
				adSlotHeight = stageHeight;
			}
			if (adsRequest)
			{
				adsRequest.adSlotWidth = stageWidth;
				adsRequest.adSlotHeight = stageHeight;
			}
		}
		
		public function dispose():void
		{
			removeEventListener(AdsLoadedEvent.ADS_LOADED, onAdsLoaded);
			removeEventListener(AdErrorEvent.AD_ERROR, onAdError);
			if (flashAdsManager) flashAdsManager.removeEventListener(AdEvent.CLICK,onClicked);
		}
		
		public function get state():String
		{
			return _state;
		}
	}
}