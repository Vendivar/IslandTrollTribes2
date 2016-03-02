function SwapSpellBook(keys)
    local caster = keys.caster
    caster.activeBook = keys.ActiveBook
    local subclass = GetSubClass(caster)

    if(caster.activeBook == nil) then --Setting up the default spell book
        caster.activeBook = "book1"
    end

    print("Swapping the ability")
    print("Class: "..caster:GetClassname()..", Subclass: "..subclass..", Book: "..caster.activeBook)

    local spellBooks = GameRules.SpellBookInfo

    print(caster:GetClassname().." , "..caster.activeBook)
    HideAllAbilities(caster)
    ShowTheSpellBook(caster, spellBooks[caster:GetClassname()][subclass][caster.activeBook])
end