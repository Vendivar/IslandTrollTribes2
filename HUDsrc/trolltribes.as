package  {
	// Flash Libraries
	import flash.display.MovieClip;

    // Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.*;
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import flash.geom.ColorTransform;

    // Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.display.Shape;
    import flash.geom.Point;

    // For chrome browser
    import flash.utils.getDefinitionByName;
		
	public class  trolltribes extends MovieClip {
		//Game API stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;
		
		public static var Translate;
		
		// These vars determain how much of the stage we can use
        // They are updated as the stage size changes

        private static var X_SECTIONS = 1;      // How many sections in the x direction
        private static var Y_SECTIONS = 1;      // How many sections in the y direction

        private static var X_PER_SECTION = 1;   // How many skill lists in each x section
        private static var Y_PER_SECTION = 1;   // How many skill lists in each y section

        // How big a SelectSkillList is
        private static var SL_WIDTH = 43;
        private static var SL_HEIGHT = 43;

        private var ITEM_WIDTH = 100;
		private var ITEM_HEIGHT = 80;
		
		private var SPELL_WIDTH = 128;
		private var SPELL_HEIGHT = 128;
		
        private var ITEM_PADDING = 4;
        private var ROW_SIZE = 1100;
        private var COLUMN_SIZE = 300; 

        // How much padding to put between each list
        private static var S_PADDING = 2;

        public var res16by9Width:Number = 1920;
        public var res16by9Height:Number = 1080;
		
		public var res16by10Width:Number = 1680;
		public var res16by10Height:Number = 1050;
		
		public var res4by3Width:Number = 1280;
		public var res4by3Height:Number = 960;
		
		public var curRes:int = 3; //Invalid so that everything resizes
		
		public var resWidth:Number = res16by9Width;
		public var resHeight:Number = res16by10Width;
		
		//Default to 16by9 as that is the master resolution
		public var maxStageWidth:Number = res16by9Width;
		public var maxStageHeight:Number = res16by9Height;

		public var scalingFactor;

		public var realScreenWidth;

		public var realScreenHeight;

		public var myStageHeight = 720;

		private var itemsCustomKV;
		private var resourceCustomKV;

		private var dotaButtonClass;

		private var subclip:MovieClip;

		private var SubMage:MovieClip;
		private var SubPriest:MovieClip;
		private var SubBM:MovieClip;
		private var SubHunter:MovieClip;
		private var SubScout:MovieClip;
		private var SubThief:MovieClip;
		private var SubGatherer:MovieClip;

		private function loadSubs() { //ugh
			var cls = getDefinitionByName("SubBM");
			SubBM = new cls();
			cls = getDefinitionByName("SubHunter");
			SubHunter = new cls();
			cls = getDefinitionByName("SubMage");
			SubMage = new cls();
			cls = getDefinitionByName("SubPriest");
			SubPriest = new cls();
			cls = getDefinitionByName("SubScout");
			SubScout = new cls();
			cls = getDefinitionByName("SubThief");
			SubThief = new cls();
			cls = getDefinitionByName("SubGatherer");
			SubGatherer = new cls();
		}

		public function  trolltribes() {
			// constructor code
			// Note this DOES run for some reason.
			trace("## trolltribes Hello World from the Constructor. 2222");
			loadSubs();
			
			
	//		SFTest_showSubclassMenu();
		}
				
		public function onLoaded() : void {
			//trace('globals:');
			//PrintTable(globals, 1);
	//		trace(this.SubBM);
			
			// constructor code
			//trace("### trolltribes killing inventory UI");
			//PrintTable(globals.Loader_inventory.movieClip.inventory, 1);
			//globals.Loader_inventory.movieClip.removeChild(globals.Loader_inventory.movieClip.inventory);
			trace("## trolltribes Starting  trolltribes HUD");
			visible = true;
			
			gameAPI.SubscribeToGameEvent("fl_level_6", this.showSubclassMenu);

			trace("###DONE");
		}

		public function showSubclassMenu(keys:Object){
	//		PrintTable(keys);
			trace("Hello!");
			if (globals.Players.GetLocalPlayer() == keys.pid || keys.pid == -1)
			{
				trace("Got my thing!");
				var gameclass:String = keys.gameclass;
				if(gameclass != null)
				{
					var targ:String = "Sub" + gameclass; //be careful of this
					trace("I want to open" + targ);
					activateSub(targ);
				}
				
			}
		}

		public function activateSub(subname:String){
			var mysub:MovieClip = this[subname];

			mysub.Option00.addEventListener(MouseEvent.CLICK, Option1Clicked);
			mysub.Option01.addEventListener(MouseEvent.CLICK, Option2Clicked);
			mysub.Option02.addEventListener(MouseEvent.CLICK, Option3Clicked);
			mysub.ExitB.addEventListener(MouseEvent.CLICK, ExitClicked);


			mysub.visible = true;
			mysub.x = 350;
			mysub.y = 180;
			addChild(mysub);
			trace("This is new!");
		}

		public function ExitClicked(ev:MouseEvent){
			ev.target.parent.visible = false;
		}
		public function Option1Clicked(ev:MouseEvent){
			gameAPI.SendServerCommand("sub_select 1");
		}
		public function Option2Clicked(ev:MouseEvent){
			gameAPI.SendServerCommand("sub_select 2");
		}
		public function Option3Clicked(ev:MouseEvent){
			gameAPI.SendServerCommand("sub_select 3");
		}

		public function onResize(re:ResizeManager) : * {
			// Update the stage width

			x = 0;
			y = 0;

			visible = true;

			scalingFactor = re.ScreenHeight/myStageHeight;

		//	this.scaleX = scalingFactor;
		//	this.scaleY = scalingFactor;

			realScreenWidth = re.ScreenWidth;
			realScreenHeight = re.ScreenHeight;

			var workingWidth:Number = myStageHeight*4/3;

			
			trace("STAGE X: " + realScreenWidth);
			var subSelectXFill:Number = subclip.width / realScreenWidth;
			var subSelectYFill:Number = subclip.height / realScreenHeight;
			trace("Sub select is taking up percent X: " + subSelectXFill);
			trace("Sub select is taking up percent Y: " + subSelectYFill);
			if(subSelectXFill > 0.75) {
				trace("Changing X Scale..");
				var diffX = subSelectXFill - 0.75
				subclip.scaleX = 1 - diffX;
			}

			trace("Aligning with unitname..");

			subclip.x = (Globals.instance.Loader_actionpanel.movieClip.middle.unitName as DisplayObject).localToGlobal(new Point()).x;
			subclip.y += 100;
			subclip.x -= 200;
			trace("### Resizing");
			if (re.IsWidescreen()) {
				trace("### Widescreen detected!");
				//16:x
				if (re.Is16by9()) {
					if (curRes != 0) {
						curRes = 0;
						//lumberOverlay.onScreenResize(0, globals.instance.Game.IsHUDFlipped());
						try {
							trace("### trolltribes HUD Flipped to "+globals.instance.Game.IsHUDFlipped());
						} catch (Exception) {
							trace("###ERRROR Ok, this didn't work..."); //This actually is used, not quite sure why yet.
						}
					}
					trace("### trolltribes Resizing for 16:9 resolution");
					resWidth = res16by9Width;
					resHeight = res16by9Height;
					//1920 * 1080
				} else {
					if (curRes != 1) {
						curRes = 1;
						//lumberOverlay.onResize(1, globals.instance.Game.IsHUDFlipped());
					}
					trace("### trolltribes Resizing for 16:10 resolution");
					resWidth = res16by10Width;
					resHeight = res16by10Height;
					//1680 * 1050
				}
			} else {
				trace("### trolltribes Resizing for 4:3 resolution");
				if (curRes != 2) {
					curRes = 2;
					//lumberOverlay.onScreenResize(2, globals.instance.Game.IsHUDFlipped());
				}
				resWidth = res4by3Width;
				resHeight = res4by3Height;
				//1280 * 960
			}
			
			maxStageHeight = re.ScreenHeight / re.ScreenWidth * resWidth;
			maxStageWidth = re.ScreenWidth / re.ScreenHeight * resHeight;
            //Scale hud to screen
      //      this.scaleX = re.ScreenWidth/maxStageWidth;
     //       this.scaleY = re.ScreenHeight/maxStageHeight;
		}
		
		// Shamelessly stolen from Frota
        public function strRep(str, count) {
            var output = "";
            for(var i=0; i<count; i++) {
                output = output + str;
            }

            return output;
        }

        public function isPrintable(t) {
        	if(t == null || t is Number || t is String || t is Boolean || t is Function || t is Array) {
        		return true;
        	}
        	// Check for vectors
        	if(flash.utils.getQualifiedClassName(t).indexOf('__AS3__.vec::Vector') == 0) return true;

        	return false;
        }

        public function PrintTable(t, indent=0, done=null) {
        	var i:int, key, key1, v:*;

        	// Validate input
        	if(isPrintable(t)) {
        		trace("PrintTable called with incorrect arguments!");
        		return;
        	}

        	if(indent == 0) {
        		trace(t.name+" "+t+": {")
        	}

        	// Stop loops
        	done ||= new flash.utils.Dictionary(true);
        	if(done[t]) {
        		trace(strRep("\t", indent)+"<loop object> "+t);
        		return;
        	}
        	done[t] = true;

        	// Grab this class
        	var thisClass = flash.utils.getQualifiedClassName(t);

        	// Print methods
			for each(key1 in flash.utils.describeType(t)..method) {
				// Check if this is part of our class
				if(key1.@declaredBy == thisClass) {
					// Yes, log it
					trace(strRep("\t", indent+1)+key1.@name+"()");
				}
			}

			// Check for text
			if("text" in t) {
				trace(strRep("\t", indent+1)+"text: "+t.text);
			}

			// Print variables
			for each(key1 in flash.utils.describeType(t)..variable) {
				key = key1.@name;
				v = t[key];

				// Check if we can print it in one line
				if(isPrintable(v)) {
					trace(strRep("\t", indent+1)+key+": "+v);
				} else {
					// Open bracket
					trace(strRep("\t", indent+1)+key+": {");

					// Recurse!
					PrintTable(v, indent+1, done)

					// Close bracket
					trace(strRep("\t", indent+1)+"}");
				}
			}

			// Find other keys
			for(key in t) {
				v = t[key];

				// Check if we can print it in one line
				if(isPrintable(v)) {
					trace(strRep("\t", indent+1)+key+": "+v);
				} else {
					// Open bracket
					trace(strRep("\t", indent+1)+key+": {");

					// Recurse!
					PrintTable(v, indent+1, done)

					// Close bracket
					trace(strRep("\t", indent+1)+"}");
				}
        	}

        	// Get children
        	if(t is MovieClip) {
        		// Loop over children
	        	for(i = 0; i < t.numChildren; i++) {
	        		// Open bracket
					trace(strRep("\t", indent+1)+t.name+" "+t+": {");

					// Recurse!
	        		PrintTable(t.getChildAt(i), indent+1, done);

	        		// Close bracket
					trace(strRep("\t", indent+1)+"}");
	        	}
        	}

        	// Close bracket
        	if(indent == 0) {
        		trace("}");
        	}
        }
	}	
}
