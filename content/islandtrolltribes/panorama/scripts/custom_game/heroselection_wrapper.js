var Root = $.GetContextPanel();
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
(function() {
  $("#Wrapper_Voting").BLoadLayout("file://{resources}/layout/custom_game/gamemode_selector.xml", false, false);
  $("#Wrapper_Hero").BLoadLayout("file://{resources}/layout/custom_game/class_picker.xml", false, false);

  $("#Wrapper_Chat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
  $("#Wrapper_Chat").RegisterListener("GamemodeSelectionEnter");
  GameUI.teamChat = false;

  PlayerTables.SubscribeNetTableListener("pickingover_" + Players.GetLocalPlayer(), PickingOver);

  $.Msg("Loaded hero selection!");
})();

function PickingOver(table, changes, deletions) {
    if (changes.over) {
        GameUI.Wrapper.Remove();
    }
}

GameUI.Wrapper = {};

var ind = 0;
GameUI.Wrapper.ToRight = function() {
  if (ind === 1) return;

  ind++;

  $("#Wrapper_Voting").style.x = "-100%";
  $("#Wrapper_Hero").style.x = "0%";

  $("#RightBtn_Wrapper").AddClass("hidden");
  $.Schedule(1, function() {
    $("#LeftBtn_Wrapper").RemoveClass("hidden");
  });
}

GameUI.Wrapper.ToLeft = function() {
  if (ind === 0) return;

  ind--;

  $("#Wrapper_Voting").style.x = "0%";
  $("#Wrapper_Hero").style.x = "100%";

  $("#LeftBtn_Wrapper").AddClass("hidden");
  $.Schedule(1, function() {
    $("#RightBtn_Wrapper").RemoveClass("hidden");
  });
}

GameUI.Wrapper.Unlock = function() {
  $("#RightBtn_Wrapper").RemoveClass("hidden");
  $("#RightBtn_Wrapper").AddClass("first_appear");
  $.Schedule(3, function() {
    $("#RightBtn_Wrapper").RemoveClass("first_appear");
  })
}

GameUI.Wrapper.Remove = function() {
  GameUI.RemoveEnterListener("GamemodeSelectionEnter");
  PlayerTables.UnsubscribeNetTableListener(GameUI.pickListenerID);
  PlayerTables.UnsubscribeNetTableListener(GameUI.voteListenerID);
  Root.DeleteAsync(0);
}
