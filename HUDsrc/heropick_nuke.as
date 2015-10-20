﻿package 
{
    import ValveLib.*;
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;

    public class heropick_nuke extends MovieClip
    {
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;
        public var selectedclass:Number = 0;
        private var selector:MovieClip;

        public function onLoaded() : void
        {
            visible = false;
            Globals.instance.resizeManager.AddListener(this);
            this.selector = this.globals.Loader_shared_heroselectorandloadout.movieClip;
            addEventListener(Event.ENTER_FRAME, this.EnterFrame);
            return;
        }// end function

        public function EnterFrame(event:Event)
        {
            if (this.selector.visible == true)
            {
                this.selector.visible = false;
                trace("HeroPick Nuked!");
                this.visible = true;
                removeEventListener(Event.ENTER_FRAME, this.EnterFrame);
            }
            return;
        }// end function
    }
}
