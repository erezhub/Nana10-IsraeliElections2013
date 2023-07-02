package com.data
{
	public class PoleData
	{
		private var _poleID:int;
		private var _poleDate:String;
		private var _poleStatus:Boolean;
		private var _parties:Array;
		
		public function PoleData(id:int, date:String, status:int,parties:Array)
		{
			_poleID = id;
			_poleDate = date.substring(0,date.lastIndexOf("/"));
			_poleStatus = status == 1;
			_parties = parties;
		}

		public function get poleID():int
		{
			return _poleID;
		}

		public function get poleDate():String
		{
			return _poleDate;
		}

		public function get poleStatus():Boolean
		{
			return _poleStatus;
		}
		
		public function getPartyVotesById(id:int):int
		{
			for (var i:int = 0; i < _parties.length; i++)
			{
				if (_parties[i].PartyID == id) return _parties[i].Votes;
			}
			return -1;
		}

	}
}