var reload = true;

$.Msg("playertables_base.js");

var PlayerTables = {};

PlayerTables.GetAllTableValues = function(tableName)
{
  var PT = CustomNetTables.__PT;
  var table = PT.tables[tableName];
  if (table)
    return JSON.parse(JSON.stringify(table));

  return null;
};


PlayerTables.GetTableValue = function(tableName, keyName)
{
  var PT = CustomNetTables.__PT;
  var table = PT.tables[tableName];
  if (!table)
    return null;

  var val = table[keyName];

  if (typeof val === 'object')
    return JSON.parse(JSON.stringify(val));

  return val;
};

PlayerTables.SubscribeNetTableListener = function(tableName, callback) 
{
  var PT = CustomNetTables.__PT;
  var listeners = PT.tableListeners[tableName];
  if (!listeners){
    listeners = {};
    PT.tableListeners[tableName] = listeners;
  }

  var ID = PT.nextListener;
  PT.nextListener++;

  listeners[ID] = callback;
  PT.listeners[ID] = tableName;

  return ID;
};

PlayerTables.UnsubscribeNetTableListener = function(callbackID)
{
  var PT = CustomNetTables.__PT;
  var tableName = PT.listeners[callbackID];
  if (tableName){
    if (PT.listeners[tableName]){
      var listener = PT.listeners[tableName][callbackID];
      if (listener){
        delete PT.listeners[tableName][callbackID];
      }
    }

    delete PT.tableListeners[callbackID];
  }
  
  return;
};

function isEquivalent(a, b) {
    var aProps = Object.getOwnPropertyNames(a);
    var bProps = Object.getOwnPropertyNames(b);

    if (aProps.length != bProps.length) {
        return false;
    }

    for (var i = 0; i < aProps.length; i++) {
        var propName = aProps[i];

        if (a[propName] !== b[propName]) {
            return false;
        }
    }

    return true;
}

function ProcessTable(newTable, oldTable, changes, dels)
{
  for (var k in newTable)
  {
    var n = newTable[k];
    var old = oldTable[k];

    if (typeof(n) == typeof(old) && typeof(n) == "object"){
      if (!isEquivalent(n, old)){
        changes[k] = n;
      }

      delete oldTable[k];
    }
    else if (n !== old){
      changes[k] = n;
      delete oldTable[k];
    }
    else if (n === old){
      delete oldTable[k];
    }
  }

  for (var k in oldTable)
  {
    dels[k] = true;
  }
}

function SendPID()
{
  var pid = Players.GetLocalPlayer();
  var spec = Players.IsSpectator(pid);
  $.Msg(pid, ' -- ', spec);
  if (pid == -1 && !spec){
    $.Schedule(1/30, SendPID);
    return;
  }

  GameEvents.SendCustomGameEventToServer( "PlayerTables_Connected", {pid:pid} );
}
 
(function(){

  if (!CustomNetTables.__PT || reload)
  {
    var count = 0;
    var _PT = {
      listeners: {},
      tableListeners: {},
      nextListener: 0,
      tables: {},
      subs: []
    };

    _PT.TableFullUpdate = function(msg)
    {
      $.Msg('TableFullUpdate -- ', msg);
      //msg.table = UnprocessTable(msg.table);
      var newTable = msg.table;
      var oldTable = _PT.tables[msg.name];

      if (!newTable)
        delete _PT.tables[msg.name];
      else
        _PT.tables[msg.name] = newTable;

      var listeners = _PT.tableListeners[msg.name] || {};
      var len = Object.keys(listeners).length;
      var changes = null;
      var dels = null;

      if (len > -1 && newTable){
        if (!oldTable){
          changes = newTable;
          dels = {};
        }
        else {
          changes = {};
          dels = {};
          ProcessTable(newTable, oldTable, changes, dels);
        }
      }

      for (var k in listeners){
        try{ listeners[k](msg.name, changes, dels);} catch(err){$.Msg("PlayerTables.TableFullUpdate callback error for '", msg.name, " -- ", newTable, "': ", err);};
      }
    };

    _PT.UpdateTable = function(msg)
    {
      $.Msg('UpdateTable -- ', msg);
      //msg.changes = UnprocessTable(msg.changes);

      var table = _PT.tables[msg.name];
      if (!table)
      {
        $.Msg("PlayerTables.UpdateTable invoked on nonexistent playertable.");
        return;
      }

      var t = {};

      for (var k in msg.changes){
        var value = msg.changes[k];

        table[k] = value;
        if (typeof value === 'object')
          t[k] = JSON.parse(JSON.stringify(value));
        else
          t[k] = value;
      }

      var listeners = _PT.tableListeners[msg.name] || {};
      for (var k in listeners){
        if (listeners[k]){
          try{ listeners[k](msg.name, t);} catch(err){$.Msg("PlayerTables.UpdateTable callback error for '", msg.name, " -- ", t, "': ", err);}      
        }
      }
    };

    _PT.DeleteTableKeys = function(msg)
    {
      $.Msg('DeleteTableKeys -- ', msg);
      var table = _PT.tables[msg.name];
      $.Msg(table);
      if (!table)
      {
        $.Msg("PlayerTables.DeleteTableKey invoked on nonexistent playertable.");
        return;
      }

      var t = {};

      for (var k in msg.keys){
        var value = msg.keys[k];

        delete table[k];
      }

      var listeners = _PT.tableListeners[msg.name] || {};
      for (var k in listeners){
        if (listeners[k]){
          try{ listeners[k](msg.name, {}, msg.keys);} catch(err){$.Msg("PlayerTables.DeleteTableKeys callback error for '", msg.name, " -- ", msg.keys, "': ", err);}
        }
      }
    }

    CustomNetTables.__PT = _PT;

    SendPID();
  }

  var _PT = CustomNetTables.__PT;
  $.Msg(_PT.listeners);

  GameEvents.Subscribe( "pt_table_full_update", _PT.TableFullUpdate);
  GameEvents.Subscribe( "pt_table_update", _PT.UpdateTable);
  GameEvents.Subscribe( "pt_table_key_delete", _PT.DeleteTableKeys);
})()