package com.data
{
	//import com.data.datas.KeyframeData;
	//import com.data.datas.items.partners.nana10.Nana10SceneData;
	//import com.data.datas.items.partners.nana10.Nana10SceneEndData;
	//import com.data.datas.items.partners.nana10.Nana10VideoData;
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.data.items.Nana10SegmentData;
	import com.data.items.player.Nana10SegmentEndData;
	import com.fxpn.util.Debugging;
	
	public class CastUpXMLParser
	{
		private static var dataRepository:Nana10DataRepository;
		
		private static var _startTime:Number;
		private static var _duration:Number = 0;
		//private static var _bmDuration:Number = 0;		
		
		public static var hqVideo:String;
		//public static var hqAvailable:Boolean;
		
		private static var currentVideoURL:int = 0;
		private static var alternateVideoURLS:Array;
		
		public static var currentHQVideoURL:int = 0;
		public static var alternateHQVideoURLS:Array;
		
		public static function parseXML(input:XML, duration:Number = 0, hq:Boolean = false):void
		{	
			dataRepository = Nana10DataRepository.getInstance();
			if (!hq)
			{
				for each (var mainParam:XML in input.PARAM)
				{
					if (mainParam.@NAME == "ORIGINAL_CLIP_TOTAL_DURATION" && parseInt(mainParam.@VALUE))
					{
						dataRepository.videoDuration = parseInt(mainParam.@VALUE);
						//break;
					} 
					else if (mainParam.@NAME == "TOTAL_DURATION" && parseInt(mainParam.@VALUE))
					{
						duration = duration ? duration : parseFloat(mainParam.@VALUE);
						CommunicationLayer.getInstance().videoGrossDuration = CommunicationLayer.getInstance().videoNetDuration = duration;//parseFloat(mainParam.@VALUE);	
					}
				}
			}
			var entries:Array = [];
			for each (var entry:XML in input.entry)
			{
				var entryObj:Object = {};
				for each (var param:XML in entry.PARAM)
				{
					var name:String = param.@NAME;
					var value:String = param.@VALUE;
					var floatValue:Number = parseFloat(value);
					if (isNaN(floatValue) == false && floatValue.toString() == value)
					{
						entryObj[name] = floatValue;
					}
					else
					{
						entryObj[name] = value;
					}
				}
				var refs:Array = [];
				for each (var ref:XML in entry.ref)
				{
					refs.push(String(ref.@href));
				}
				entryObj.refs = refs;
				if (entry.starttime != undefined)
				{
					entryObj.startTime = getTime(String(entry.starttime.@value));
					entryObj.duration = getTime(String(entry.duration.@value));
					if (entryObj.duration < duration) entryObj.duration = duration;
				}
				entries.push(entryObj);
			}
			if (hq)
			{
				getHQVideo(entries);
			}
			else
			{
				convertData(entries);
				/*if (isNaN(DataRepository.getInstance().movieDuration)) 
				{
					DataRepository.getInstance().movieDuration = _duration;
				}
				DataRepository.getInstance().bmDuration = _bmDuration;*/
			}
		}
		
		private static function convertData(data:Array):void
		{
			var communicationLayer:CommunicationLayer = CommunicationLayer.getInstance();
			var itemId:int = 1;
			var totalEntries:int = data.length;
			var adTiming:int;
			var hasBM:Boolean;
			var entry:Object;			
			var firstEntry:Boolean = true;
			var mainEntry:Object;
			var midrollID:int;
			for (var i:int = 0; i < totalEntries; i++)
			{
				entry = data[i];
				//var videoData:Nana10VideoData = new Nana10VideoData(0,0,"");
				var markerData:Nana10MarkerData;
				switch (String(entry.title).toLocaleLowerCase())
				{
					case "preroll":	
						communicationLayer.hasPreroll = true;
						break;
					case "midroll":
						markerData = new Nana10MarkerData(itemId++,Nana10ItemData.MARKER);
						markerData.timeCode = data[i+1].startTime;
						markerData.status = 1;
						dataRepository.addItem(markerData);
						midrollID = markerData.id;
						break;
					case "postroll": 
						//communicationLayer.hasPostroll = true; // postroll are disabled 	
						break;
					default:
						if (!firstEntry) continue;
						firstEntry = false;
						mainEntry = entry;				
						if (entry.ORIGINAL_CLIP_TOTAL_DURATION != null)
						{
							dataRepository.videoDuration = entry.ORIGINAL_CLIP_TOTAL_DURATION;
						}
						if (alternateVideoURLS == null)
						{
							alternateVideoURLS = entry.refs;
							dataRepository.videoLink = entry.refs[0];
							Debugging.printToConsole("--CastupXMLParser.convertData: total clip's refs",alternateVideoURLS.length);
						}
						if (isNaN(communicationLayer.videoStartPoint))
						{
							communicationLayer.videoStartPoint = entry.startTime;
						}
						/*if (isNaN(communicationLayer.videoGrossDuration))
						{
							communicationLayer.videoGrossDuration = communicationLayer.videoNetDuration = entry.duration - entry.startTime;	
						}*/
						var segmentData:Nana10SegmentData;
						var videoEndData:Nana10MarkerData;
						var totalItems:int = entry.BM_ITEMS;
						if (totalItems)
						{
							hasBM = true;
							var previousSegmentEnd:Nana10SegmentEndData;
							for (var j:int = 1; j < totalItems + 1; j++)
							{
								var segmentStartPoint:Number =  entry["BM" + j + "_POS_DURATION"];
								var segmentDuration:Number = entry["BM" + j + "_DURATION"];
								var segmentEndPoint:Number = segmentStartPoint + segmentDuration;
								if (previousSegmentEnd)
								{
									if (segmentStartPoint - 1 < previousSegmentEnd.timeCode && segmentEndPoint > previousSegmentEnd.timeCode)
									{	// segments overlapping (or less than 1sec between them) - remove previous's segment end-data										
										if (segmentStartPoint < previousSegmentEnd.timeCode)
										{	// removing the overlapping time from the net-duration (only if they realy overlap - not just too close)
											communicationLayer.videoNetDuration-= previousSegmentEnd.timeCode - segmentStartPoint;
											communicationLayer.videoGrossDuration-= previousSegmentEnd.timeCode - segmentStartPoint;
										}
										dataRepository.removeItemById(previousSegmentEnd.id);
										previousSegmentEnd = null;
									}
									//else
									//{
										segmentData = addSegmentStart(entry,j,itemId++);
									//}
								}
								else
								{
									segmentData = addSegmentStart(entry,j,itemId++);
								}
								if (previousSegmentEnd)
								{
									if (segmentEndPoint > previousSegmentEnd.timeCode)
									{
										communicationLayer.videoGrossDuration+= segmentStartPoint - previousSegmentEnd.timeCode + segmentDuration;
										previousSegmentEnd.nextSegmentID = segmentData.id;
										segmentData.gapToPreviousSegment = segmentData.timeCode - previousSegmentEnd.timeCode;
										/*if (segmentData.timeCode - previousSegmentEnd.timeCode > 1)
										{
											communicationLayer.videoNetDuration-=(segmentData.timeCode - previousSegmentEnd.timeCode);
										}*/
										communicationLayer.videoNetDuration+= segmentDuration;
										previousSegmentEnd = addSegmentEnd(segmentEndPoint,itemId++);	
									}
								}
								else
								{
									previousSegmentEnd = addSegmentEnd(segmentEndPoint,itemId++);
									communicationLayer.videoNetDuration+= segmentDuration;
									communicationLayer.videoGrossDuration+= segmentDuration;
								}
								if (j == 1) communicationLayer.currentSegmentId = segmentData.id;								
								/*segmentData = new Nana10SegmentData(itemId++);							
								segmentData.timeCode = entry["BM" + j + "_POS_DURATION"]*1000;
								segmentData.title = entry["BM" + j + "_NAME"];
								if (previousSegmentEnd) 
								{
									previousSegmentEnd.nextSegmentID = segmentData.id;
								}
								-----------------------------------------
								var sceneKFData:KeyframeData = new KeyframeData(parseInt(i+"0"+j),entry["BM" + j + "_POS_DURATION"]*1000);
								var sceneData:Nana10SceneData = new Nana10SceneData(0,entry["BM" + j + "_NAME"])//,entry["BM" + j + "_POS_DURATION"]*1000);
								sceneKFData.addItem(sceneData);
								sceneData.addKeyframe(sceneKFData.id);
								dataRepository.addKeyframe(sceneKFData);
								---------------------------
								dataRepository.addItem(segmentData);
								var segmentDuration:Number = entry["BM" + j + "_DURATION"];
								var segmentEndData:Nana10SegmentEndData = new Nana10SegmentEndData(itemId++);
								segmentEndData.timeCode = segmentData.timeCode + segmentDuration*1000
								--------------------------
								var sceneEndKFData:KeyframeData = new KeyframeData(parseInt(i+"0"+j+"1"),sceneKFData.timeCode + sceneDuration*1000);
								var sceneEndData:Nana10SceneEndData = new Nana10SceneEndData(0,sceneDuration);
								sceneEndKFData.addItem(sceneEndData);
								sceneEndData.addKeyframe(sceneEndKFData.id);
								dataRepository.addKeyframe(sceneEndKFData);
								--------------------------
								dataRepository.addItem(segmentEndData);
								previousSegmentEnd = segmentEndData;*/
								//_bmDuration+= segmentDuration;
							}
							videoEndData = new Nana10MarkerData(itemId++,Nana10ItemData.VIDEO_END);
							videoEndData.timeCode = previousSegmentEnd.timeCode - 0.01;
							videoEndData.status = 1;
							dataRepository.addItem(videoEndData);
						}
						//_duration+= entry.duration;
						break;
				}				
			}			
			if (!hasBM && ExternalParameters.getInstance().IsLive != 1)
			{
				videoEndData = new Nana10MarkerData(itemId++,Nana10ItemData.VIDEO_END);
				videoEndData.timeCode = (mainEntry.startTime + mainEntry.duration) - 0.01;
				dataRepository.addItem(videoEndData);		
			}
			if (midrollID && communicationLayer.videoNetDuration % CommunicationLayer.MINS_BETWEEN_MIDROLLS * 60 < 30)
			{	// in case there's a midroll less than 30secs before the video ends - remove it
				dataRepository.removeItemById(midrollID);
			}
		}
			
		private static function addSegmentStart(data:Object, index:int, id:int):Nana10SegmentData
		{
			var segmentData:Nana10SegmentData = new Nana10SegmentData(id++);							
			segmentData.timeCode = data["BM" + index + "_POS_DURATION"];
			segmentData.title = data["BM" + index + "_NAME"];
			segmentData.duration = data["BM" + index + "_DURATION"];
			segmentData.endTimecode = segmentData.timeCode + segmentData.duration;
			segmentData.status = 1;
			dataRepository.addItem(segmentData);
			return segmentData;
		}
		
		private static function addSegmentEnd(endPoint:Number,id:int):Nana10SegmentEndData
		{
			var segmentEndData:Nana10SegmentEndData = new Nana10SegmentEndData(id);
			segmentEndData.timeCode = endPoint;
			segmentEndData.status = 1;
			dataRepository.addItem(segmentEndData);
			return segmentEndData;
		}
		
		public static function getTime(input:String):Number
		{
			var output:Number = 0;
			var arr:Array = input.split(":");
			output+= parseInt(arr[0]) * 60 * 60;
			output+= parseInt(arr[1]) * 60;
			output+= parseFloat(arr[2]);
			
			return output;
		}
		
		private static function getHQVideo(data:Array):void
		{
			var totalEntries:int = data.length;
			for (var i:int = 0; i < totalEntries; i++)
			{
				if (data[i].title == null)
				{
					alternateHQVideoURLS = data[i].refs;
					hqVideo = data[i].refs[0];
					break;
				}
			}
			Debugging.printToConsole("CastupXMLParser.getHQVideo: total HQ clip's refs",alternateHQVideoURLS.length);
		}
		
		public static function setHQLinks(data:String):void
		{
			alternateHQVideoURLS = data.split(";"); 
			hqVideo = alternateHQVideoURLS[0];
			Debugging.printToConsole("CastupXMLParser.setHQLinks: total HQ clip's refs",alternateHQVideoURLS.length);
		}
		
		/*public static function get startTime():Number
		{
			return isNaN(_startTime) ? 0 : _startTime;
		}*/
		
		/*public static function get duration():Number
		{
			return _bmDuration;//_duration;
		}*/
		
		public static function get hasAlternateVideoURL():Boolean
		{
			return alternateVideoURLS && currentVideoURL < alternateVideoURLS.length - 1;
		}
		
		public static function get alternateVideoURL():String
		{
			return alternateVideoURLS[++currentVideoURL];
		}
		
		public static function reset():void
		{
			_startTime = NaN;
			//_duration = 0;
			hqVideo = null;
			currentVideoURL = 0;
			alternateVideoURLS = null;			
		}
		
	}
}