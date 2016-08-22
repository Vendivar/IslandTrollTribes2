function SwapSpellBook(keys)
    local caster = keys.caster
    caster.activeBook = keys.ActiveBook
    local subclass = caster:GetSubClass()

    if(caster.activeBook == nil) then --Setting up the default spell book
        caster.activeBook = "book1"
    end

    print("Swapping the ability")
    print("Class: "..caster:GetClassname()..", Subclass: "..subclass..", Book: "..caster.activeBook)

    local spellBooks = GameRules.SpellBookInfo

    print(caster:GetClassname().." , "..caster.activeBook)
    HideAllAbilities(caster)
    local book = spellBooks[caster:GetClassname()][subclass][caster.activeBook]
    ShowTheSpellBook(caster, book)

    -- Reorder
    for i,ability_name in pairs(book) do
        local ability_in_slot = GetAbilityOnVisibleSlot(caster, tonumber(i))
        if ability_in_slot then
            local name = ability_in_slot:GetAbilityName()
            if name ~= ability_name then
                caster:SwapAbilities(name, ability_name, true, true)
            end
        end
    end
    PrintAbilities(caster)
end