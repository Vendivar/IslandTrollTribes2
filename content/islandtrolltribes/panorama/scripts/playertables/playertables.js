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
  $.Msg(PT);
  var tableName = PT.listeners[callbackID];
  if (tableName){
    if (PT.tableListeners[tableName]){
      var listener = PT.tableListeners[tableName][callbackID];
      if (listener){
        delete PT.tableListeners[tableName][callbackID];
      }
    }
 
    delete PT.listeners[callbackID];
  }
  
  return;
}; 