function SwapSpellBook(keys)
    local caster = keys.caster

    if(caster.activeBook == nil) then --Setting up the default spell book
        caster.activeBook = "book1"
    end

    if(caster.subclass==nil) then
        caster.subclass="none"
    end
    print("Swapping the ability")
    print("Class: "..caster:GetClassname()..", Subclass: "..caster.subclass..", Book: "..caster.activeBook)

    local spellBooks = {}
    spellBooks[MAGE] = {none={},elementalist={},hypnotist={},dementia_master={}}
    spellBooks[PRIEST] = {none={}, booster={}, master_healer={}, shaman={}}

    spellBooks[MAGE]["none"]["book1"] = {
        "ability_mage_spellbook_toggle",
        "ability_mage_nulldamage",
        "ability_mage_pumpup",
        "ability_mage_magefire",
        "ability_mage_reducefood"
    }

    spellBooks[MAGE]["none"]["book2"] = {
        "ability_mage_spellbook_toggle",
        "ability_mage_negativeblast",
        "ability_mage_flamespray",
        "ability_mage_depress",
        "ability_mage_metronome"
    }

    spellBooks[MAGE]["elementalist"]["book1"] = {
        "ability_mage_spellbook_toggle",
    }

    spellBooks[MAGE]["elementalist"]["book2"] = {
        "ability_mage_spellbook_toggle",
    }

    spellBooks[MAGE]["hypnotist"]["book1"] = {
        "ability_mage_spellbook_toggle",
    }

    spellBooks[MAGE]["hypnotist"]["book2"] = {
        "ability_mage_spellbook_toggle",
    }

    spellBooks[MAGE]["dementia_master"]["book1"] = {
        "ability_mage_spellbook_toggle",
    }

    spellBooks[MAGE]["dementia_master"]["book2"] = {
        "ability_mage_spellbook_toggle",
    }

    spellBooks[PRIEST]["none"]["book1"] = {
        "ability_priest_toggle_spellbar",
        "ability_priest_theglow",
        "ability_priest_cureall",
        "ability_priest_resistall",
        "ability_priest_pumpup",
        "ability_priest_sprayhealing",
    }

    spellBooks[PRIEST]["none"]["book2"] = {
        "ability_priest_toggle_spellbar",
        "ability_priest_pacifyingsmoke",
        "ability_priest_mixheat",
        "ability_priest_mixenergy",
        "ability_priest_mixhealth"
    }

    spellBooks[PRIEST]["booster"]["book1"] = {
        "ability_priest_toggle_spellbar",
    }

    spellBooks[PRIEST]["booster"]["book2"] = {
        "ability_priest_toggle_spellbar",
    }

    spellBooks[PRIEST]["master_healer"]["book1"] = {
        "ability_priest_toggle_spellbar",
    }

    spellBooks[PRIEST]["master_healer"]["book2"] = {
        "ability_priest_toggle_spellbar",
    }

    spellBooks[PRIEST]["shaman"]["book1"] = {
        "ability_priest_toggle_spellbar",
    }

    spellBooks[PRIEST]["shaman"]["book2"] = {
        "ability_priest_toggle_spellbar",
    }

    print(caster:GetClassname().." , "..caster.activeBook)
    HideTheSpellBook(caster, spellBooks[caster:GetClassname()][caster.subclass][caster.activeBook])
    SwapTheSpellBook(caster)
    ShowTheSpellBook(caster, spellBooks[caster:GetClassname()][caster.subclass][caster.activeBook])
end

function SwapTheSpellBook(caster)
    if(caster.activeBook == "book1") then -- swapping the books
        caster.activeBook = "book2"
    else
        caster.activeBook = "book1"
    end
    return caster
end

function HideTheSpellBook(caster, spellbook)
    for _,spell in pairs(spellbook) do
        SetAbilityVisibility (caster, spell,false)
    end
end

function ShowTheSpellBook(caster, spellbook)
    for _,spell in pairs(spellbook) do
        print(caster:FindAbilityByName(spell):GetAbilityName())
        SetAbilityVisibility (caster, spell,true)
    end
end