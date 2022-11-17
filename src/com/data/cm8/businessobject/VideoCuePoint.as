package com.data.cm8.businessobject
{
	import com.checkm8.advantage.video.delegation.player.api.businessobject.IVideoCuePoint;
	import com.data.ExternalParameters;
	import com.data.Nana10PlayerData;
	import com.data.items.Nana10MarkerData;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.StringUtils;
	
	public class VideoCuePoint implements IVideoCuePoint
	{
		private var markerData:Nana10MarkerData;
		private var _offset:Number;
		
		public function VideoCuePoint(nana10MarkerData:Nana10MarkerData,offset:Number)
		{
			markerData = nana10MarkerData;
			_offset = offset;
		}
		
		public function get videoId():String
		{
			return String(ExternalParameters.getInstance().VideoID);
		}
		
		public function get name():String
		{
			if (Nana10PlayerData.getInstance().isLive) return "live";
			return "vod";
			//return markerData.typeName + markerData.id;
		}
		
		public function get time():Number
		{
			if (markerData == null)
			{
				Debugging.printToConsole("--VideoCuePoint.time",_offset);
				return _offset;
			}
			Debugging.printToConsole("--VideoCuePoint.time",StringUtils.turnNumberToTime(markerData.timeCode - _offset,true,true));
			return (markerData.timeCode-_offset)*1000;
		}
		
		public function get customValues():Array
		{
			return null;
		}
	}
}