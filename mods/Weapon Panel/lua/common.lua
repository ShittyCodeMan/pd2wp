--[[
ModPath = "mods/weapon panel/"
SavePath = "mods/save/"
LogsPath = "mods/logs/"
]]

_G.WeaponPanel = _G.WeaponPanel or (function()
	local obj = {
		mod_dir = ModPath,
		save_path = SavePath .. "weapon_panel.txt",
		options = {
			default = {
				base = {
					realammo = false,
					alpha = 0.5,
					offset = {
						x = -3,
						y = 0,
						z = 0
					}
				}
			}
		}
	}

	function obj:ErrorHandler()
		if LuaModManager:IsModEnabled(self.mod_dir) then
			log("Disabling " .. self.mod_dir)
			LuaModManager:DisableMod(self.mod_dir)
			
			log("Unloading " .. self.mod_dir)
			Hooks:RemovePostHook("WeaponPanel")
			
			if self.ws_panel and self.ws_panel:child("info_panel") then
				self.ws_panel:child("info_panel"):hide()
			end
			
			QuickMenu:new(
				"Mod Error", "Error occured on \"" .. self.mod_dir .. "\".\nThis mod is unloaded and disabled automatically.\nSee BLT log for more details.",
				{
					[1] = {
						text = "Open logs folder",
						callback = function()
							os.execute(string.gsub("start " .. LogsPath, "\/", "\\"))
						end,
					},
					[2] = {
						text = "OK",
						is_cancel_button = true,
					}
				},
				true)
		end
	end
	
	function obj:create_panel()
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
				alpha = self.options.data.base.alpha,
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
				alpha = self.options.data.base.alpha,
				layer = 9,
			}):set_shape(prev_text:shape())
		end
		new_progtext("clip")
		new_progtext("ammo")
		info_panel:set_h(prev_text:bottom())
	end

	function obj:update_panel_info()
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
		local max_clip, cur_clip, cur_ammo, max_ammo = base:get_ammo_max_per_clip(), base:get_ammo_remaining_in_clip(), base:get_ammo_total(), base:get_ammo_max()
		if self.options.data.base.realammo then
			cur_ammo = math.max(0, cur_ammo - cur_clip)
			max_ammo = math.max(0, max_ammo - max_clip)
		end
		clip_text:set_text(string.format("%03d / %03d", cur_clip, max_clip))
		ammo_text:set_text(string.format("%03d / %03d", cur_ammo, max_ammo))
		local percent = cur_clip / max_clip
		clip_text_bg:set_w(info_panel:w() * percent) clip_text_bg2:set_x(info_panel:w() * percent)
		local percent = cur_ammo / max_ammo
		ammo_text_bg:set_w(info_panel:w() * percent) ammo_text_bg2:set_x(info_panel:w() * percent)
	end
	
	function obj:update(fpcp_base)
		local cam = managers.viewport:get_current_camera()
		if not cam then
			return
		end
		local equipped_unit = fpcp_base._parent_unit:inventory():equipped_unit()
		local obj = equipped_unit:get_object(Idstring("fire")) or equipped_unit:get_object(Idstring("a_sight")) or fpcp_base._unit:get_object(Idstring("a_weapon_right"))
		if not obj then
			return
		end
		local vec = obj:position()
		local rot = obj:rotation()
		local temp = Vector3()
		local offset = self.options.data.base.offset
		mvector3.set(temp, rot:x())
		mvector3.multiply(temp, offset.x)
		mvector3.add(vec, temp)
		mvector3.set(temp, rot:y())
		mvector3.multiply(temp, offset.y)
		mvector3.add(vec, temp)
		mvector3.set(temp, rot:z())
		mvector3.multiply(temp, offset.z)
		mvector3.add(vec, temp)
		mvector3.direction(temp, cam:position(), vec)
		local in_fov = mvector3.angle(cam:rotation():y(), temp) < 90 and 1 or 0
		local pos = self.ws:world_to_screen(cam, vec)
		local in_steelsight = managers.player:player_unit():movement():current_state()._state_data.in_steelsight
		local info_panel = self.ws_panel:child("info_panel")
		info_panel:set_x(pos.x - (offset.x < 0 and info_panel:w() or 0))
		info_panel:set_y(pos.y - (offset.z > 0 and info_panel:h() or 0))
		info_panel:set_alpha(self.visibled * in_fov * (in_steelsight and 0.75 or 1))
	end
	
	function obj:save_options()
		local file = io.open( self.save_path, "w" )
		if file then
			file:write( json.encode( self.options.data ) )
			file:close()
		end
	end
	function obj:load_options()
		local file = io.open( self.save_path, "r" )

		if file then
			self.options.data = json.decode( file:read("*a") )
			file:close()
			self:complement_options()
		else
			self:reset_options()
		end
	end
	function obj:reset_options()
		self.options.data = {}
		self:complement_options()
	end
	function obj:complement_options()
		local function f(dst, src)
			if type(src) == "table" then
				dst = dst or {}
				for k, v in pairs(src) do
					dst[k] = f(dst[k], v)
				end
			else
				dst = dst or src
			end
			return dst
		end
		self.options.data = f(self.options.data, self.options.default)
	end
	obj:load_options()

	return obj
end)()
