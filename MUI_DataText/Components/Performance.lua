local _, namespace = ...;

-- luacheck: ignore MayronUI self 143 631
local _, db, em = MayronUI:GetCoreComponents();
local ComponentsPackage = namespace.ComponentsPackage;

local C_Timer = _G.C_Timer;

-- Register and Import Modules -------

local Performance = ComponentsPackage:CreateClass("Performance", nil, "IDataTextComponent");

-- Load Database Defaults ------------

db:AddToDefaults("profile.datatext.performance", {
    showFps = true,
    showHomeLatency = true,
    showServerLatency = false
});

-- Performance Module --------------

MayronUI:Hook("DataTextModule", "OnInitialize", function(self)
    local sv = db.profile.datatext.performance;
    sv:SetParent(db.profile.datatext);

    local settings = sv:GetTrackedTable();
    self:RegisterComponentClass("performance", Performance, settings);
end);

function Performance:__Construct(data, settings, dataTextModule)
    data.settings = settings;
    self.TotalLabelsShown = 0;
    self.HasLeftMenu = false;
    self.HasRightMenu = false;
    self.Button = dataTextModule:CreateDataTextButton();
end

function Performance:SetEnabled(data, enabled)
    data.enabled = enabled;

    if (enabled) then
        data.handler = em:CreateEventHandler("FRIENDLIST_UPDATE", function()
            if (not self.Button) then return; end
            self:Update();
        end);

    elseif (data.handler) then
        data.handler:Destroy();
        data.handler = nil;
    end
end

function Performance:IsEnabled(data)
    return data.enabled;
end

function Performance:Update(data, refreshSettings)
    if (refreshSettings) then
        data.settings:Refresh();
    end

    if (data.executed) then
        return;
    end

    data.executed = true;

    local function loop()
        local _, _, latencyHome, latencyServer = _G.GetNetStats();

        local label = "";

        if (data.settings.showFps) then
            label = string.format("|cffffffff%u|r fps", _G.GetFramerate());
        end

        if (data.settings.showHomeLatency) then
		
			if latencyHome <= 100 then
				label = string.format("%s |cff32cd32%u|r ms", label, latencyHome);
			end
			
			if latencyHome >= 101 and latencyHome <= 250 then
				label = string.format("%s |cffffcc00%u|r ms", label, latencyHome);
			end
			
			if latencyHome >=251 then		
				label = string.format("%s |cffff0000%u|r ms", label, latencyHome);
			end
			
        end

        if (data.settings.showServerLatency) then
            
			if latencyServer <= 100 then
				label = string.format("%s |cff32cd32%u|r ms", label, latencyServer);
			end
			
			if latencyServer >= 101 and latencyServer <= 250 then
				label = string.format("%s |cffffcc00%u|r ms", label, latencyServer);
			end
			
			if latencyServer >= 251 then	
				label = string.format("%s |cffff0000%u|r ms", label, latencyServer);
			end
			
        end

        self.Button:SetText(label:trim());

        C_Timer.After(3, loop);
    end

    loop();
end

function Performance:Click() end