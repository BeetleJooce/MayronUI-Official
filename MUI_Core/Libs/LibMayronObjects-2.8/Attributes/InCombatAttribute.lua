-- luacheck: ignore self 143 631
local Lib = _G.LibStub:GetLibrary("LibMayronObjects"); ---@type LibMayronObjects
local Attributes = Lib:CreatePackage("Attributes", "Framework.System");
local InCombatLockdown = _G.InCombatLockdown;

Attributes:CreateInterface("IAttribute", {
    -- functions:
    OnExecute = {type = "function"; params = {"Object", "table", "string"}};
    __Construct = {type = "function", params = {"?boolean"}}
});

---@class InCombatAttribute : Object
local InCombatAttribute = Attributes:CreateClass("InCombatAttribute", nil, "IAttribute");

function InCombatAttribute:__Construct(data, silent)
    data.silent = silent;
end

---@param instance Object
function InCombatAttribute:OnExecute(data, instance, _, funcName)
    if (InCombatLockdown()) then
        Lib:Assert(data.silent, "Failed to execute %s.%s: Cannot execute while in combat.", instance:GetObjectType(), funcName);
    end
end