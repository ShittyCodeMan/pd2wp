dofile(ModPath.. "lua/common.lua")

function WeaponPanel:create_panel()
	self.ws = managers.gui_data:create_fullscreen_workspace()
	self.ws_panel = self.ws:panel()
	self.visibled = 0
	local info_panel = self.ws_panel:panel({name = "info_panel", w = 75, alpha = 1, layer = 30})
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

function WeaponPanel:update_panel()
	if not self.ws_panel then
		self:create_panel()
	end
	local info_panel = self.ws_panel:child("info_panel")
	
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
	
	WeaponPanel:update_panel()
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

Hooks:PostHook( HUDManager, "set_ammo_amount", "WeaponPanel", function(self, selection_index, max_clip, current_clip, current_left, max)
	if not LuaModManager:IsModEnabled(mod_path) then return end
	local s, r = pcall(function()
	
	WeaponPanel:update_panel()
	
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
	
	local cam = managers.viewport:get_current_camera()
	if not cam then
		return
	end
	local equipped_unit = self._parent_unit:inventory():equipped_unit()
	local obj = equipped_unit:get_object(Idstring("fire")) or WeaponPanel.equipped_unit:get_object(Idstring("a_sight")) or self._unit:get_object(Idstring("a_weapon_right"))
	if not obj then
		return
	end
	local vec = obj:position()
	local rot = obj:rotation()
	local temp = Vector3()
	local offset = WeaponPanel.options.base.offset
	mvector3.set(temp, rot:x())
	mvector3.multiply(temp, offset.x)
	mvector3.add(vec, temp)
	mvector3.set(temp, rot:y())
	mvector3.multiply(temp, offset.y)
	mvector3.add(vec, temp)
	mvector3.set(temp, rot:z())
	mvector3.multiply(temp, offset.z)
	mvector3.add(vec, temp)
	local pos = WeaponPanel.ws:world_to_screen(cam, vec)
	local in_steelsight = managers.player:player_unit():movement():current_state()._state_data.in_steelsight
	local info_panel = WeaponPanel.ws_panel:child("info_panel")
	info_panel:set_x(pos.x - (offset.x < 0 and info_panel:w() or 0))
	info_panel:set_y(pos.y - (offset.z > 0 and info_panel:h() or 0))
	info_panel:set_alpha(WeaponPanel.visibled * (in_steelsight and 0.75 or 1))
	
	end)
	if s then return r else WeaponPanel:ErrorHandler() return end
end )

end
