package com.data
{
	import com.fxpn.util.Debugging;
	import com.gemius.stream.StreamManager;
	import com.gemius.stream.streamController.actionscript.sender.Debug;
	
	public class GemiusDelegate
	{
		private static var NOTIFY_AFTER_SEEK_COMPLETE:Boolean;
		
		private static const ENCODING:String = "utf-8";
		private static const IDENTIFIER:String = "pxYwrXNVC1yswCaBeuIGeMbinDPwNRiFEL85bzQU3hf.i7";
		private static const HITCOLLECTOR:String = "http://sil.hit.gemius.pl";
		
		private static const SHORT:String = "short views – up to 8 minuets";
		private static const LONG:String = "full episodes";
		private static const LIVE:String = "full events";
		
		private static const gA_NEWS:String = "news";
		private static const gA_ISRAELI:String = "israeli";
		private static const gA_DOCUMENTARY:String = "documentary";
		private static const gA_COMEDY:String = "comedy";
		private static const gA_REALITY:String = "reality";
		private static const gA_DRAMA:String = "drama";
		private static const gA_CHILDREN:String = "children";
		private static const gA_ENTERTAINMENT:String = "entertainment";
		private static const gA_LIVE:String = "live broadcast";
		private static const gA_FOOD:String = "food";
		
		private static var playerId:String;
		private static var materialIdentifier:String;
		private static var totalTime:Number;	
		private static var _serviceName:Object;
		private static var _length:Object;
		private static var _genere:Object;
		private static var treeId:Array = [];
		private static var additionalPackage:Array = [];
		private static var customPackage:Array;
		private static var commLayer:CommunicationLayer;
		private static var reportedVideoIDs:Array = [];
		
		public static function init():void
		{
			commLayer = CommunicationLayer.getInstance();
			try
			{
				if (Nana10PlayerData.getInstance().embededPlayer)
					StreamManager.getInstance().init(StreamManager.CONTROLLER_ACTIONSCRIPT);
				else
					StreamManager.getInstance().init();
				StreamManager.getInstance().setEncoding(ENCODING);
				StreamManager.getInstance().setGSMIdentifier(IDENTIFIER);
				StreamManager.getInstance().setGSMHitcollector(HITCOLLECTOR);
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--GemiusDelegate.init error",e.message);
			}
			
			playerId = "player_" + ExternalParameters.getInstance().SessionID;
			_serviceName = {name: "SERVICE_NAME", value: ExternalParameters.getInstance().ServiceName};
			_length = {name: "gACAT", value: SHORT};
			_genere = {name: "gA", value: gA_ISRAELI};
			customPackage = [_serviceName,_genere,_length];
		}
		
		public static function setVideoData(videoId:int,videoDuration:Number,serviceID:int):void
		{
			if (reportedVideoIDs.indexOf(videoId) > -1) return;
			reportedVideoIDs.push(videoId);
			materialIdentifier = videoId.toString();
			totalTime = videoDuration;
			if (totalTime == -1)
			{
				_length.value = LIVE;
			}
			else
			{
				_length.value = totalTime > 8*60 ? LONG : SHORT;
			}
			setGenere(serviceID);
			
			try
			{
				Debugging.printToConsole("--GemiusDelegate.setVideoData",videoId,_length.value,_genere.value);
				StreamManager.getInstance().newStream(playerId, materialIdentifier, totalTime,customPackage, additionalPackage, treeId);
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--GemiusDelegate.setVideoData error",e.message);
			}
		}
		
		private static function setGenere(serviceID:int):void
		{
			var genere:String;
			switch (serviceID)
			{
				case 126:
				case 130:
				case 127:
				case 182:
				case 187:
					genere = gA_NEWS;
					break;
				case 169:
					genere = gA_ISRAELI;
					break;
				case 186:
				case 267:
				case 268:
				case 235:
					genere = gA_DOCUMENTARY;
					break;
				case 252:
				case 261:
				case 269:
				case 266:
					genere = gA_COMEDY;
					break;
				case 177:
				case 227:
				case 249:
				case 247:
				case 250:
				case 272:
				case 237:
				case 248:
				case 276:
				case 275:
				case 278:
					genere = gA_REALITY;
					break;
				case 256:
				case 270:
				case 244:
				case 183:
				case 274:
					genere =gA_DRAMA;
					break;
				case 271:
					genere = gA_CHILDREN;
					break;
				case 123:
				case 129:
				case 265:
				case 262:
				case 259:
				case 253:
					genere = gA_ENTERTAINMENT;
					break;
				case 142:
					genere = gA_FOOD;
					break;
				default:
					genere = gA_ISRAELI;
					break;
			}
			if (Nana10PlayerData.getInstance().isLive) genere = gA_LIVE;
			_genere.value = genere;
		}
		
		public static function set playerID(value:String):void
		{
			playerId = "player_" + value;
		}
		
		public static function setCritertions(serviceName:String):void
		{
			_serviceName.value = serviceName;
		}
		
		public static function playing(afterSeekOrBuffer:Boolean = false):void
		{
			if (materialIdentifier == null || isNaN(totalTime)) return;
			if (afterSeekOrBuffer && !NOTIFY_AFTER_SEEK_COMPLETE) return;
			try
			{
				Debugging.printToConsole("--GemiusDelegate.playing",commLayer.playheadTime);
				StreamManager.getInstance().event(playerId, materialIdentifier, commLayer.playheadTime,"playing");
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--GemiusDelegate.playing error",e.message);
			}
			NOTIFY_AFTER_SEEK_COMPLETE = false;
		}
		
		public static function paused():void
		{
			if (materialIdentifier == null || isNaN(totalTime)) return;
			try
			{
				Debugging.printToConsole("--GemiusDelegate.paused");
				StreamManager.getInstance().event(playerId, materialIdentifier, commLayer.playheadTime,"paused");
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--GemiusDelegate.paused error",e.message);
			}
		}
		
		public static function buffering():void
		{
			if (materialIdentifier == null || isNaN(totalTime)) return;
			Debugging.printToConsole("--GemiusDelegate.buffering");
			StreamManager.getInstance().event(playerId, materialIdentifier, commLayer.playheadTime,"buffering");
			NOTIFY_AFTER_SEEK_COMPLETE = true;
		}
		
		public static function seekingStarted():void
		{
			if (materialIdentifier == null || isNaN(totalTime)) return;
			try
			{
				Debugging.printToConsole("--GemiusDelegate.seekingStarted");
				StreamManager.getInstance().event(playerId, materialIdentifier, commLayer.playheadTime,"seekingStarted");
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--GemiusDelegate.seekingStarted error",e.message);
			}		
			NOTIFY_AFTER_SEEK_COMPLETE = true;
		}
		
		public static function complete():void
		{
			if (materialIdentifier == null || isNaN(totalTime)) return;
			try
			{
				Debugging.printToConsole("--GemiusDelegate.complete");
				StreamManager.getInstance().event(playerId, materialIdentifier, commLayer.playheadTime,"complete");
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--GemiusDelegate.complete error",e.message);
			}
		}
		
		public static function closeStream():void
		{
			if (materialIdentifier == null || isNaN(totalTime)) return;
			try
			{
				Debugging.printToConsole("--GemiusDelegate.closeStream",commLayer.playheadTime);
				StreamManager.getInstance().closeStream(playerId, materialIdentifier, commLayer.playheadTime);
			}
			catch (e:Error)
			{
				Debugging.printToConsole("--GemiusDelegate.init error",e.message);
			}
		}
		
		
	}
}