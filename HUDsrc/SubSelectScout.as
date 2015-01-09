package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	
	public class RawMeat extends MovieClip
	{
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		public function RawMeat() { 
			this.Option1.addEventListener(MouseEvent.CLICK, onButtonOption1Clicked);
			this.Option2.addEventListener(MouseEvent.CLICK, onButtonOption2Clicked);
			this.Option3.addEventListener(MouseEvent.CLICK, onButtonOption3Clicked);
		}
		
		// called by the game engine when this .swf has finished loading
		public function onLoaded():void
		{
			visible = true;
			gameAPI.SendServerCommand( "my_command arg1 arg2" );
		}		
		private function onButtonOption1Clicked(event:MouseEvent) : void {
            gameAPI.SendServerCommand("Option1");
        }		
		private function onButtonOption2Clicked(event:MouseEvent) : void {
            gameAPI.SendServerCommand("Option2");
        }
		private function onButtonOption3Clicked(event:MouseEvent) : void {
            gameAPI.SendServerCommand("Option3");
        }
		// called by the game engine after onLoaded and whenever the screen size is changed
		public function onScreenSizeChanged():void
		{
			// By default, your 1024x768 swf is scaled to fit the vertical resolution of the game
			//   and centered in the middle of the screen.
			// You can override the scaling and positioning here if you need to.
			// stage.stageWidth and stage.stageHeight will contain the full screen size.
		}
	}
}
