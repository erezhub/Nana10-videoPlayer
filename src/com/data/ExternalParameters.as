package com.data
{
	import com.fxpn.util.Debugging;
	
	public dynamic class ExternalParameters
	{
		private static var _instance:ExternalParameters;
		 
		public function ExternalParameters(se:SingletonEnforcer)
		{
			
		}
		
		public static function getInstance():ExternalParameters
		{
			if (_instance == null)
			{
				_instance = new ExternalParameters(new SingletonEnforcer());
			}
			return _instance;
		}
		
		public function init(params:Object):void
		{
			var output:String = "";
			for (var i:String in params)
			{
				if (params[i].toLocaleLowerCase() == "true")
				{
					this[i] = true;	
				}
				else if (params[i].toLocaleLowerCase() == "false")
				{
					this[i] = false;
				}
				else if (params[i] == "null")
				{
					this[i] = null;
				}
				else
				{
					this[i] = params[i];
				}
				output = output.concat("\n",i," = ",params[i]);
			}
			Debugging.printToConsole("flashVars:",output);
		}
		
		public function reset():void
		{
			for (var i:String in this)
			{
				this[i] = null;
			}
		}

	}
	
	
}
internal class SingletonEnforcer{}
