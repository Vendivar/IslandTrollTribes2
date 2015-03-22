package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	
	public class SelectClass extends MovieClip
	{
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var element:String;
		
		//toxic's variables
		public var selectedclass:Number = 0;
		//0=hunter, 1=gatherer, 2=scout, 3=thief, 4=priest, 5=mage 6=bm
		
		public function SelectClass() { 
			this.button_hunter.addEventListener(MouseEvent.MOUSE_DOWN, onButtonHunterClicked);
			this.button_gatherer.addEventListener(MouseEvent.MOUSE_DOWN, onButtonGathererClicked);
			this.button_scout.addEventListener(MouseEvent.MOUSE_DOWN, onButtonScoutClicked);
			this.button_thief.addEventListener(MouseEvent.MOUSE_DOWN, onButtonThiefClicked);
			this.button_priest.addEventListener(MouseEvent.MOUSE_DOWN, onButtonPriestClicked);
			this.button_mage.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMageClicked);
			this.button_beastmaster.addEventListener(MouseEvent.MOUSE_DOWN, onButtonBeastmasterClicked);
			
			this.button_select2.addEventListener(MouseEvent.CLICK, onButtonSelectClicked);
			this.button_select2.addEventListener(MouseEvent.MOUSE_OVER, onButtonSelectOver);
			this.button_select2.addEventListener(MouseEvent.MOUSE_OUT, onButtonSelectOut);
		}
		// called by the game engine when this .swf has finished loading
		public function onLoaded():void
		{
			visible = true;
			gameAPI.SendServerCommand( "my_command arg1 arg2" );
		}
		//the following 7 functions set selected class to the value for the current class
		private function onButtonHunterClicked(event:MouseEvent) : void {
			selectedclass=0;
			textbox.text='Hunter';
			biobox.text='A troll specialized in physical combat.\n\nHis strength is unrivaled by any other troll.\n\nHis abilities allow him to track and ensnare enemies to prevent their escape for easy meat and xp.\n\nSlots: 3\nDifficulty: Easy\n\nPros:\nEasiest to hunt with\nHighest physical damage output\nSome offensive spells\n\nCons:\nVery few slots\nLimited skill library\n';
        }
		private function onButtonGathererClicked(event:MouseEvent) : void {
			selectedclass=1;
			textbox.text='Gatherer';
			biobox.text='A troll specialized in gathering resources.\n\nWeak and slow but makes up for it with a huge carrying capacity.\n\nHis abilities allow him to ping resources on the map to make it easier to obtain what he needs.\n\nSlots: 6\nDifficulty: Medium\n\nPros:\nOnly troll that can make 6-slot items in his inventory\nGreat late-game due to equipment potential\nCan find rarer items with ease\n\nCons:\nLow physical damage\nNo offensive abilities';
        }
		private function onButtonScoutClicked(event:MouseEvent) : void {
			selectedclass=2;
			textbox.text='Scout';
			biobox.text='A troll specialized in finding enemies and animals.\n\nWeak but makes up for it with his ability to level fairly fast by finding things to kill.\n\nHis abilities allow him to ping animals/enemies and reveal large areas.\n\nSlots: 5\nDifficulty: Average\n\nPros:\nCan find animals and enemies easily\nGood number of slots\nCan reveal large areas to gather and hunt more efficiently\n\nCons:\nLow physical damage\nNo damage abilities or status effects';
        }
		private function onButtonThiefClicked(event:MouseEvent) : void {
			selectedclass=3;
			textbox.text='Thief';
			biobox.text='A troll specialized in stealing and escaping.\n\nWeak but is very hard to kill.\n\nHis abilities allow him to blink to an area he can see and go invisible, allowing him to steal items from enemy bases early-on with little risk.\n\nSlots: 5\nDifficulty: Average\n\nPros:\nHigh potential for early-game harassment and theft\nGood number of slots\nBest night vision\n\nCons:\nLow physical damage\nNo damage abilities or status effects';
        }
		private function onButtonPriestClicked(event:MouseEvent) : void {
			selectedclass=4;
			textbox.text='Priest';
			biobox.text='A troll specialized in beneficial magic.\n\nWeak and slow but this can easily be changed by buffing himself.\n\nHis abilities allow him to buff, cure, and protect his allies or himself making him much stronger than his stats imply.\n\nSlots: 4\nDifficulty: Hard\n\nPros:\nBuffs allow him to output more damage than usual\nCan cure poisons and block magical attacks\nPassive aura makes survival easier\n\nCons:\nSpells uses energy which can kill you if used incorrectly\nNo offensive spells';
        }
		private function onButtonMageClicked(event:MouseEvent) : void {
			selectedclass=5;
			textbox.text='Mage';
			biobox.text='A troll specialized in offensive magic.\n\nWeak and slow but this is easily substituted by huge magical damage output.\n\nHis abilities allow him to debuff and damage enemies.\n\nSlots: 4\nDifficulty: Hard\n\nPros:\nCan slow and damage enemies\nGreat early-game\nEasy to hunt with\n\nCons:\nSpells uses energy which can kill you if used incorrectly\nLow physical damage';
        }
		private function onButtonBeastmasterClicked(event:MouseEvent) : void {
			selectedclass=6;
			textbox.text='Beastmaster';
			biobox.text='A troll specialized in animal fury.\n\nPhysically strong and fast.\n\nHis abilities are limited but he can tame creatures to fight for him, and has a passive which slows nearby animals and deals minor damage to them.\n\nSlots: 4\nDifficulty: Easy\n\nPros:\nSecond highest physical damage output\nCan tame creatures for extra damage\nCan slow and damage animals\n\nCons:\nVery few abilities\nDoes not get abilities every level';
		}
		//sends the selected class to the game as (FUNCTIONNAME, int) hopefully 
		private function onButtonSelectClicked(event:MouseEvent) : void {
			gameAPI.SendServerCommand("SelectClass "+selectedclass);
        }
		//Mouseover on
		private function onButtonSelectOver(event:MouseEvent) : void {
			button_select2.alpha=1;
        }
		//Mouseover off
		private function onButtonSelectOut(event:MouseEvent) : void {
			button_select2.alpha=0;
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
