"use strict";

var m_Item = -1;
var m_ItemSlot = -1;
var m_contID = -1;
var m_contString = "";
var m_slot = -1;
var m_QueryUnit = -1;
var m_Container = null;
var started = false;

function UpdateItem()
{
	m_Item = -1;
	if (m_contString !== ""){
		m_Item = PlayerTables.GetTableValue(m_contString, "slot" + m_slot) || -1;
		m_QueryUnit = PlayerTables.GetTableValue(m_contString, "entity") || -1;
		var sel = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
		if (!Entities.IsInventoryEnabled(m_QueryUnit) || !Entities.IsControllableByAnyPlayer(m_QueryUnit) || 
			(Entities.GetTeamNumber(m_QueryUnit) != Entities.GetTeamNumber(sel))){
			m_QueryUnit = -1;
		}
	}

	if (m_Container === null || m_Container.deleted){
		return;
	}

	if (m_Container && !m_Container.visible){
		$.Schedule( 0.1, UpdateItem );
		return;
	}

	var itemName = Abilities.GetAbilityName( m_Item );
	if (itemName == ""){
		m_Item = -1;
	}
	var hotkey = Abilities.GetKeybind( m_Item, m_QueryUnit );
	var isPassive = Abilities.IsPassive( m_Item );
	var chargeCount = 0;
	var hasCharges = false;
	var altChargeCount = 0;
	var hasAltCharges = false;
	
	if ( Items.ShowSecondaryCharges( m_Item ) )
	{
		// Ward stacks display charges differently depending on their toggle state
		hasCharges = true;
		hasAltCharges = true;
		if ( Abilities.GetToggleState( m_Item ) )
		{
			chargeCount = Items.GetCurrentCharges( m_Item );
			altChargeCount = Items.GetSecondaryCharges( m_Item );
		}
		else
		{
			altChargeCount = Items.GetCurrentCharges( m_Item );
			chargeCount = Items.GetSecondaryCharges( m_Item );
		}
	}
	else if ( Items.ShouldDisplayCharges( m_Item ) )
	{
		hasCharges = true;
		chargeCount = Items.GetCurrentCharges( m_Item );
	}

	var isShop = m_Container && m_Container.IsShop();
	var stock = -1;
	var price = -1;
	if (isShop && m_Item !== -1){
		stock = PlayerTables.GetTableValue(m_contString, "stock" + m_Item);
		if (stock === null) 
			stock = -1;
		price = PlayerTables.GetTableValue(m_contString, "price" + m_Item) || Items.GetCost(m_Item);
	}

	var gold = Players.GetGold(Players.GetLocalPlayer());

	$.GetContextPanel().SetHasClass( "show_stock", stock >= 0 );
	$.GetContextPanel().SetHasClass( "out_of_stock", stock === 0 );
	$.GetContextPanel().SetHasClass( "show_price", price >= 0 );
	$.GetContextPanel().SetHasClass( "high_price", gold < price );

	$.GetContextPanel().SetHasClass( "no_item", (m_Item == -1) );
	$.GetContextPanel().SetHasClass( "show_charges", hasCharges );
	$.GetContextPanel().SetHasClass( "show_alt_charges", hasAltCharges );
	$.GetContextPanel().SetHasClass( "is_passive", isPassive );
	//$.GetContextPanel().SetHasClass( "no_mana_cost", (Abilities.GetManaCost( m_Item ) <= 0));
	//$.Msg(m_QueryUnit, " -- ", m_Item, " -- ", Abilities.GetManaCost( m_Item ), " -- ", Entities.GetMana(m_QueryUnit));
	$.GetContextPanel().SetHasClass( "low_mana", ((m_QueryUnit !== -1) && Abilities.GetManaCost( m_Item ) > Entities.GetMana(m_QueryUnit)));

	

	if (m_Container)
		$.GetContextPanel().SetHasClass( "is_active", (Abilities.GetLocalPlayerActiveAbility() == m_Item));
	
	$( "#HotkeyText" ).text = hotkey;
	$( "#ItemImage" ).itemname = itemName;
	$( "#ItemImage" ).contextEntityIndex = m_Item;
	$( "#ChargeCount" ).text = chargeCount;
	$( "#AltChargeCount" ).text = altChargeCount;

	$( "#Price" ).text = price;
	$( "#Stock" ).text = "x" + stock;

	var manaCost = Abilities.GetManaCost( m_Item );
	if (m_Container)
		$( "#ManaCost" ).text = Abilities.GetManaCost( m_Item );
	
	if ( m_QueryUnit == -1 || m_Item == -1 || Abilities.IsCooldownReady( m_Item ) )
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", true );
		$.GetContextPanel().SetHasClass( "in_cooldown", false );
	}
	else
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", false );
		$.GetContextPanel().SetHasClass( "in_cooldown", true ); 
		var cooldownLength = Abilities.GetCooldownLength( m_Item );
		var cooldownRemaining = Abilities.GetCooldownTimeRemaining( m_Item );
		var cooldownPercent = Math.ceil( 100 * cooldownRemaining / cooldownLength );
		$( "#CooldownTimer" ).text = Math.ceil( cooldownRemaining );
		$( "#CooldownOverlay" ).style.width = cooldownPercent+"%";
	}
	
	$.Schedule( 0.1, UpdateItem );
}

