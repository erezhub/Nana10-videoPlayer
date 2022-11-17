package com.ui.controls
{
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.GemiusDelegate;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.stats.StatsManagers;
	import com.data.WatchedVideoData;
	import com.data.items.Nana10SegmentData;
	import com.events.Nana10DataEvent;
	import com.events.VideoControlsEvent;
	import com.fxpn.display.AccurateShape;
	import com.fxpn.display.ShapeDraw;
	import com.fxpn.display.TooltipFactory;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	import gs.TweenLite;
	import gs.easing.Linear;
	
	public class ProgressBar extends Sprite
	{
		private var frame:Sprite;
		private var progress:Shape;
		private var buffer:Shape;
		private var playhead:Playhead;
		private var tooltip:ProgressTooltip;
		private var totallTime:ProgressTooltip;
		
		private var communicationLayer:CommunicationLayer;
		private var _ratio:Number;
		private var progressOrigWidth:Number;
		private var progressAdWidth:Number;
		private var frameOrigWidth:Number;
		private var _adMode:Boolean;
		private var bufferFull:Boolean;
		private var adLength:Number;
		private var toolTipTween:Tween;
		private var progressTween:Tween;
		private var prevPlayheadTime:int;
		private var resetBufferAfterAd:Number;
		
		private var tweenProgress:Boolean;
		public var tweenPlayhead:Boolean;
		
		public function ProgressBar(barWidth:Number)
		{
			communicationLayer = CommunicationLayer.getInstance();
			
			buffer = ShapeDraw.drawSimpleRect(barWidth-3,9,0x6b6f70);
			buffer.y = 2;
			buffer.x = 2;
			buffer.visible = false;
			addChild(buffer);
			
			progress = ShapeDraw.drawSimpleRect(barWidth-3,9,0x00adef);
			progress.y = 2;
			progress.x = 2;
			progress.visible = false;
			progressOrigWidth = progress.width;
			addChild(progress);
			
			frame = new Sprite();
			frame.addChild(ShapeDraw.drawSimpleRectWithFrame(barWidth,12,0,0x9ca0a0,1,0));
			frame.addEventListener(MouseEvent.CLICK,onClickFrame);
			frame.addEventListener(MouseEvent.ROLL_OVER,onRollOverFrame);
			frame.addEventListener(MouseEvent.ROLL_OUT,onRollOutFrame);
			frame.buttonMode = true;
			frameOrigWidth = barWidth;
			addChild(frame);
			
			totallTime = new ProgressTooltip(0x00adef);
			addChild(totallTime);
			totallTime.visible = false;
			
			tooltip = new ProgressTooltip();
			addChild(tooltip);
			tooltip.visible = false;
			
			playhead = new Playhead();
			playhead.buttonMode = true;
			playhead.addEventListener(MouseEvent.CLICK,onClickFrame);
			addChild(playhead);
			playhead.alpha = 0;
			
			if (Nana10PlayerData.getInstance().isLive) bufferFull = true;
			tweenPlayhead = tweenProgress = true;
		}		
						
		public function set ratio(videoDuration:Number):void
		{
			_ratio = progressOrigWidth / videoDuration;
			if (_adMode) adLength = videoDuration;
		}		
		
		public function updateProgress(playheadTime:Number = NaN):void
		{
			//Debugging.printToConsole("updateProgress",playheadTime,communicationLayer.playheadTime,Debugging.GetStackInfo(true));
			if (isNaN(playheadTime)) playheadTime = communicationLayer.playheadTime;
			if (playheadTime < 0)
			{
				playheadTime = 0;
				tweenPlayhead = false;
			}
			progress.width = Math.min(_ratio * playheadTime,progressOrigWidth);	
			var tooltipNewX:Number;
			if (_adMode)
			{
				if (isNaN(progressAdWidth) || !tweenProgress)
				{
					tooltipNewX = progressAdWidth = progress.width = progressOrigWidth - progress.width;
					tweenProgress = true;
				}
				else
				{
					var progressTempWidth:Number = progress.width;
					progressTween = new Tween(progress,"width",None.easeNone,progressAdWidth,progressOrigWidth - progress.width,0.5,true);
					tooltipNewX = progressAdWidth = progressOrigWidth - progressTempWidth;
					progressTween.start();
				}
			}
			else
			{	
				//Debugging.firebug("UPDATE_PROGRESS",progress.scaleX)
				if (progressTween && progressTween.isPlaying) progressTween.stop();
				tooltipNewX = progress.x + progress.width;
				// fading out the total time tooltip when the currtent time tooltip overlaps it
				totallTime.alpha = tooltipNewX > totallTime.x - totallTime.width ? (totallTime.x - tooltipNewX - tooltip.width/2)/(totallTime.width/2) : 1;
			}
			progress.visible = true;
			var currentTime:String = StringUtils.turnNumberToTime(playheadTime,true,true);
			if (currentTime != tooltip.text || !tweenPlayhead)
			{
				tooltip.visible = true;
				if (toolTipTween) toolTipTween.stop();
				if (Math.abs(int(playheadTime) - prevPlayheadTime) == 1 && tweenPlayhead)
				{
					toolTipTween = new Tween(tooltip,"x",None.easeNone,tooltip.x,tooltipNewX + (tooltipNewX - progress.width),1,true);
					toolTipTween.start();
				}
				else
				{
					tooltip.x = tooltipNewX;
				}
				tooltip.text = currentTime;
				prevPlayheadTime = int(playheadTime);
				tweenPlayhead = true;
			}
		}
		
		public function updateBuffer(percent:Number):void
		{
			//Debugging.firebug("UPDATE_BUFFER");
			buffer.scaleX = percent * (progressOrigWidth - buffer.x)/(progressOrigWidth - 2);
			buffer.scaleX*= stage.displayState == StageDisplayState.FULL_SCREEN ? (frame.width-1)/(frameOrigWidth-1) : frame.scaleX;
			if (buffer.width > progressOrigWidth) buffer.width = progressOrigWidth;
			buffer.visible = !_adMode;
			if (percent == 1)
			{
				bufferFull = true;
			}
		}
		
		public function set adMode(value:Boolean):void
		{
			Debugging.printToConsole("--ProgressBar.adMode",value);
			buffer.visible = playhead.visible = frame.buttonMode = frame.mouseEnabled = !value;
			if (Nana10PlayerData.getInstance().isLive == false) totallTime.visible = !value; 
			_adMode = value;
			if (value)
			{
				if (progressTween) progressTween.stop();
				progress.width = 0;
			}
			else
			{
				progressAdWidth = NaN;
				if (!isNaN(resetBufferAfterAd))
				{
					resetBuffer(resetBufferAfterAd);
					resetBufferAfterAd = NaN;
				}
			}
		}
		
		public function resetBuffer(startPoint:Number):void
		{
			if (_adMode)
			{
				resetBufferAfterAd = startPoint;
			}
			else
			{
				buffer.scaleX = 0;
				progress.width = playhead.x = buffer.x = progress.x + startPoint * progressOrigWidth;
				Debugging.printToConsole("resetBuffer",progress.width);
				tweenPlayhead = bufferFull = false;
			}
		}
		
		private function onClickFrame(event:MouseEvent):void
		{
			Debugging.printToConsole("--ProgressBar.onClickFrame",communicationLayer.enableSeek);
			if (communicationLayer.enableSeek)
			{
				WatchedVideoData.closeTiming(communicationLayer.playheadTime);
				tweenPlayhead = false;
				var currentTime:Number = (playhead.x - 2) / _ratio;
				var dataRepository:Nana10DataRepository = Nana10DataRepository.getInstance();
				var totalItems:int = dataRepository.totalItems;
				var segmentsGap:Number = 0;
				for (var i:int = 0; i < totalItems; i++)
				{
					if (dataRepository.getItemByIndex(i) is Nana10SegmentData)
					{
						var segmentData:Nana10SegmentData = dataRepository.getItemByIndex(i) as Nana10SegmentData;
						segmentsGap+=segmentData.gapToPreviousSegment;
						if (currentTime + segmentsGap > segmentData.timeCode && currentTime + segmentsGap < segmentData.endTimecode)
						{
							communicationLayer.currentSegmentId = segmentData.id;
							currentTime+=segmentsGap;
							communicationLayer.scenesGaps = segmentsGap;
							break;
						}
					}
				}
				StatsManagers.updatePlayerStats(StatsManagers.JumpToTime,StringUtils.turnNumberToTime(currentTime - communicationLayer.scenesGaps,true,true,true));
				WatchedVideoData.addTiming(currentTime - communicationLayer.scenesGaps);
				dispatchEvent(new VideoControlsEvent(VideoControlsEvent.GO_TO_FRAME,currentTime));
			}
		}
		
		private function onRollOverFrame(event:MouseEvent):void
		{
			onMouseMove(null);
			TweenLite.to(playhead,0.3,{alpha: 1});
			frame.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if (mouseX + 2 > frame.width) return;
			playhead.currentTime = StringUtils.turnNumberToTime((mouseX-2)/_ratio,true,true);
			playhead.x = mouseX;
		}
		
		private function onRollOutFrame(event:MouseEvent):void
		{
			if (event.relatedObject == playhead) return;
			TweenLite.to(playhead,0.3,{alpha: 0});
			frame.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}		
		
		public function dispalyTotalTime():void
		{
			totallTime.visible = true;
			totallTime.x = frame.width;
			totallTime.text = StringUtils.turnNumberToTime(communicationLayer.videoNetDuration,true,true);
		}
		
		public function hideProgress():void
		{
			progress.visible = tooltip.visible = false;
		}
		
		public function pause():void
		{
			if (toolTipTween && toolTipTween.isPlaying) toolTipTween.stop();
			if (progressTween && progressTween.isPlaying) progressTween.stop();
		}
		
		override public function set width(value:Number):void
		{
			var bufferXRatio:Number = buffer.x / frame.width;
			var progressWidthRatio:Number = progress.width / frame.width;
			var tooltipXRatio:Number = tooltip.x / frame.width;
			frame.width = totallTime.x = value;
			progressOrigWidth = value - 3;
			ratio = (_adMode && !isNaN(adLength)) ? adLength : communicationLayer.videoNetDuration;
			buffer.x = value * bufferXRatio;
			progress.width = value * progressWidthRatio;
			tooltip.x = value * tooltipXRatio;
			tweenPlayhead = tweenProgress = false;
			if (bufferFull) buffer.width = (stage.displayState == StageDisplayState.FULL_SCREEN ? progressOrigWidth-1 : progressOrigWidth + 1) - buffer.x;
		}
		
		override public function get width():Number
		{
			return frame.width;
		}
	}
}