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
		
		
		public function  trolltribes() {
			// constructor code
			// Note this DOES run for some reason.
			trace("## trolltribes Hello World from the Constructor. 2222");
	//		SFTest_showSubclassMenu();
		}
				
		public function onItemClick(item:String){
			trace("AS " + item);
			gameAPI.SendServerCommand("tae_buy_item " + item);
		}
		
		public function onBuildingClick(building:String){
			trace("Building " + building);
			gameAPI.SendServerCommand("tae_wants_to_build " + building);
		}
		
        public function onPanelClose(obj:Object){
        	obj.target.parent.visible = false;
        }

        public function onMouseClickItem(keys:MouseEvent){
        	trace("click");
       		var s:Object = keys.target;

       		trace("Bought " + s.itemName);

        }

       	public function onMouseRollOver(keys:MouseEvent){
       		
       		var s:Object = keys.target;
       		trace("roll over! " + s.itemName);
            // Workout where to put it
            var lp:Point = s.localToGlobal(new Point(0, 0));

            // Decide how to show the info
            if(lp.x < realScreenWidth/2) {
                // Workout how much to move it
                var offset:Number = 16*scalingFactor;

                // Face to the right
                globals.Loader_rad_mode_panel.gameAPI.OnShowAbilityTooltip(lp.x+offset, lp.y, s.getResourceName());
            } else {
                // Face to the left
                globals.Loader_heroselection.gameAPI.OnSkillRollOver(lp.x, lp.y, s.getResourceName());
            }
       	}

       	public function onMouseRollOut(keys:Object){
       		 globals.Loader_heroselection.gameAPI.OnSkillRollOut();
       	}
		public function tempEvent1(args:Object) : void {
			trace("WE ARE FREE, FREE AS A BIRD, A CYBER BIRD");
		}
		public function tempEvent2(args:Object) : void {
			trace("EXTERMINATE, EXTERMINATE");
		}
		
		public function onLoaded() : void {
			//trace('globals:');
			//PrintTable(globals, 1);
			trace("## trolltribes Fixing healthbar");
			
			// constructor code
			//trace("### trolltribes killing inventory UI");
			//PrintTable(globals.Loader_inventory.movieClip.inventory, 1);
			//globals.Loader_inventory.movieClip.removeChild(globals.Loader_inventory.movieClip.inventory);
			trace("## trolltribes Starting  trolltribes HUD");
			visible = true;
			
			Translate = Globals.instance.GameInterface.Translate;
			
			globals.scaleX = 0.5;
			globals.scaleY = 0.5;
			
			trace("Loading kv..");

			gameAPI.SubscribeToGameEvent("fl_level_6", this.showSubclassMenu);

			dotaButtonClass = getDefinitionByName("button_big");
			subclip = new subSelect();
			//Resizing is blitz
			Globals.instance.resizeManager.AddListener(this);
			trace("###DONE");
			
		}

		public function showSubclassMenu(keys:Object){
	//		PrintTable(keys);
			if (globals.Players.GetLocalPlayer() == keys.pid || keys.pid == -1)
			{
				trace("Got my thing!");
				gameAPI.SendServerCommand("acknowledge_flash_event " + "fl_level_6" + " " + globals.Players.GetLocalPlayer() + " " + keys.id);
				trace("Sent server cmd!\n\n\n");
				var gameclass:String = keys.gameclass;
				trace("Got gameclass");
				//Class is in the event. Class select movieclip is filled with assets for all classes. Find any not for this class and invis them.
				for(var i = 0; i < subclip.numChildren; i++)
				{
					var child = subclip.getChildAt(i);
					trace("Child: " + child);
					if(child == null){
						continue;
					}
					var childName:String = child.name
					trace("Name: +" + childName);
					if(childName != null && childName != "" && childName.indexOf("expbox") == -1 && childName.indexOf(gameclass) == -1 ){
						child.visible = false;
					}
				}
				trace("Making buttons..");
		//		makeButton("1", subclip.getChildByName(gameclass + "1") as MovieClip, subclip.getChildByName("selectsub1") as MovieClip);
		//		makeButton("2", subclip.getChildByName(gameclass + "2") as MovieClip, subclip.getChildByName("selectsub2") as MovieClip);
		//		makeButton("3", subclip.getChildByName(gameclass + "3") as MovieClip, subclip.getChildByName("selectsub3") as MovieClip);
				var txt1 = subclip.getChildByName(gameclass + "1");
				var txt2 = subclip.getChildByName(gameclass + "2");
				var txt3 = subclip.getChildByName(gameclass + "3");
				txt1.visible = true;
				txt2.visible = true;
				txt3.visible = true;
				txt1.addEventListener(MouseEvent.CLICK, subSelectButtonClick);
				txt2.addEventListener(MouseEvent.CLICK, subSelectButtonClick);
				txt3.addEventListener(MouseEvent.CLICK, subSelectButtonClick);
				txt1.choice = "1";
				txt2.choice = "2";
				txt3.choice = "3";
				txt1.buttonMode = true;
				txt2.buttonMode = true;
				txt3.buttonMode = true;
				subclip.getChildByName("clip_headerText").visible = true;
				subclip.getChildByName("clip_baseClip").visible = true;
				subclip.getChildByName("clip_headerClip").visible = true;
				subclip.getChildByName("clip_picframe1").visible = true;
				subclip.getChildByName("clip_picframe2").visible = true;
				subclip.getChildByName("clip_picframe3").visible = true;
				subclip.getChildByName("clip_divider1").visible = true;
				subclip.getChildByName("clip_divider2").visible = true;
				subclip.getChildByName("clip_divider3").visible = true;
				var btn1:MovieClip = subclip.getChildByName("clip_btn1") as MovieClip;
				var btn2:MovieClip = subclip.getChildByName("clip_btn2") as MovieClip;
				var btn3:MovieClip = subclip.getChildByName("clip_btn3") as MovieClip;
				btn1.buttonMode = true;
				btn2.buttonMode = true;
				btn3.buttonMode = true;
				btn1.visible = true;
				btn1.choice = "1";
				btn1.addEventListener(MouseEvent.CLICK, subSelectButtonClick);
				btn2.addEventListener(MouseEvent.CLICK, subSelectButtonClick);
				btn2.visible = true;
				btn2.choice = "2";
				btn3.addEventListener(MouseEvent.CLICK, subSelectButtonClick);
				btn3.visible = true;
				btn3.choice = "3";
				subclip.getChildByName("clip_patch").visible = true;
				subclip.visible = true;
				addChild(subclip);
			}
		}

		public function makeButton(pname:String, textclip:MovieClip, anchor:MovieClip){
			trace("Makebutton!");
			var button:MovieClip = new dotaButtonClass();
			trace("Adding..!");
			subclip.addChild(button);
			trace("Added!");
			button.name = pname;
			button.x = anchor.x;
			button.text = "";
			button.y = anchor.y;
			trace("Aligned!");
			button.addEventListener(ButtonEvent.CLICK, subSelectButtonClick);	
			button.visible = true;
			trace("Swapping..");
			if(textclip == null){
				trace("null textchilp?");
			}
			subclip.swapChildren(textclip, button);
		//	button.addChild(textclip);
		}
		
		public function subSelectButtonClick(e:MouseEvent){
			trace("BEV!")
			gameAPI.SendServerCommand("select_sub " + e.target.choice);
			
			subclip.visible = false;
		}

		public function SFTest_showSubclassMenu(){
			subclip = new subSelect();
			trace("Got my thing!\n\n\n");
			var gameclass:String = "gatherer";
			//Class is in the event. Class select movieclip is filled with assets for all classes. Find any not for this class and invis them.
			trace("Entering loop..");
			trace("Num children? " + subclip.numChildren);
			for(var i = 0; i < subclip.numChildren; i++)
			{
				trace("Loop " + i);
				var child:MovieClip = subclip.getChildAt(i) as MovieClip;
				trace("Got child! " + child);
				if(child == null){
					continue;
				}
				var childName:String = child.name
				trace("Got child: " + childName);
				if(childName != null && childName != "" && childName.indexOf("expbox") == -1 && childName.indexOf(gameclass) == -1){
					child.visible = false;
				}
			}
			subclip.visible = true;
			addChild(subclip);
			trace("Done with loop..");
			SFTest_makeButton("1", subclip.getChildByName(gameclass + "1") as MovieClip, subclip.getChildByName("selectsub1") as MovieClip);
			SFTest_makeButton("2", subclip.getChildByName(gameclass + "1") as MovieClip, subclip.getChildByName("selectsub2") as MovieClip);
			SFTest_makeButton("3", subclip.getChildByName(gameclass + "1") as MovieClip, subclip.getChildByName("selectsub3") as MovieClip);

			trace("INVISME vis? " + subclip.clip_invisme.visible);
			trace("gathererthing vis? " + subclip.clip_gatherersub2_exp.visible);
		}

		public function SFTest_makeButton(pname:String,  textclip:MovieClip, anchor:MovieClip){
			trace("Making!");
			var button:MovieClip = new MovieClip();
			subclip.addChild(button);
			trace("Added!");
			button.name = pname;
			button.x = anchor.x;
			button.y = anchor.y;
			trace("X: " + button.x + " Y: " + button.y);
		//	button.addEventListener(ButtonEvent.CLICK, subSelectButtonClick);	
			button.visible = true;
			subclip.swapChildren(button, textclip);
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
