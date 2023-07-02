package com.data
{
	import com.adobe.serialization.json.JSON;
	import com.fxpn.util.MathUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class DataRepository extends EventDispatcher
	{
		private static var _instance:DataRepository;
		
		private var partiesColors:Object = {1: 0x023465, 2: 0xdc070e, 3: 0xcc9b0a, 4: 0xff6600, 9: 0x01b6e5, 8: 0x4ab122, 5: 0x5507e3, 6: 0x652a02, 7: 0xdc07cf, 12: 0x019376, 11: 0xff729d, 10: 0x597b84}
		
		private var _parties:Array;
		private var _poles:Array;
		
		public function DataRepository()
		{
		}
		
		public static function getInstance():DataRepository
		{
			if (_instance == null)
			{
				_instance = new DataRepository();
			}
			return _instance;
		}
		
		public function loadData(stageURL:String):void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,onDataLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onDataError);
			urlLoader.load(new URLRequest("http://specials" + (stageURL.indexOf("-dev") == -1 /*&& stageURL.indexOf("workspace") == -1*/ ? "" : "-dev") + ".nana10.co.il/IsraeliElections2013/Action.ashx?r=" + MathUtils.randomInteger(100,1000)));
		}
		
		private function onDataLoaded(event:Event):void
		{
			var data:Object = JSON.decode(event.target.data);			
			setParties(data.PartiesList);
			setPoles(data.PolesList);
			dispatchEvent(event);
		}
		
		private function onDataError(event:IOErrorEvent):void
		{
			dispatchEvent(event);
		}
		
		private function setParties(parties:Array):void
		{
			_parties = [];
			for (var i:int = 0; i < parties.length; i++)
			{
				var partyObject:Object = parties[i];
				_parties.push(new PartyData(partyObject.PartyID,partyObject.PartyName,partyObject.Important,partiesColors[partyObject.PartyID]));
			}
		}
		
		private function setPoles(poles:Array):void
		{
			_poles = [];
			for (var i:int = 0; i < poles.length; i++)
			{
				var poleObject:Object = poles[i];
				if (poleObject.PoleStatus == 1)
					_poles.push(new PoleData(poleObject.PoleID,poleObject.PoleDate,poleObject.PoleStatus,poleObject.PartiesList));				
			}
		}
		
		public function get totalParties():int
		{
			return _parties.length;
		}
		
		public function getPartyByName(name:String):PartyData
		{
			for (var i:int = 0; i < totalParties; i++)
			{
				if (_parties[i].partyName == name) return _parties[i];
			}
			return null;
		}
		
		public function getPartyByIndex(i:int):PartyData
		{
			return _parties[i];
		}
		
		public function getPartyColor(id:int):int
		{
			return partiesColors[id];
		}
		
		public function get totalPoles():int
		{
			return _poles.length;
		}
		
		public function getPoleByIndex(i:int):PoleData
		{
			return _poles[i];
		}		
	}
}