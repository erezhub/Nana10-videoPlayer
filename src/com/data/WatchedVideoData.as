/**
 * this class main use is to report to the stats DB for how long the user watched a content.
 * it does so by keeping an arry of TimingDetails object, which keep track of section which the user watched, thus taking into account seek operation performed by the user, 
 * or 'black-holes' between segments of the content.
 * the total length watched is sent to the stats DB every 10 to 60 seconds, depending on the content length.
 * moreover, 2 more automatic reports take place after 15 and 45 seconds of watching (for statistic reports reasons)
 * 
 * at a later stage, this class was used for a secondary reason:
 * the stats report is being sent eveyt 10-60 seconds, however the timer object runs every second, and keeps in a share-object the current time-code the user is watching, 
 * and the next time the user will watch it, he/she will be prompted to watch from the time-code where he/she left
 */ 
package com.data
{
	import com.fxpn.util.Debugging;
	import com.fxpn.util.ObjectUtisl;
	import com.fxpn.util.StringUtils;
	import com.gltovar.pausetimer.PauseTimer;
	
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import com.data.stats.StatsManagers;

	public class WatchedVideoData
	{
		private static var timingsArray:Array;
		private static var currentTiming:TimingDetails;
		private static var timer:PauseTimer;
		private static var minimalViewTimer:PauseTimer;
		private static var lastReport:Number;
		private static var delay:int;
		private static var liveStreamTotalPause:Number;
		private static var liveStreamCurrentPause:int;
		private static var so:SharedObject;
		
		public static function init(updateStats:Boolean = true):void
		{
			Debugging.printToConsole("--WatchedVideoData.init");
			timingsArray = [];	
			timer = null;
			if (updateStats) StatsManagers.updatePlayerStats(StatsManagers.KeepAlive,"0");
			if (isNaN(liveStreamTotalPause)) liveStreamTotalPause = 0;
			if (Nana10PlayerData.getInstance().isLive == false && CommunicationLayer.getInstance().videoNetDuration > 10*60)
			{
				try
				{
					so = SharedObject.getLocal("lt_" + ExternalParameters.getInstance().VideoID);
				}
				catch (e:Error) {};
			}
		}
		
		public static function addTiming(startTime:int):void
		{
			Debugging.printToConsole("--WatchedVideoData.addTiming",startTime);
			if (timingsArray == null)
			{
				init();
			}
			else if (timingsArray.length && isNaN(timingsArray[timingsArray.length - 1].finish))
			{	// don't ad new entry till the previous one is closed
				return;
			}
			
			currentTiming = new TimingDetails(startTime);
			timingsArray.push(currentTiming);
		}
		
		// the user perfomed a seek operation - close the current segment
		public static function closeTiming(endTime:Number):void
		{
			Debugging.printToConsole("--WatchedVideoData.closeTiming",endTime);
			if (currentTiming) currentTiming.finish = endTime;
		}
		
		public static function getTotalTiming():Number
		{
			var arrDup:Array = ObjectUtisl.clone(timingsArray);
			var currentTime:Number = CommunicationLayer.getInstance().playheadTime;
			if (isNaN(arrDup[arrDup.length-1].finish)) arrDup[arrDup.length-1].finish = currentTime;
			arrDup.sortOn("start",Array.NUMERIC);
			var currentStartTime:Number = arrDup[0].start;
			var currentFinishTime:Number = arrDup[0].finish;
			var totalTime:Number = currentFinishTime - currentStartTime;
			for (var i:int = 1; i < arrDup.length; i++)
			{	// going through all the timing-details array, and looking for overlapping
				var currentTiming:Object = arrDup[i];
				if (currentTiming.start < currentFinishTime && currentTiming.finish > currentFinishTime)
				{
					totalTime-=(currentFinishTime - currentTiming.start);
					currentFinishTime = currentTiming.finish;
				}
				currentStartTime = currentTiming.start;
				if (currentTiming.finish >= currentFinishTime)
				{
					totalTime+=(currentTiming.finish - currentStartTime);
					currentFinishTime = currentTiming.finish;
				}
			}
			
			if (totalTime == 0) 
			{
				totalTime = currentTime;
				//StatsManagers.updatePlayerStats(StatsManagers.Error,"KeepAlive error: "+arrDup.length+", start: "+arrDup[0].start+", finish: "+currentFinishTime);
			}
			
			return totalTime;
		}
		
		public static function startTimer():void
		{
			if (Nana10DataRepository.getInstance().previewGroupID) return;
			Debugging.printToConsole("--WatchedVideoData.startTimer");
			if (timer == null)
			{	// calculating the delay, according to the content's length
				delay = Math.min(Math.max(Math.round(CommunicationLayer.getInstance().videoNetDuration/20),10),60);
				if (Nana10PlayerData.getInstance().isLive) delay = 60;
				timer = new PauseTimer((so ? 1 : delay) * 1000);
				timer.addEventListener(TimerEvent.TIMER,onReport);
			}
			else if (Nana10PlayerData.getInstance().isLive && liveStreamCurrentPause > 0)
			{	// in case of live-streaming, the playhead keeps on going while the video is pause, so calculating for how long the player was paused
				liveStreamTotalPause+= (getTimer() - liveStreamCurrentPause)/1000;
			}
			if (minimalViewTimer == null)
			{
				minimalViewTimer = new PauseTimer(15000,1);
				minimalViewTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onReportMinimalView);
				minimalViewTimer.start();
			}
			else //if (minimalViewTimer.currentCount == 0)
			{
				minimalViewTimer.delay = 15000;
				minimalViewTimer.reset();
				minimalViewTimer.start();
			}
			timer.start();
			
		}
		
		public static function pauseTimer():void
		{
			if (timer) timer.pause();
			if (minimalViewTimer && minimalViewTimer.running) minimalViewTimer.pause();
			liveStreamCurrentPause = getTimer();
		}
		
		private static function onReport(event:TimerEvent):void
		{
			if (timer.currentCount % delay == 0 || so == null)
			{	// sending a 'keep-alive' event report
				var totalTiming:Number;
				try
				{
					totalTiming = getTotalTiming();
				}
				catch (e:Error)
				{
					totalTiming = CommunicationLayer.getInstance().playheadTime;
					//StatsManagers.updatePlayerStats(StatsManagers.Error,"KeepAlive error: "+e.message);
				}
				if (Nana10PlayerData.getInstance().isLive) totalTiming-= liveStreamTotalPause;
				if (totalTiming != lastReport && totalTiming > 1)
					StatsManagers.updatePlayerStats(StatsManagers.KeepAlive,int(totalTiming*1000).toString());
				lastReport = totalTiming;
			}
			if (so)
			{	// updating the shared-object
				so.data.lt = CommunicationLayer.getInstance().playheadTime;
				so.flush();
			}
		}
		
		// sending automatic reports after 15 and 45 seconds of watching
		// pay attention - this functionality doesn't work very well, for there are cases where those reports are sent more than once (mainly after seeking/toggling HQ etc.)
		private static function onReportMinimalView(event:TimerEvent):void
		{
			Debugging.printToConsole("--WatchedVideoData.onReportMinimalView",minimalViewTimer.superTimerDelay,lastReport);
			if (minimalViewTimer.superTimerDelay == 15000 && CommunicationLayer.getInstance().playheadTime > 0)
			{				
				if (lastReport < 15 || isNaN(lastReport)) StatsManagers.updatePlayerStats(StatsManagers.KeepAlive,"15000");
				minimalViewTimer.delay = 30000;
				minimalViewTimer.reset();
				minimalViewTimer.start();				
			}
			else if ((lastReport < 45  || isNaN(lastReport)) && CommunicationLayer.getInstance().playheadTime > 0)
			{
				StatsManagers.updatePlayerStats(StatsManagers.KeepAlive,"45000");
			}
		}
	}
}

class TimingDetails
{
	public var start:Number;
	public var finish:Number;
	
	public function TimingDetails(startTiming:Number)
	{
		start = startTiming;	
	}
}