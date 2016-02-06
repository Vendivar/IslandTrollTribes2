"use strict";

var contID = -1;
var idString = "";
var subscription = -1;
var isShop = false;
var positionString = null;

var oldSkins = {};

function TakeAll()
{
  var panel = $.GetContextPanel();
  panel.ToggleClass("Hourglass");
}

function GetID()
{
  return contID;
}

function GetIDString()
{
  return idString;
}

function ContainerChange(tableName, changes, del)
{
  var panel = $.GetContextPanel();
  $.Msg('ContainerChange -- ', tableName, ' -- ', changes, ' -- ', del);
  if (!changes)
    return;

  if ("headerText" in del)
    SetHeaderText("");

  if ("buttons" in del)
    SetButtons({});

  if ("OnCloseClicked" in del)
    $("#CloseButton").visible = true;

  if ("position" in del)
    positionString = null;



  if ("skins" in changes)
    SetSkins(changes["skins"]);

  if ("headerText" in changes)
    SetHeaderText(changes["headerText"]);

  if ("layout" in changes)
    SetLayout(changes["layout"]);

  if ("buttons" in changes)
    SetButtons(changes["buttons"]);

  if ("draggable" in changes)
    panel.SetDraggable(changes["draggable"] !== 0);

  if ("position" in changes)
    SetPosition(changes["position"]);

  if ("shop" in changes)
    isShop = changes["shop"] == 1;

  if ("OnCloseClicked" in changes)
    $("#CloseButton").visible = changes["OnCloseClicked"] !== 0;
}

function SetSkins(skins)
{
  var panel = $.GetContextPanel();

  for (var key in skins){
    $.Msg("skin: ", key);
    panel.SetHasClass(key, true);
    delete oldSkins[key];
  }

  for (var key in oldSkins){
    $.Msg("oldskin: ", key);
    panel.SetHasClass(key, false);
  }

  oldSkins = skins;
}

function SetHeaderText(text)
{
  var label = $("#HeaderLabel");
  label.text = $.Localize(text);
}

function SetLayout(layout)
{
  var inner = $("#Inner");
  inner.RemoveAndDeleteChildren();

  var slot = 1;
   
  for (var key in layout){
    var row = $.CreatePanel( "Panel", inner, "row" + key);
    row.AddClass('ItemRow');
 
    //var queryUnit = Players.GetLocalPlayerPortraitUnit();
    //var item = Entities.GetItemInSlot( queryUnit, i );
 
    for (var j=0; j<layout[key]; j++){
      var child = $.CreatePanel( "Panel", row, "slot" + slot); 
      child.BLoadLayout("file://{resources}/layout/custom_game/containers/inventory_item.xml", false, false);
      child.SetItem( -1, contID, slot, $.GetContextPanel() );

      slot++;
    }
  }
}

function ButtonPress(number)
{
  $.Msg('ButtonPress', ' -- ', number);

  var action = PlayerTables.GetTableValue(idString, "OnButtonPressed");
  if (action !== 0){
    GameEvents.SendCustomGameEventToServer( "Containers_OnButtonPressed", {unit:Players.GetLocalPlayerPortraitUnit(), contID:contID, button:parseInt(number)} );
    return;
  }
}

function SetButtons(buttons)
{
  var footer = $("#Footer");
  footer.RemoveAndDeleteChildren();

  for (var number in buttons){
    var button = $.CreatePanel( "Button", footer, "Button" + number);
    button.SetDraggable(true);
    button.AddClass("ButtonBevel");
    button.SetPanelEvent("onactivate", (function(num){
      return function(){ ButtonPress(num); };
    })(number));

    var label =  $.CreatePanel( "Label", button, "");
    label.text = $.Localize(buttons[number]);

    $.RegisterEventHandler( 'DragStart', button, NullDragStart );
    $.RegisterEventHandler( 'DragEnd', button, NullDragEnd );
  }
}

function SetPosition(pos)
{
  var panel = $.GetContextPanel();
  if (pos == "mouse"){
    positionString = "mouse";
    var cursor = GameUI.GetCursorPosition();
    $.Msg(panel.contentwidth, " -- ", panel.contentheight);
    $.Msg(panel.actuallayoutwidth, " -- ", panel.actuallayoutheight);
    $.Msg(panel.desiredlayoutwidth, " -- ", panel.desiredlayoutheight);

    var x = cursor[0] - panel.desiredlayoutwidth/2;
    var y = cursor[1] - 25;

    panel.style.position = x + "px " + y + "px 0px;";
  }
  else if (pos == "entity"){
    positionString = "entity";
    var ent = PlayerTables.GetTableValue(idString, "entity");
    if (ent != undefined){
      var origin = Entities.GetAbsOrigin(ent)
      var wx = Game.WorldToScreenX(origin[0], origin[1], origin[2]);
      var wy = Game.WorldToScreenY(origin[0], origin[1], origin[2]);
      var sw = GameUI.CustomUIConfig().screenwidth;
      var sh = GameUI.CustomUIConfig().screenheight
      var scale = 1080 / sh;

      var x = scale * Math.min(sw - panel.desiredlayoutwidth,Math.max(0, wx - panel.desiredlayoutwidth/2));
      var y = scale * Math.min(sh - panel.desiredlayoutheight,Math.max(0, wy - panel.desiredlayoutheight - 50));

      panel.style.position = x + "px " + y + "px 0px;";
    }
    else
    {
      panel.style.position = "0px 0px 0px;";
    }
  }
  else {
    panel.style.position = pos;
    positionString = null;
  }
}

