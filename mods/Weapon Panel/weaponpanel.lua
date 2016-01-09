local offset_x = 50
local offset_y = 0



local mod_path = mod_path or ModPath

_G.weapon_panel = _G.weapon_panel or {}

weapon_panel.ErrorHandler = function()
	if LuaModManager:IsModEnabled(mod_path) then
		log("Disabling " .. mod_path)
		LuaModManager:DisableMod(mod_path)
		
		log("Unloading " .. mod_path)
		Hooks:RemovePostHook("weapon_panel_show_endscreen_hud")
		Hooks:RemovePostHook("weapon_panel__set_weapon_selected")
		Hooks:RemovePostHook("weapon_panel_set_ammo_amount")
		Hooks:RemovePostHook("weapon_panel_hide_weapon")
		Hooks:RemovePostHook("weapon_panel_show_weapon")
		Hooks:RemovePostHook("weapon_panel_update")
		
		if weapon_panel.ws_panel and weapon_panel.ws_panel:child("info_panel") then
			weapon_panel.ws_panel:child("info_panel"):hide()
		end
		
		QuickMenu:new("Mod Error", "Error occured on \"" .. mod_path .. "\".\nThis mod is unloaded and disabled automatically.\nSee BLT log for more details.", {}, true)
	end
end

weapon_panel.create_panel = function()
	weapon_panel.ws = managers.gui_data:create_fullscreen_workspace()
	weapon_panel.ws_panel = weapon_panel.ws:panel()
	weapon_panel.info_panel_visibled = 0
	local info_panel = weapon_panel.ws_panel:panel({name = "info_panel", w = 75, alpha = 1, layer = 30})
	local prev_text = {left = function(self) return 0 end, bottom = function(self) return 0 end}
	local function new_text(name)
		local text = info_panel:text({
			name = name .. "_text",
			text = "DUMMY",
			font = tweak_data.menu.small_font,
			font_size = 16,
			align = "right",
			color = Color(1, 1, 1),
			x = prev_text:left(),
			y = prev_text:bottom(),
			alpha = 1,
			layer = 10,
			blend_mode = 'add'
		})
		managers.hud:make_fine_text(text)
		text:set_width(info_panel:w())
		info_panel:rect({
			name = name .. "_text_bg",
			blend_mode = "normal",
			color = Color(0, 0, 1),
			alpha = 0.25,
			layer = 9,
		}):set_shape(text:shape())
		prev_text = text
		return text
	end
	local function new_progtext(name)
		new_text(name)
		info_panel:rect({
			name = name .. "_text_bg2",
			blend_mode = "normal",
			color = Color(1, 0, 0),
			alpha = 0.25,
			layer = 9,
		}):set_shape(prev_text:shape())
	end
	new_progtext("clip")
	new_progtext("ammo")
	info_panel:set_h(prev_text:bottom())
end

weapon_panel.update_panel = function()
	if not weapon_panel.ws_panel then
		weapon_panel.create_panel()
	end
	local info_panel = weapon_panel.ws_panel:child("info_panel")
	
	local clip_text = info_panel:child("clip_text")
	local clip_text_bg = info_panel:child("clip_text_bg")
	local clip_text_bg2 = info_panel:child("clip_text_bg2")
	local ammo_text = info_panel:child("ammo_text")
	local ammo_text_bg = info_panel:child("ammo_text_bg")
	local ammo_text_bg2 = info_panel:child("ammo_text_bg2")
	local weapon = managers.player:player_unit():inventory():equipped_unit()
	if not weapon then
		return
	end
	local base = weapon:base()
	local max_clip, cur_clip, cur_ammo, max_ammo =  base:get_ammo_max_per_clip(), base:get_ammo_remaining_in_clip(), base:get_ammo_total(), base:get_ammo_max()
	clip_text:set_text(string.format("%03d / %03d", cur_clip, max_clip))
	ammo_text:set_text(string.format("%03d / %03d", cur_ammo, max_ammo))
	local percent = cur_clip / max_clip
	clip_text_bg:set_w(info_panel:w() * percent) clip_text_bg2:set_x(info_panel:w() * percent)
	local percent = cur_ammo / max_ammo
	ammo_text_bg:set_w(info_panel:w() * percent) ammo_text_bg2:set_x(info_panel:w() * percent)
end

if RequiredScript == "lib/managers/hudmanagerpd2" then

Hooks:PostHook( HUDManager, "show_endscreen_hud", "weapon_panel_show_endscreen_hud", function(self)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	if weapon_panel then
		weapon_panel.info_panel_visibled = 0
	end
	
	end)
	if s then return r else weapon_panel.ErrorHandler() return end
end )

Hooks:PostHook( HUDManager, "_set_weapon_selected", "weapon_panel__set_weapon_selected", function(self, id)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	weapon_panel.update_panel()
	
	end)
	if s then return r else weapon_panel.ErrorHandler() return end
end )

Hooks:PostHook( HUDManager, "set_ammo_amount", "weapon_panel_set_ammo_amount", function(self, selection_index, max_clip, current_clip, current_left, max)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	weapon_panel.update_panel()
	
	end)
	if s then return r else weapon_panel.ErrorHandler() return end
end )

elseif RequiredScript == "lib/units/cameras/fpcameraplayerbase" then

Hooks:PostHook( FPCameraPlayerBase, "hide_weapon", "weapon_panel_hide_weapon", function(self)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	weapon_panel.info_panel_visibled = 0
	
	end)
	if s then return r else weapon_panel.ErrorHandler() return end
end )

Hooks:PostHook( FPCameraPlayerBase, "show_weapon", "weapon_panel_show_weapon", function(self)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	weapon_panel.info_panel_visibled = 1
	
	end)
	if s then return r else weapon_panel.ErrorHandler() return end
end )

Hooks:PostHook( FPCameraPlayerBase, "update", "weapon_panel_update", function(self, unit, t, dt)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	local cam = managers.viewport:get_current_camera()
	if not cam then
		return
	end
	local equipped_unit = self._parent_unit:inventory():equipped_unit()
	local obj = equipped_unit:get_object(Idstring("fire")) or weapon_panel.equipped_unit:get_object(Idstring("a_sight")) or self._unit:get_object(Idstring("a_weapon_right"))
	if not obj then
		return
	end
	local vec = obj:position()
	local pos = weapon_panel.ws:world_to_screen(cam, vec)
	local in_steelsight = managers.player:player_unit():movement():current_state()._state_data.in_steelsight
	local camera = self._parent_unit:camera()
	local info_panel = weapon_panel.ws_panel:child("info_panel")
	info_panel:set_x(pos.x + offset_x)
	info_panel:set_y(pos.y + offset_y)
	info_panel:set_alpha(in_steelsight and weapon_panel.info_panel_visibled * 0.75 or weapon_panel.info_panel_visibled)
	
	end)
	if s then return r else weapon_panel.ErrorHandler() return end
end )

end
