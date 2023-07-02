package com.data
{
	public class PartyData
	{
		private var _partyID:int;
		private var _partyName:String;
		private var _partyColor:int;
		private var _partyImportant:Boolean;
		
		public function PartyData(ID:int, name:String, important:Boolean, color:int)
		{
			_partyID = ID;
			_partyName = name;
			_partyColor = color;
			_partyImportant = important;
		}

		public function get partyID():int
		{
			return _partyID;
		}

		public function get partyName():String
		{
			return _partyName;
		}

		public function get partyColor():int
		{
			return _partyColor;
		}

		public function get partyImportant():Boolean
		{
			return _partyImportant;
		}	

	}
}