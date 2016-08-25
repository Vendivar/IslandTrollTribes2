
var settings = {
  speed: 2,
  pick: 1,
  custom_noob: false,
  custom_fixedbush: false,
  custom_norevive: false,
  custom_noislandbosses: false
};

var voted = false;

var notvoted_players = {};
var voted_players = {};

var custom_active = false;

function setSpeed(speed) {
  $("#speed_" + settings["speed"]).RemoveClass("active_speed");

  settings["speed"] = speed;
  $("#speed_" + speed).AddClass("active_speed");
}

function setPick(pick) {
  $("#pick_" + settings["pick"]).RemoveClass("active_pick")

  settings["pick"] = pick;
  $("#pick_" + pick).AddClass("active_pick")
}

function toggleCustom() {
  custom_active = !custom_active

  if (custom_active) {
    $("#Gamemode_customwrapper").RemoveClass("hidden");
    $("#custom_options").AddClass("active_custom");
  }
  else {
    $("#Gamemode_customwrapper").AddClass("hidden");
    $("#custom_options").RemoveClass("active_custom");

    for (var i in settings) {
      if (i.slice(0,6) === "custom" && settings[i]) {
        setCustomToggle(i);
      }
    }
  }
}

function setCustomToggle(key) {
  settings[key] = !settings[key];

  if (settings[key]) {
    $("#" + key).AddClass("active_custom");
  }
  else {
    $("#" + key).RemoveClass("active_custom");
  }
}

function sendVote() {
  if (voted) return;
  GameEvents.SendCustomGameEventToServer("game_mode_selected", {
    settings: settings
  });
  voted = true

  $("#Gamemode_confirm").AddClass("hidden");
  $("#Gamemode_confirmed").RemoveClass("hidden");
}

function setNotVoted() {
  var labels = $("#Gamemode_notvoted").Children();
  for (i in labels) {
    if (i > 0) {
      labels[i].DeleteAsync(0);
    }
  }

  var i = 0;
  var player;
  var label;
  for (i in notvoted_players) {
    player = notvoted_players[i];

    label = $.CreatePanel("Label",$("#Gamemode_notvoted"),"");
    label.AddClass("player_line");
    label.text = player;
  }
}

function setVoted() {
  var labels = $("#Gamemode_voted").Children();
  for (i in labels) {
    if (i > 0) {
      labels[i].DeleteAsync(0);
    }
  }

  var i = 0;
  var player;
  var settings;
  var label;
  for (i in voted_players) {
    player = voted_players[i].player;
    settings = voted_players[i].settings;

    label = $.CreatePanel("Label", $("#Gamemode_voted"), "");
    label.AddClass("player_line");
    label.SetDialogVariable("player", player);
    label.SetDialogVariable("speed", settings.game_mode);
    label.SetDialogVariable("pick", settings.pick_mode);
    label.html = true

    var c = 0;
    var setting;
    var img;
    var custom = "";
    for (c in settings.custom_settings) {
      setting = settings.custom_settings[c];
      if (setting) {
        custom += c + " ";  // TODO: Replace this with the custom icons.
      }
    }
    label.SetDialogVariable("custom", custom);
    label.text = $.Localize("#Gamemode_player_line", label);
  }
}

function setPlayerList() {
  // Sets the initial playerlist.
  var i = 0;
  var player;
  for (i; i < 16; i++) {
    if (Players.IsValidPlayerID(i)) {
      player = Players.GetPlayerName(i);
      notvoted_players[i] = player;
    }
  }

  setNotVoted();
}

function OnVoteConfirmed(vote) {
  var player_confirmed = Players.GetPlayerName(vote.player);
  voted_players[vote.player] = {
    player: player_confirmed,
    settings: vote.settings
  };

  delete notvoted_players[vote.player];

  setNotVoted();
  setVoted();

  if (vote.voting_ended) {
    $.Msg("Voting has ended!");
    // Voting has ended!
    // TODO: Implement voting ending.
    // TODO: Remove gamemode selection screen and show hero selection, if needed.
    // vote.voted_settings
    $("#Gamemode_container").AddClass("hidden");

    // class_picker.js is handling the pick mode.
  }
}

(function() {
  GameEvents.Subscribe("vote_confirmed", OnVoteConfirmed);

  setPlayerList();
  $.GetContextPanel().SetFocus();
  GameUI.DenyWheel();

  $.Msg("Gamemode selection loaded!");
})()
