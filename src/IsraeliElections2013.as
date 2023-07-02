package
{
	import cinabu.HebrewTextHandling;
	
	import com.adobe.protocols.dict.Dict;
	import com.adobe.serialization.json.JSON;
	import com.data.DataRepository;
	import com.data.PartyData;
	import com.data.PoleData;
	import com.fxpn.util.ContextMenuCreator;
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	import com.fxpn.util.MathUtils;
	import com.ui.PartyLine;
	
	import fl.controls.CheckBox;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	import gs.TweenLite;
	
	import resources.BG;
	import resources.Circle;
	import resources.DataContainer;
	import resources.DateContainer;
	import resources.Dot;
	import resources.LoadingAnimation;
	import resources.PartyLegend;
	
	[SWF (backgroundColor=0xffffff, width=780, height=460)]
	public class IsraeliElections2013 extends Sprite
	{
		private var dr:DataRepository;
		private var dataContainer:DataContainer;
		private var paritesObjects:Dictionary = new Dictionary();
		private var partiesCircles:Dictionary = new Dictionary();
		private var currentPoleIndex:int;
		private var currentPoleID:int;
		private var so:SharedObject;
		
		private var bg:BG;
		private var loadingAnimation:LoadingAnimation;
		
		private const partiesOrigX:int = 685;
		private const partiesOrigY:int = 415;
		private const maxPoles:int = 5;
		
		private const tweenDelta:int = 109;
		private const tweenDuration:Number = 0.5;
		private var tweenItems:Array;
		private var tweenIndex:int;
		private var partyStrip0:DisplayObject;
		
		public function IsraeliElections2013()
		{
			Security.allowDomain("f-dev.nanafiles.co.il","f.nanafiles.co.il");
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);	
		}
		
		private function onAddedToStage(event:Event):void
		{
			bg = new BG();			
			addChild(bg);
			
			loadingAnimation = new LoadingAnimation();
			addChild(loadingAnimation);
			DisplayUtils.align(stage,loadingAnimation);
			
			dataContainer = new DataContainer();
			dataContainer.x = 655;
			dataContainer.y = 386;
			addChild(dataContainer);
			tweenItems = [dataContainer.linesContainer,dataContainer.dotsContainer,dataContainer.circlesContainer,dataContainer.datesStripContainer];
			
			dr = DataRepository.getInstance();
			dr.addEventListener(Event.COMPLETE,onDataReady);
			dr.addEventListener(IOErrorEvent.IO_ERROR,onDataError);
			dr.loadData(stage.loaderInfo.url);
			
			try 
			{
				so = SharedObject.getLocal("ie2013");
			}
			catch (e:Error){}
			
			contextMenu = ContextMenuCreator.setContextMenu("בחירות 2013 (c)Nana10 1.4",loaderInfo.url.indexOf("http://") == -1);
		}
		
		private function onDataReady(event:Event):void
		{
			setParties();
			setPoles();
			if (dr.totalPoles > maxPoles)
			{
				bg.nextBtn.addEventListener(MouseEvent.CLICK,onNext);
				bg.prevBtn.addEventListener(MouseEvent.CLICK,onPrevious);
			}
			removeChild(loadingAnimation);
			loadingAnimation.stop();
			loadingAnimation = null;
		}
		
		private function onDataError(event:IOErrorEvent):void
		{
			removeChild(loadingAnimation);
			loadingAnimation.stop();
			loadingAnimation = null;
			Debugging.alert("שגיאה בטעינת המידע.  נא לנסות שוב מאוחר יותר");
		}		
		
		private function setParties():void
		{			
			for (var i:int = 0; i < dr.totalParties; i++)
			{	
				var partyData:PartyData  = dr.getPartyByIndex(i);
				paritesObjects[partyData.partyName] = [];
				partiesCircles[partyData.partyName] = [];
				addPartyNameBox(partyData,i);
				addPartyLine(partyData);
			}
		}
		
		private function addPartyNameBox(partyData:PartyData,index:int):void
		{
			var partyBox:PartyLegend = new PartyLegend();
			partyBox.name = partyData.partyName;
			partyBox.name_txt.text = HebrewTextHandling.reverseWord(partyData.partyName);
			partyBox.x = partiesOrigX - (index % 6) * (partyBox.bg.width + 9);
			partyBox.y = partiesOrigY + int(index/6) * (partyBox.bg.height + 5);
			DisplayUtils.setTintColor(partyBox.bg,partyData.partyColor);
			partyBox.cb.addEventListener(Event.CHANGE,onPartyToggle);
			var cbSelected:Boolean = partyData.partyImportant;
			if (so)
			{
				if (so.data["s_" + partyData.partyID] == undefined)
				{
					so.data["s_" + partyData.partyID] = cbSelected;
				}
				else
				{
					cbSelected = so.data["s_" + partyData.partyID];
				}
			}
			partyBox.cb.selected = cbSelected; //(so && ) ? so.data["s_" + partyData.partyID] : partyData.partyImportant; 
			partyBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverParty);
			partyBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutParty);
			addChild(partyBox);			
		}		
		
		private function addPartyLine(partyData:PartyData):void
		{
			var partyLine:PartyLine = new PartyLine(partyData, so ? so.data["s_" + partyData.partyID] : partyData.partyImportant);
			dataContainer.linesContainer.addChild(partyLine);			
			partyLine.addEventListener(MouseEvent.ROLL_OVER,onRollOverParty);
			partyLine.addEventListener(MouseEvent.ROLL_OUT,onRollOutParty);
			addDots(partyLine.dotsArray,partyData);
		}
		
		private function addDots(dotsArray:Array, partyData:PartyData):void
		{
			var dotColor:int = partyData.partyColor;
			for (var i:int = 0; i < dotsArray.length; i++)
			{
				var dotLoc:Point = dotsArray[i].loc;
				var dot:Dot = new Dot();
				dot.x = dotLoc.x;
				dot.y = dotLoc.y;
				dot.addEventListener(MouseEvent.ROLL_OVER,onRollOverParty);
				dot.addEventListener(MouseEvent.ROLL_OUT,onRollOutParty);
				dot.name = partyData.partyName;
				DisplayUtils.setTintColor(dot,dotColor);
				dataContainer.dotsContainer.addChild(dot);
				dot.visible = so ? so.data["s_" + partyData.partyID] : partyData.partyImportant//partyData.partyImportant;
				paritesObjects[partyData.partyName].push(dot);
				
				var circle:Circle = new Circle();
				circle.votes_txt.text = dotsArray[i].votes;
				circle.partyStrip.name_txt.text = HebrewTextHandling.reverseWord(partyData.partyName);
				DisplayUtils.setTintColor(circle.partyStrip.bg,partyData.partyColor);
				circle.partyStrip.visible = false;
				circle.x = dotLoc.x;
				circle.y = dotLoc.y;
				circle.addEventListener(MouseEvent.ROLL_OVER,onRollOverParty);
				circle.addEventListener(MouseEvent.ROLL_OUT,onRollOutParty);
				circle.name = partyData.partyName + "_" + dotsArray[i].poleID;
				circle.visible = false;
				DisplayUtils.setTintColor(circle.bg,dotColor);
				partiesCircles[partyData.partyName].push(circle);
				dataContainer.circlesContainer.addChild(circle);				
			}
		}
		
		private function setPoles():void
		{
			var poleIndex:int = 0;
			for (var i:int = 0; i < dr.totalPoles; i++)
			{
				var poleData:PoleData = dr.getPoleByIndex(i);
				var poleDateContainer:DateContainer = new DateContainer();
				poleDateContainer.date_txt.text = poleData.poleDate;
				poleDateContainer.x = -poleDateContainer.width - (poleDateContainer.width + 9) * poleIndex++;
				dataContainer.datesStripContainer.addChild(poleDateContainer);	
				if (currentPoleID == 0)
				{
					currentPoleIndex = i;
					currentPoleID = poleData.poleID;
				}
			}
			if (poleIndex < maxPoles)
				dataContainer.x-= (5- poleIndex) * 109;
		}		
		
		private function onPartyToggle(event:Event):void
		{
			var partyName:String = event.target.parent.name;
			var partyObjects:Array = paritesObjects[partyName];
			var checked:Boolean = event.target.selected;
			for (var i:int = 0; i < partyObjects.length; i++)
			{
				partyObjects[i].visible = checked;
			}
			dataContainer.linesContainer.getChildByName(event.target.parent.name).visible = checked;
			if (checked)
				showPartyData(partyName);
			else
				hidePartyData(partyName);
			if (so)
			{
				so.data["s_" + dr.getPartyByName(partyName).partyID] = checked;
			}
		}
		
		private function onRollOverParty(event:MouseEvent):void
		{
			if (event.target is PartyLegend && !event.target.cb.selected) return;
			showPartyData(event.target.name.split("_")[0]);			
		}
		
		private function showPartyData(partyName:String):void
		{			
			var partyCircles:Array = partiesCircles[partyName];
			for (var i:int = 0; i < partyCircles.length; i++)
			{
				partyCircles[i].visible = true;
			}
			var highlightPoleIndex:int = currentPoleIndex;
			while (dr.getPoleByIndex(highlightPoleIndex).getPartyVotesById(dr.getPartyByName(partyName).partyID) == -1)
			{
				highlightPoleIndex++;
				if (highlightPoleIndex == dr.totalPoles) break;
			}
			if (highlightPoleIndex >=0 && highlightPoleIndex < dr.totalPoles)	
			{
				var partyStrip:DisplayObject = dataContainer.circlesContainer.getChildByName(partyName + "_" + dr.getPoleByIndex(highlightPoleIndex).poleID)["partyStrip"]; 
				partyStrip.visible = true;
				if (partyCircles[highlightPoleIndex].votes_txt.text == "0")
				{
					partyStrip0 = partyStrip.parent;
					partyStrip0.y = -11;					
				}				
			}
			fadeItems(dataContainer.linesContainer,partyName,0.2);
			fadeItems(dataContainer.dotsContainer,partyName,0.2);
		}
		
		private function onRollOutParty(event:MouseEvent):void
		{		
			var partyName:String = event.target.name;
			hidePartyData(partyName.split("_")[0]);
			fadeItems(dataContainer.linesContainer,partyName,1);
			fadeItems(dataContainer.dotsContainer,partyName,1);
			if (partyStrip0)
			{
				partyStrip0.y = 0;
				partyStrip0 = null;
			}
		}
		
		private function fadeItems(container:DisplayObjectContainer, target:String, alpha:Number):void
		{			
			for (var j:int = 0; j < container.numChildren; j++)
			{	
				if (container.getChildAt(j).name != target)
				{
					TweenLite.to(container.getChildAt(j),0.3,{alpha: alpha});
				}
			}
		}
		
		private function hidePartyData(partyName:String):void
		{
			var partyCircles:Array = partiesCircles[partyName];
			for (var i:int = 0; i < partyCircles.length; i++)
			{
				partyCircles[i].visible = false;
				partyCircles[i].partyStrip.visible = false;
			}
		}
		
		private function onNext(event:MouseEvent):void
		{
			if (tweenIndex > 0)
			{
				for each (var item:DisplayObject in tweenItems)
				{
					TweenLite.killTweensOf(item,true);
					TweenLite.to(item,tweenDuration,{x: item.x - tweenDelta});
				}
				tweenIndex--;
				currentPoleID = dr.getPoleByIndex(--currentPoleIndex).poleID;
			}
		}
		
		private function onPrevious(event:MouseEvent):void
		{
			if (tweenIndex < dr.totalPoles - maxPoles)
			{
				for each (var item:DisplayObject in tweenItems)
				{
					TweenLite.killTweensOf(item,true);
					TweenLite.to(item,tweenDuration,{x: item.x + tweenDelta});
				}
				tweenIndex++;
				currentPoleID = dr.getPoleByIndex(++currentPoleIndex).poleID;
			}
		}
	}
}