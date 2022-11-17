package com.data.cm8.businessobject
{
	import com.checkm8.advantage.video.delegation.player.api.businessobject.IVideo;
	import com.checkm8.advantage.video.util.logger.Log;
	import com.data.CommunicationLayer;
	import com.data.ExternalParameters;
	import com.data.Nana10DataRepository;
	import com.data.Nana10PlayerData;
	import com.data.items.Nana10ItemData;
	import com.data.items.Nana10MarkerData;
	import com.data.items.Nana10SegmentData;
	import com.fxpn.util.Debugging;
	import com.io.CommunicationLayer;
	
	public class Video implements IVideo
	{
		private var commLayer:com.data.CommunicationLayer;
		private var _cuePoints:Array;
		
		public function Video()
		{
			Debugging.printToConsole("--cm8.businessobject.Video");
			commLayer = com.data.CommunicationLayer.getInstance();
			
			_cuePoints = [];
			var dr:Nana10DataRepository = Nana10DataRepository.getInstance();
			dr.sortOnTimeCode();
			var offset:Number = 0;
			var totalItems:int = dr.totalItems;
			for (var i:int = 0; i < totalItems; i++)
			{
				var currItem:Nana10MarkerData = dr.getItemByIndex(i);
				if (dr.previewGroupID && 
					((currItem.type == Nana10ItemData.SEGMENT &&  currItem.belongsToGroup(dr.previewGroupID)== false && (currItem as Nana10SegmentData).uniqueGroup != dr.previewGroupID) || 
						(currItem.type == Nana10ItemData.MARKER && currItem.belongsToGroup(dr.previewGroupID)== false))) continue;
				if (currItem.status == 0) continue;
				switch (currItem.type)
				{
					case Nana10ItemData.MARKER:
						if (currItem.markerType == Nana10MarkerData.AD)
						{
							Debugging.printToConsole("cuePoint",currItem.timeCodeDisplay);
							_cuePoints.push(new VideoCuePoint(currItem,offset));
						}
						break;
					case Nana10ItemData.SEGMENT:
						offset+=currItem.timeCode;
						break;
					case Nana10ItemData.SEGMENT_END:
						offset-=currItem.timeCode;
						break;
				}
			}
			if (_cuePoints.length == 0) _cuePoints = null;
		}
		
		public function get displayName():String
		{
			return ExternalParameters.getInstance().Title;
		}
		
		public function get duration():Number
		{
			if (Nana10PlayerData.getInstance().isLive) return 60*60*1000//Number.POSITIVE_INFINITY;
			return commLayer.videoNetDuration*1000;
		}
		
		public function get id():String
		{
			return String(ExternalParameters.getInstance().VideoID);
		}
		
		public function get url():String
		{
			return commLayer.videoPlayer.source;
		}
		
		public function get cuePoints():Array
		{
			return _cuePoints;
		}
		
		public function get customValues():Array
		{
			var output:Array
			if (_cuePoints || Nana10PlayerData.getInstance().isLive)
			{
				output = [{key: "MASA_AllowMidroll", value: "No"}];
			}
			else
			{
				output = [{key: "MASA_AllowMidroll", value: "Yes"}];
			}
			output.push({key: "Nana10PlayerID", value: ExternalParameters.getInstance().PlayerID});				
			Log.getInstance().log("Video.custumValues " + output[0].value + ", " + output[1].value);
			return output;
		}
	}
}