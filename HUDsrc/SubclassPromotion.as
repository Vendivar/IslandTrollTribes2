package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	
	public class SubclassPromotion extends MovieClip
	{
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var element:String;
		//toxic's variables
		public var State:Number = 0;
		//0=fresh,1=clicked(openmenu),2=clickedagain(closemenu)
		//sunburst only on 0
		
		public function SubclassPromotion() { 
			this.btn_open_sub.addEventListener(MouseEvent.MOUSE_DOWN, onButtonOpenSubClicked);
			this.btn_open_sub.addEventListener(MouseEvent.MOUSE_OVER, onButtonOpenSubOver);
			this.btn_open_sub.addEventListener(MouseEvent.MOUSE_OUT, onButtonOpenSubOut);
		}
		// called by the game engine when this .swf has finished loading
		public function onLoaded():void{
			visible = true;
			gameAPI.SendServerCommand( "my_command arg1 arg2" );
		}
		//sends the selected class to the game as (FUNCTIONNAME, int) hopefully 
		private function onButtonOpenSubClicked(event:MouseEvent) : void {
			if(State==0){
				Burst.alpha=0;
				State=1;
				textbox1.text="Click again to close";
				textbox2.text="Click again to close";
				gameAPI.SendServerCommand("OpenSubMenu");
			}
			else if(State==1){
				State=2;
				gameAPI.SendServerCommand("CloseSubMenu");
			}
			else if(State==2){
				State=1;
				gameAPI.SendServerCommand("OpenSubMenu");
				textbox1.text="Click again to close";
				textbox2.text="Click again to close";
				
			}
        }
		//Mouseover on
		private function onButtonOpenSubOver(event:MouseEvent) : void {
			textbox1.text="Select Subclass";
			textbox2.text="Select Subclass";
			if(State==1 ){
				textbox1.text="Click again to close";
				textbox2.text="Click again to close";
			}
        }
		//Mouseover off
		private function onButtonOpenSubOut(event:MouseEvent) : void {
			textbox1.text="";
			textbox2.text="";
			if(State==1 ){
				textbox1.text="Click again to close";
				textbox2.text="Click again to close";
			}
			
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
