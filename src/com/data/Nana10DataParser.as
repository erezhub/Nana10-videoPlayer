package com.data
{
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.data.items.Nana10SegmentData;
	import com.data.items.player.Nana10SegmentEndData;

	public class Nana10DataParser
	{
		// this function goes through all the items in the data-repository, calculates the content's net duration (by removing 'black-holes' between the segments), also taking into account overlapping segments
		public static function parseData():void
		{
			var communicationLayer:CommunicationLayer = CommunicationLayer.getInstance();
			var dataRepository:Nana10DataRepository = Nana10DataRepository.getInstance();
			var segmentData:Nana10SegmentData;
			var videoEndData:Nana10MarkerData;
			var itemId:int = 1;
			var hasAds:Boolean;
			
			var totalItems:int = dataRepository.totalItems;
			if (totalItems > 1)
			{
				var previousSegmentEnd:Nana10SegmentEndData;
				var firstItem:Boolean = true;
				for (var j:int = 0; j < totalItems; j++)
				{
					var itemData:Nana10MarkerData = dataRepository.getItemByIndex(j);
					if (dataRepository.previewGroupID && // in case of preview (from within the tagger) - ignoring items not in the relevant group
						((itemData.type == Nana10ItemData.SEGMENT &&  itemData.belongsToGroup(dataRepository.previewGroupID)== false && (itemData as Nana10SegmentData).uniqueGroup != dataRepository.previewGroupID) || 
						 (itemData.type == Nana10ItemData.MARKER && itemData.belongsToGroup(dataRepository.previewGroupID)== false))) continue;
					if (itemData.status == 0) continue;
					if (itemData.type == Nana10ItemData.MARKER)
					{
						if (itemData.markerType == Nana10MarkerData.AD)
						{	// if the content includes ads - automatically add a preroll
							if (Nana10PlayerData.getInstance().showAds)
							{
								communicationLayer.hasPreroll = true;
								hasAds = true;
							}
							if (itemData.timeCode == 0)
							{	// if the marker is in time-code 0 - ignore it
								dataRepository.removeItemById(itemData.id);
								j--;
								totalItems--;
							}
						}
						continue;
					}
					segmentData = itemData as Nana10SegmentData;
					var segmentStartPoint:Number =  segmentData.timeCode;
					var segmentEndPoint:Number = segmentData.endTimecode;
					var segmentDuration:Number = segmentData.endTimecode - segmentData.timeCode;
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
					}
					if (previousSegmentEnd)
					{
						if (segmentEndPoint > previousSegmentEnd.timeCode)
						{
							communicationLayer.videoGrossDuration+= segmentStartPoint - previousSegmentEnd.timeCode + segmentDuration;
							previousSegmentEnd.nextSegmentID = segmentData.id;
							segmentData.gapToPreviousSegment = segmentData.timeCode - previousSegmentEnd.timeCode;
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
					if (firstItem) 
					{
						communicationLayer.currentSegmentId = segmentData.id;
						communicationLayer.videoStartPoint = segmentData.timeCode;
						firstItem = false;
					}
					if (dataRepository.previewGroupID && isNaN(communicationLayer.videoStartPoint))
					{
						communicationLayer.videoStartPoint = segmentStartPoint;
					}
				}
				
				// adding an item to mark the end of the video
				videoEndData = new Nana10MarkerData(itemId++,Nana10ItemData.VIDEO_END);
				videoEndData.timeCode = previousSegmentEnd.timeCode - 0.01;
				dataRepository.addItem(videoEndData);
				if (!hasAds && Nana10PlayerData.getInstance().showAds) communicationLayer.hasPreroll = true;
			}
			else if (totalItems == 1 && dataRepository.getItemByIndex(0).type == Nana10ItemData.SEGMENT)
			{	// the content contains a single item, throughout the entire video
				segmentData = dataRepository.getItemByIndex(0) as Nana10SegmentData;
				var endTimeCode:Number = segmentData.endTimecode == 0 ? dataRepository.videoDuration : segmentData.endTimecode; 
				communicationLayer.videoNetDuration = communicationLayer.videoGrossDuration = endTimeCode - segmentData.timeCode;
				communicationLayer.videoStartPoint = segmentData.timeCode;
				
				videoEndData = new Nana10MarkerData(itemId++,Nana10ItemData.VIDEO_END);
				videoEndData.timeCode = endTimeCode - 0.01;
				dataRepository.addItem(videoEndData);
				if (Nana10PlayerData.getInstance().showAds) communicationLayer.hasPreroll = true;
			}
		}
		
		private static function addSegmentEnd(endPoint:Number,id:int):Nana10SegmentEndData
		{
			var segmentEndData:Nana10SegmentEndData = new Nana10SegmentEndData(id);
			segmentEndData.timeCode = endPoint;
			segmentEndData.status = 1;
			Nana10DataRepository.getInstance().addItem(segmentEndData);
			return segmentEndData;
		}
	}
}