function ItemShowTooltip()
{
	if ( m_Item == -1 )
		return;

	var itemName = Abilities.GetAbilityName( m_Item );
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", $.GetContextPanel(), itemName, m_QueryUnit );
}

function ItemHideTooltip()
{
	$.DispatchEvent( "DOTAHideAbilityTooltip", $.GetContextPanel() );
}

var lastClick = 1; // 1 right, 0 left

function ActivateItem()
{
	lastClick = 0;
	if ( m_Item == -1 )
		return;

	var action = PlayerTables.GetTableValue(m_contString, "OnLeftClick");
	if (action !== 0){
		GameEvents.SendCustomGameEventToServer( "Containers_OnLeftClick", {unit:Players.GetLocalPlayerPortraitUnit(), contID:m_contID, itemID:m_Item, slot:m_slot} );
		return;
	}

	//Abilities.ExecuteAbility( m_Item, m_QueryUnit, false );
}

function DoubleClickItem()
{
	if (lastClick === 0)
		ActivateItem();
}

var DOTA_ITEM_STASH_MIN = 6;

function IsInStash()
{
	return ( m_ItemSlot >= DOTA_ITEM_STASH_MIN );
}

function RightClickItem()
{
	lastClick = 1;
	var action = PlayerTables.GetTableValue(m_contString, "OnRightClick");
	if (action === 1){
		GameEvents.SendCustomGameEventToServer( "Containers_OnRightClick", {unit:Players.GetLocalPlayerPortraitUnit(), contID:m_contID, itemID:m_Item, slot:m_slot} );
		return;
	}

	ItemHideTooltip();

	var bSlotInStash = IsInStash();
	var bControllable = Entities.IsControllableByPlayer( m_QueryUnit, Game.GetLocalPlayerID() );
	var bSellable = Items.IsSellable( m_Item ) && Items.CanBeSoldByLocalPlayer( m_Item );
	var bDisassemble = Items.IsDisassemblable( m_Item ) && bControllable && !bSlotInStash;
	var bAlertable = Items.IsAlertableItem( m_Item ); 
	var bShowInShop = Items.IsPurchasable( m_Item );
	var bDropFromStash = bSlotInStash && bControllable;

	if (m_Container || ( !bSellable && !bDisassemble && !bShowInShop && !bDropFromStash && !bAlertable && !bMoveToStash ))
	{
		// don't show a menu if there's nothing to do
		return;
	}

	var contextMenu = $.CreatePanel( "DOTAContextMenuScript", $.GetContextPanel(), "" );
	contextMenu.AddClass( "ContextMenu_NoArrow" );
	contextMenu.AddClass( "ContextMenu_NoBorder" );
	contextMenu.GetContentsPanel().Item = m_Item;
	contextMenu.GetContentsPanel().SetHasClass( "bSellable", bSellable );
	contextMenu.GetContentsPanel().SetHasClass( "bDisassemble", bDisassemble );
	contextMenu.GetContentsPanel().SetHasClass( "bShowInShop", bShowInShop );
	contextMenu.GetContentsPanel().SetHasClass( "bDropFromStash", bDropFromStash );
	contextMenu.GetContentsPanel().SetHasClass( "bAlertable", bAlertable );
	contextMenu.GetContentsPanel().SetHasClass( "bMoveToStash", false ); // TODO
	contextMenu.GetContentsPanel().BLoadLayout( "file://{resources}/layout/custom_game/inventory_context_menu.xml", false, false );
} 

function OnDragEnter( a, draggedPanel )
{
	var draggedItem = draggedPanel.m_DragItem; 

	// only care about dragged items other than us
	if ( draggedItem === null || draggedItem == m_Item )
		return true;

	// highlight this panel as a drop target
	$.GetContextPanel().AddClass( "potential_drop_target" );
	return true;
}

