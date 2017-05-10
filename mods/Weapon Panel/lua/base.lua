dofile(ModPath.. "lua/common.lua")

if RequiredScript == "lib/managers/hudmanagerpd2" then

Hooks:PostHook( HUDManager, "show_endscreen_hud", "WeaponPanel", function(self)
	return WeaponPanel:safecall(function()
		if not WeaponPanel.ws_panel then
			WeaponPanel:create_panel()
		end
		WeaponPanel.ws_panel:child("info_panel"):hide()
	end)
end )

Hooks:PostHook( HUDManager, "_set_weapon_selected", "WeaponPanel", function(self, id)
	return WeaponPanel:safecall(function()
		if not WeaponPanel.ws_panel then
			WeaponPanel:create_panel()
		end
		WeaponPanel:update_panel_info(id)
	end)
end )

Hooks:PostHook( HUDManager, "set_ammo_amount", "WeaponPanel", function(self, selection_index, max_clip, current_clip, current_left, max)
	return WeaponPanel:safecall(function()
		if not WeaponPanel.ws_panel then
			WeaponPanel:create_panel()
		end
		WeaponPanel:set_ammo_amount(selection_index, max_clip, current_clip, current_left, max)
		WeaponPanel:update_panel_info((managers.player:player_unit():inventory():equipped_selection() == 1) and 1 or selection_index)
	end)
end )

elseif RequiredScript == "lib/units/cameras/fpcameraplayerbase" then

Hooks:PostHook( FPCameraPlayerBase, "hide_weapon", "WeaponPanel", function(self)
	return WeaponPanel:safecall(function()
		if not WeaponPanel.ws_panel then
			WeaponPanel:create_panel()
		end
		if WeaponPanel.ws_panel then
			WeaponPanel.ws_panel:child("info_panel"):hide()
		end
	end)
end )

Hooks:PostHook( FPCameraPlayerBase, "show_weapon", "WeaponPanel", function(self)
	return WeaponPanel:safecall(function()
		if not WeaponPanel.ws_panel then
			WeaponPanel:create_panel()
		end
		WeaponPanel.ws_panel:child("info_panel"):show()
	end)
end )

Hooks:PostHook( FPCameraPlayerBase, "update", "WeaponPanel", function(self, unit, t, dt)
	return WeaponPanel:safecall(function()
		if not WeaponPanel.ws_panel then
			WeaponPanel:create_panel()
		end
		WeaponPanel:update(self)
	end)
end )

end
