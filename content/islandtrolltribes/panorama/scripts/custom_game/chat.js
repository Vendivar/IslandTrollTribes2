
GameUI.GameChat = $("#GameChatContent");
GameUI.ChatActivated = false;

function AddChatLine(playerName, steamid, color, message, isTeamChat) {
    var line = $.CreatePanel("Panel", $("#GameChatContent"), "");
    var last = $("#GameChatContent").GetChild(0);
    line.AddClass("GameChatLine");
    line.AddClass("GameChatLineAppear");

    if (last != null) {
        $("#GameChatContent").MoveChildBefore(line, last);
    }

    if (steamid !== "") {
      var img = $.CreatePanel("DOTAAvatarImage", line, "");
      img.AddClass("GameChatImage");
      img.steamid = steamid
    }

    var label = $.CreatePanel("Label", line, "");
    label.SetDialogVariable("name", playerName);
    label.SetDialogVariable("color", color);
    label.SetDialogVariable("message", message);
    if (isTeamChat) {
        label.SetDialogVariable("type","(TEAM) ");
    }
    else {
        label.SetDialogVariable("type","");
    }
    label.html = true;
    label.text = $.Localize("#ChatLine", label);

    $.Schedule(0.1, function() {
      $("#GameChatContent").ScrollToBottom();
    });

    $.Schedule(5, function(){
        line.AddClass("GameChatLineHidden");
    });
}

function OnCustomChatSay(args) {
    var color = LuaColor(args.color);
    $.Msg("Message arrived!");

    var name;
    var steamid;
    if (args.player !== undefined) {
      name = Players.GetPlayerName(args.player);
      if (args.name.length > 0) {
          name = args.name;
      }

      steamid = Game.GetPlayerInfo(args.player).player_steamid;
    }
    else {
      name = "(SYSTEM)"
      steamid = ""
    }

    AddChatLine(name, steamid, color, args.message, args.isTeam);
}

(function() {
  $.Msg("Chat loaded in!");

  GameEvents.Subscribe("custom_chat_say", OnCustomChatSay);
  AddEnterListener("GameHudChatEnter", function() {
    GameUI.ChatActivated = false;
    $("#GameChatEntryContainer").BLoadLayout("file://{resources}/layout/custom_game/chat.xml", true, true);
    $("#GameChatEntry").SetFocus();
    $("#GameChatContent").RemoveClass("ChatHidden");
    $("#GameChatContent").ScrollToBottom();
    if (GameUI.IsShiftDown()) {
      GameUI.teamChat = false;
      $("#GameChatEntryType").text = "(ALL) ";
    }
    else {
      GameUI.teamChat = true;
      $("#GameChatEntryType").text = "(TEAM) ";
    }
  });
})();