function NewContainer(id)
{
  var panel = $.GetContextPanel();
  contID = id;
  idString = "cont_" + id;

  subscription = PlayerTables.SubscribeNetTableListener(idString, ContainerChange);

  var pt = PlayerTables.GetAllTableValues(idString);
  $.Msg(pt);
  
  $.Msg("container panel created ", panel.id);

  SetSkins(pt.skins);
  SetHeaderText(pt.headerText);
  SetLayout(pt.layout);
  SetButtons(pt.buttons);
  panel.SetDraggable(pt.draggable !== 0);
  isShop = pt.shop === 1;

  if (pt.OnCloseClicked === 0 && $("#CloseButton"))
    $("#CloseButton").visible = false;


  var count = 0;
  var f = null;

  if (pt.position === "mouse" || pt.position === "entity"){
    panel.style.position = "-1000px -1000px 0px;"
    f = function(){
      count++;
      if (panel.desiredlayoutheight === 0){
        $.Schedule(1/30, f);      
        return;
      }

      SetPosition(pt.position);
    };

    $.Schedule(1/30, f);
  }
  else{
    panel.style.position = pt.position || "200px 200px 0px";
  }
}

function OpenContainer()
{
  var panel = $.GetContextPanel();

  if (!panel.visible && positionString){
    SetPosition(positionString);
  }

  panel.visible = true;
}

function CloseContainer()
{
  var panel = $.GetContextPanel();
  panel.visible = false;
}

function DeleteContainer()
{
  var panel = $.GetContextPanel();

  PlayerTables.UnsubscribeNetTableListener(subscription);
  if (panel){
    panel.deleted = true;
    CloseContainer();
  }
}

function IsShop()
{
  return isShop;
}

function CloseClicked()
{
  $.Msg("CloseClicked");

  var action = PlayerTables.GetTableValue(idString, "OnCloseClicked");
  if (action !== 0){
    GameEvents.SendCustomGameEventToServer( "Containers_OnCloseClicked", {unit:Players.GetLocalPlayerPortraitUnit(), contID:contID} );
    return;
  }
}




function OnDragStart( panelId, dragCallbacks )
{
  $.Msg('OnDragStart -- ', panelId)
  var panel = $('#' + panelId);

  dragCallbacks.displayPanel = panel;//panel;

  var cursor = GameUI.GetCursorPosition();

  dragCallbacks.offsetX = cursor[0] - panel.actualxoffset;//250;
  dragCallbacks.offsetY = cursor[1] - panel.actualyoffset;//20;
  dragCallbacks.removePositionBeforeDrop = false;
  return false;
} 

function OnDragEnd( panelId, draggedPanel )
{
  //$.Msg('OnDragEnd -- ', panelId, ' -- ', draggedPanel);
  draggedPanel.SetParent(draggedPanel.dragParent);
  return false; 
} 

function NullDragStart( panelId, dragCallbacks)
{
  return true;
}

function NullDragEnd( panelId, draggedPanel)
{
  return true;
}



(function(){
  //$.DispatchEvent("DOTAShowTitleTextTooltipStyled", $.GetContextPanel(), "Title asdf", "asdfasdf asdf asdf asdf asdf few fwef wef we", "StlyeClass") 

  //TestFunction();
  //TestFunctionTwo();

  var panel = $.GetContextPanel();
  var inner = $("#Inner");
  var close = $("#CloseButton");

  panel.NewContainer = NewContainer;
  panel.OpenContainer = OpenContainer;
  panel.CloseContainer = CloseContainer;
  panel.DeleteContainer = DeleteContainer;
  panel.GetID = GetID;
  panel.GetIDString = GetIDString;
  panel.IsShop = IsShop;

  if (panel.initialized){
    //containers = panel.containers;
    return;
  }

  panel.initialized = true;

  panel.dragParent = panel.GetParent();

  $.RegisterEventHandler( 'DragStart', panel, OnDragStart );
  $.RegisterEventHandler( 'DragEnd', panel, OnDragEnd );

  $.RegisterEventHandler( 'DragStart', inner, NullDragStart );
  $.RegisterEventHandler( 'DragEnd', inner, NullDragEnd );

  $.RegisterEventHandler( 'DragStart', close, NullDragStart );
  $.RegisterEventHandler( 'DragEnd', close, NullDragEnd );

})()
