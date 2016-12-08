function teamMemberUp(args) {
  var player = args.player;
  var hero = args.hero;

  // Taken from chat.js
  var line = $.CreatePanel("Panel", $("#RevivePanel"), "");
  line.AddClass("ReviveNotification");

  var playerName = "You have"
  if (player != Players.GetLocalPlayer()) {
    playerName = Players.GetPlayerName(player);
    playerName = playerName + " has"
  }

    Game.EmitSound("revive2.layered")
	
  var img = $.CreatePanel("DOTAHeroImage", line, "");
  img.AddClass("ReviveNotification_icon");
  img.heroimagestyle = "icon";
  img.heroname = hero;

  var label = $.CreatePanel("Label", line, "");
  label.SetDialogVariable("name", playerName);
  label.html = true;
  label.text = $.Localize("#ReviveMessage", label);

    Game.EmitSound("revive2")
	
	
  $.Schedule(4, function(){
      line.DeleteAsync(0)
  });
}

(function() {
  GameEvents.Subscribe("team_member_up", teamMemberUp);
})();