function OnDragDrop( panelId, draggedPanel )
{
	var draggedItem = draggedPanel.m_DragItem;
	
	// only care about dragged items other than us
	if ( draggedItem === null )
		return true;

	var dropTarget = $.GetContextPanel();
	$.GetContextPanel().RemoveClass( "potential_drop_target" );

	// executing a slot swap - don't drop on the world
	draggedPanel.m_DragCompleted = true;
	
	// item dropped on itself? don't acutally do the swap (but consider the drag completed)
	if ( draggedItem == m_Item )
		return true;


	var action = PlayerTables.GetTableValue(m_contString, "OnDragTo");
	if (action !== 0){
		GameEvents.SendCustomGameEventToServer( "Containers_OnDragFrom", {unit:Players.GetLocalPlayerPortraitUnit(), contID:draggedPanel.m_contID, itemID:draggedItem, 
			fromSlot:draggedPanel.m_OriginalPanel.GetSlot(), toContID:m_contID, toSlot:m_slot} );
	}


	/*if (m_Container || container)
	{
		if (m_Container && container)
		{
			draggedPanel.m_OriginalPanel.SetItem(m_QueryUnit, m_Item, container);
			SetItem(draggedPanel.m_QueryUnit, draggedItem, m_Container);
		}
	}
	else
	{
		// create the order
		var moveItemOrder =
		{
			OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_ITEM,
			TargetIndex: m_ItemSlot,
			AbilityIndex: draggedItem
		};
		Game.PrepareUnitOrders( moveItemOrder );
	}*/
	return true;
}

function OnDragLeave( panelId, draggedPanel )
{
	var draggedItem = draggedPanel.m_DragItem;
	if ( draggedItem === null || draggedItem == m_Item )
		return false;

	// un-highlight this panel
	$.GetContextPanel().RemoveClass( "potential_drop_target" );
	return true;
}

function OnDragStart( panelId, dragCallbacks )
{
	if ( m_Item == -1 )
	{
		return true;
	}

	var action = PlayerTables.GetTableValue(m_contString, "OnDragDrop");
	var action2 = PlayerTables.GetTableValue(m_contString, "OnDragWorld");
	if (action === 0 && action2 === 0){
		return true;
	}

	var itemName = Abilities.GetAbilityName( m_Item );

	ItemHideTooltip(); // tooltip gets in the way

	// create a temp panel that will be dragged around
	var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "dragImage" );
	displayPanel.itemname = itemName;
	displayPanel.contextEntityIndex = m_Item;
	displayPanel.m_DragItem = m_Item;
	displayPanel.m_contID = m_contID;
	displayPanel.m_DragCompleted = false; // whether the drag was successful
	displayPanel.m_OriginalPanel = $.GetContextPanel();
	displayPanel.m_QueryUnit = m_QueryUnit;

	// hook up the display panel, and specify the panel offset from the cursor
	dragCallbacks.displayPanel = displayPanel;
	dragCallbacks.offsetX = 0;
	dragCallbacks.offsetY = 0;
	
	// grey out the source panel while dragging
	$.GetContextPanel().AddClass( "dragging_from" );
	return true;
}

function OnDragEnd( panelId, draggedPanel )
{

	var action = PlayerTables.GetTableValue(m_contString, "OnDragWorld");

	if (!draggedPanel.m_DragCompleted && action === 1){
		var position = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
		var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() );
		var entity = null;

		if (mouseEntities.length !== 0){
			for ( var e of mouseEntities )
			{
				if ( e.accurateCollision ){
					entity = e.entityIndex;
					break;
				}
			}
		}
		GameEvents.SendCustomGameEventToServer( "Containers_OnDragWorld", {unit:Players.GetLocalPlayerPortraitUnit(), contID:m_contID, itemID:m_Item, slot:m_slot, position:position, entity:entity} );
	}

	// if the drag didn't already complete, then try dropping in the world
		//Game.DropItemAtCursor( m_QueryUnit, m_Item );

	// kill the display panel
	draggedPanel.DeleteAsync( 0 );

	// restore our look
	$.GetContextPanel().RemoveClass( "dragging_from" );
	return true;
}

function SetItemSlot( itemSlot )
{
	m_ItemSlot = itemSlot;
}

function SetItem( queryUnit, contID, slot, container )
{
	m_contID = contID;
	m_contString = "cont_" + contID;
	m_slot = slot;
	//m_Item = iItem;
	//m_QueryUnit = queryUnit;
	m_Container = container;

	if (!started){
		UpdateItem(); // initial update of dynamic state
	}
	started = true;
}


function GetSlot()
{
	return m_slot;
}

(function()
{
	$.GetContextPanel().SetItem = SetItem;
	$.GetContextPanel().SetItemSlot = SetItemSlot;
	$.GetContextPanel().GetSlot = GetSlot;

	// Drag and drop handlers ( also requires 'draggable="true"' in your XML, or calling panel.SetDraggable(true) )
	$.RegisterEventHandler( 'DragEnter', $.GetContextPanel(), OnDragEnter );
	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
	$.RegisterEventHandler( 'DragLeave', $.GetContextPanel(), OnDragLeave );
	$.RegisterEventHandler( 'DragStart', $.GetContextPanel(), OnDragStart );
	$.RegisterEventHandler( 'DragEnd', $.GetContextPanel(), OnDragEnd );
})();
