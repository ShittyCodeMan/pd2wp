dofile(ModPath.. "lua/common.lua")

if RequiredScript == "lib/managers/hudmanagerpd2" then

Hooks:PostHook( HUDManager, "show_endscreen_hud", "WeaponPanel", function(self)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	WeaponPanel.visibled = 0
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

Hooks:PostHook( HUDManager, "_set_weapon_selected", "WeaponPanel", function(self, id)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	WeaponPanel:update_panel_info()
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

Hooks:PostHook( HUDManager, "set_ammo_amount", "WeaponPanel", function(self, selection_index, max_clip, current_clip, current_left, max)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	WeaponPanel:update_panel_info()
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

elseif RequiredScript == "lib/units/cameras/fpcameraplayerbase" then

Hooks:PostHook( FPCameraPlayerBase, "hide_weapon", "WeaponPanel", function(self)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	WeaponPanel.visibled = 0
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

Hooks:PostHook( FPCameraPlayerBase, "show_weapon", "WeaponPanel", function(self)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	WeaponPanel.visibled = 1
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

Hooks:PostHook( FPCameraPlayerBase, "update", "WeaponPanel", function(self, unit, t, dt)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	WeaponPanel:update(self)
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

end
