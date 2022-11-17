/**
 * this class is used by the StatsManager class, to save stats report's properties
 */  
package com.data.stats
{
	public class StatsDataObject
	{
		
		private var _type:int;
		private var _position:Number;
		private var _textInfo:String;
		private var _sessionTime:int;
		private var _serverName:String;		
		private var _eventOrder:int
		
		private static var eventOrderCounter:int = 1;
		
		public function StatsDataObject(type:int,position:Number,textInfo:String,sessionTime:int,serverName:String = null)
		{
			_type = type;
			_position = position;
			_textInfo = textInfo;
			_sessionTime = sessionTime;
			_serverName = serverName;
			
			_eventOrder = eventOrderCounter++;
		}
		
		
		public function get type():int
		{
			return _type;
		}

		public function get position():Number
		{
			return _position;
		}

		public function get textInfo():String
		{
			return _textInfo;
		}

		public function get sessionTime():int
		{
			return _sessionTime;
		}

		public function get serverName():String
		{
			return _serverName;
		}

		public function get eventOrder():int
		{
			return _eventOrder;
		}
	}
}