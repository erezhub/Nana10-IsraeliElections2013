package
{
	import com.fxpn.util.Debugging;
	import com.fxpn.util.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import resources.LoadingAnimation;
		
	[SWF (backgroundColor=0xffffff, width=780, height=460)]
	public class IsraeliElections2013Preloader extends Sprite
	{
		private var loadingAnimation:LoadingAnimation;
		
		public function IsraeliElections2013Preloader()
		{
			Security.allowDomain("specials.nana10.co.il","specials-dev.nana10.co.il");
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			
			loadingAnimation = new LoadingAnimation();
			addChild(loadingAnimation);
			DisplayUtils.align(stage,loadingAnimation);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			var url:String = stage.loaderInfo.url;
			loader.load(new URLRequest("http://specials" + (url.indexOf("-dev") == -1 && url.indexOf("workspace") == -1 ? "" : "-dev") + ".nana10.co.il/IsraeliElections2013/IsraeliElections2013.swf"));	
		}
		
		private function onLoaded(event:Event):void
		{
			var graph:DisplayObject = event.target.content as DisplayObject;
			addChild(graph);
			removeChild(loadingAnimation);
		}
		
		private function onError(event:IOErrorEvent):void
		{
			Debugging.alert("שגיאה בטעינה \n" + event.text);
		}
	}
}