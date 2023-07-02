package com.ui
{
	import com.data.DataRepository;
	import com.data.PartyData;
	import com.data.PoleData;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import resources.Dot;
	
	public class PartyLine extends Sprite
	{
		private var _dotsArray:Array = [];
		private var _y:Number;
		private var _x:Number;
		
		public function PartyLine(partyData:PartyData, display:Boolean)
		{
			var dr:DataRepository = DataRepository.getInstance();
			graphics.lineStyle(2,partyData.partyColor);
			
			var poleIndex:int = 0;
			var firstPartyPole:Boolean = true;
			var lineCommands:Vector.<int> = new Vector.<int>();
			var lineCords:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < dr.totalPoles; i++)
			{
				var poleData:PoleData = dr.getPoleByIndex(i);
				//if (poleData.poleStatus) 
				//{
					var votes:int =	poleData.getPartyVotesById(partyData.partyID);
					if (poleIndex == 0 || firstPartyPole)
					{
						lineCommands.push(1);
					}
					else if (votes >= 0)
					{
						lineCommands.push(2);
					}
					else 
					{
						poleIndex++;
						continue;
					}
					var cordX:int = -poleIndex * 109;
					var cordY:int = -votes * 8;
					lineCords.push(cordX);
					lineCords.push(cordY);
					addDot(cordX,cordY,votes,poleData.poleID);
					poleIndex++;
					if (votes >= 0)
					{
						firstPartyPole = false;
						if (isNaN(_x)) _x = cordX;
						if (isNaN(_y)) _y = cordY;
					}
				//}
			}
			graphics.lineStyle(2,partyData.partyColor);
			graphics.drawPath(lineCommands,lineCords);
			
			graphics.lineStyle(5,0,0);
			graphics.drawPath(lineCommands,lineCords);
			
			visible = display;//partyData.partyImportant;
			name = partyData.partyName;// + "_line";
		}
		
		private function addDot(_x:Number,_y:Number, _votes:int, _poleID:int):void
		{
			_dotsArray.push({loc: new Point(_x,_y), votes: _votes, poleID: _poleID});
		}
		
		public function get dotsArray():Array
		{
			return _dotsArray;		
		}
		
		override public function get y():Number
		{
			return _y;
		}
		
		override public function get x():Number
		{
			return _x - 50;
		}
	}
}