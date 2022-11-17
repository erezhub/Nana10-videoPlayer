/**
 * this class is for displaying the user's demographics form
 */
package com.ui.pannels
{
	import com.adobe.utils.StringUtil;
	import com.data.ExternalParameters;
	import com.data.stats.StatsManagers;
	import com.events.Nana10PlayerEvent;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	
	import fl.controls.RadioButtonGroup;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import resources.pannels.OpeningFormVisuals;

	public class OpeningForm extends OpeningFormVisuals
	{
		private var _displayed:Boolean;
		private var so:SharedObject;
		private var soAvailable:Boolean;
		private var date:Date;
		private var sex_rbg:RadioButtonGroup;
		private var age_rbg:RadioButtonGroup;
		private var closeTimer:Timer;
		
		private static var _AGE:Object;
		private static var _SEX:Object;
		
		public function OpeningForm()
		{
			try
			{
				so = SharedObject.getLocal("ud");
				soAvailable = true;
			}
			catch (e:Error){}
		}
		
		public function checkDisplay(_stage:Stage):Boolean
		{
			try
			{
				if (ExternalInterface.call("parent.RequestQueryString","WNB") == 1) return false; // not displaying the form when the page's URL cotains 'WNB=1'
			}
			catch (e:Error) {};
			Debugging.printToConsole("--OpeningForm.checkDisplay",soAvailable);			
			var externalParams:ExternalParameters = ExternalParameters.getInstance();
			if (soAvailable)
			{	// shared object is available - checking if it has data, and not data was supplied from the FlashVars (data which is derived from the browser's cookies)
				if ((StringUtils.isStringEmpty(externalParams.user_age) && so.data.a) ||
					(StringUtils.isStringEmpty(externalParams.user_sex) && so.data.s))
				{
					if (_stage.loaderInfo.url.indexOf("http://")>-1)
					{
						try
						{	// updating the browser's cookies with the data saved in the shared-object
							ExternalInterface.call("UpdateUserDataCookie",so.data.a,so.data.s);
						}
						catch (e:Error) {}
					}
				}
				// if the shared object is empty and the data was supplied from the FlashVars - updating the shared-object
				if (so.data.a == null && StringUtils.isStringEmpty(externalParams.user_age) == false)
				{
					so.data.a = externalParams.user_age;
				}
				if (so.data.s == null && StringUtils.isStringEmpty(externalParams.user_sex) == false)
				{
					so.data.s = externalParams.user_sex;
				}
				_AGE = so.data.a;
				_SEX = so.data.s;
				date = new Date();	
				if ( // if the shared-object doesn't have the data, or it shouldn't be hidden, or its been 5 times since the last time it was displayed (and the player is large enough) - display it
					(so.data.hasOwnProperty("hide") == false || (so.data.c != null && so.data.c == 5))//(so.data.nd != null && so.data.nd < date.getTime())) 
					&& (so.data.hasOwnProperty("s") == false || so.data.hasOwnProperty("a") == false) 
					&& width + 20 < _stage.stageWidth 
					&& height + 20 < _stage.stageHeight)
				{
					init();
					return true;
				}
				if (so.data.c != null)
				{	// update the counter
					so.data.c++;
				}
				if (_AGE && _SEX) StatsManagers.updatePlayerStats(StatsManagers.FormDataFound);
			}
			else
			{	// shared data object isn't available.  if data isn't supplied from the FlahsVars - display the form
				if (StringUtils.isStringEmpty(externalParams.user_age) == false)
				{
					_AGE = externalParams.user_age;
				}
				if (StringUtils.isStringEmpty(externalParams.user_sex) == false)
				{
					_SEX = externalParams.user_sex;
				}
				if (_SEX == null || _AGE == null)
				{
					init();
					return true;
				}
				StatsManagers.updatePlayerStats(StatsManagers.FormDataFound);
					
			}
			return false;
		}
		
		private function init():void
		{
			Debugging.printToConsole("--OpeningForm.init");
			/*for (var i:int = 1930; i < 2010; i++)
			{
				year_cb.addItem({label: i});
			}
			year_cb.selectedIndex = 50;*/
			ok_btn.addEventListener(MouseEvent.CLICK,onSend);
			cancel_btn.addEventListener(MouseEvent.CLICK, onClose);
			sex_rbg = new RadioButtonGroup("sex");
			male_rb.group = female_rb.group = sex_rbg;
			
			age_rbg = new RadioButtonGroup("age");
			age_1.group = age_2.group = age_3.group = age_4.group = age_5.group = age_rbg;
			
			closeTimer = new Timer(20000,1);
			closeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onClose);
			closeTimer.start();
			
			StatsManagers.updatePlayerStats(StatsManagers.FormDisplayed);
		}
	
		
		private function onSend(event:MouseEvent):void
		{
			if (sex_rbg.selectedData == null) return;
			if (age_rbg.selectedData == null) return;
			if (stage.loaderInfo.url.indexOf("http://")>-1) ExternalInterface.call("UpdateUserDataCookie",age_rbg.selectedData,sex_rbg.selectedData); // updating the browser's cookies
			
			_AGE = age_rbg.selectedData;
			_SEX = sex_rbg.selectedData;
			
			if (soAvailable)
			{	// updating the shared data object
				so.data.nd = null;
				so.data.c = 0;
				so.data.hide = true;
				so.data.a = _AGE;
				so.data.s = _SEX;
			}
			StatsManagers.updatePlayerStats(StatsManagers.FormFilled);
			closeTimer.stop();
			close();
		}
		 // user either clicked the 'cancel' button or ignored the form for over 20 seconds
		private function onClose(event:Event):void
		{
			if (soAvailable)
			{
				so.data.c = 0;
				so.data.hide = true;
			}
			StatsManagers.updatePlayerStats(StatsManagers.FormIgnored);
			if (event.type == MouseEvent.CLICK) closeTimer.stop();
			close();
		}
		
		private function close():void
		{
			visible = false;
			dispatchEvent(new Nana10PlayerEvent(Nana10PlayerEvent.FORM_CLOSED));
			if (soAvailable) so.flush();
		}
		
		public static function get AGE():String
		{
			if (_AGE) return _AGE.toString();
			return "";
		}
		
		public static function get SEX():String
		{
			if (_SEX)
			{
				if (_SEX == "2") return "f";
				return "m";					
			}
			return "";
		}
		
		override public function get width():Number
		{
			return bg.width;
		}
	}
}