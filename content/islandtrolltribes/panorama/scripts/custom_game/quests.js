var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

var quests_table = {};

function AddQuest(id, quest) {
  $.Msg("Adding a quest with id " + id);
  quests_table[id] = quest;

  var panel = $.CreatePanel("Panel", $("#QuestsMainPanel"), "");
  panel.AddClass("Quest");
  quests_table[id]["mainpanel"] = panel;

  var icon = $.CreatePanel("Label", panel, "");
  icon.AddClass("QuestIcon");
  icon.text = "!";

  var content = $.CreatePanel("Panel", panel, "");
  content.AddClass("QuestContent");

  var header = $.CreatePanel("Label", content, "");
  header.AddClass("QuestHeader");
  header.text = $.Localize(quest.title, header);

  if (quest.progress_bar !== 0) {
    var bar = $.CreatePanel("Panel", content, "");
    bar.AddClass("QuestProgressBarBg");

    var left_bar = $.CreatePanel("Panel", bar, "");
    left_bar.AddClass("QuestProgressBarBg_Left");

    var right_bar = $.CreatePanel("Panel", bar, "");
    right_bar.AddClass("QuestProgressBarBg_Right");

    var progress = $.CreatePanel("Panel", bar, "");
    progress.AddClass("QuestProgressBar");
    progress.from = quest.progress_bar.from;
    progress.to = quest.progress_bar.to;
    quests_table[id]["progressbar"] = progress;

    progress.style.width = "0px";
  }

  if (quest.desc) {
    var text = $.CreatePanel("Label", content, "");
    text.AddClass("QuestDesc");
    text.text = $.Localize(quest.desc, text);
  }
  
    Game.EmitSound("quest.new")
}

function UpdateQuest(id, quest) {
  if (quest.finished === 1) {
    quests_table[id].finished = true;

    var panel = quests_table[id].mainpanel;
    panel.DeleteAsync(0);
    Game.EmitSound("quest.complete")
    // End a quest
  }
  else {
    quests_table[id].current = quest.current;

    var bar = quests_table[id].progressbar;
    bar.style.width = Math.floor(200 * (quest.current / bar.to)) + "px";
    // Update the progress bar
  }
}

function IncomingData(table, changes, deletions) {
  $.Msg(changes);
  for (var key in changes) {
    var id = parseInt(key);
    if (quests_table[id]) {
      // Update an existing quest.
      UpdateQuest(key, changes[key])
    }
    else {
      // A new quest appears!
      AddQuest(key, changes[key])
    }
  }
}

(function() {
  PlayerTables.SubscribeNetTableListener("quests_" + Players.GetLocalPlayer(), IncomingData);
})();
