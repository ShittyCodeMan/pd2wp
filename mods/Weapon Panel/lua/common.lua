--[[
ModPath = "mods/weapon panel/"
SavePath = "mods/save/"
LogsPath = "mods/logs/"
]]

_G.WeaponPanel = _G.WeaponPanel or (function()
	local obj = {
		mod_dir = ModPath,
		save_path = SavePath .. "weapon_panel.txt",
		default_options = {
			base = {
				offset = {
					x = -3,
					y = 0,
					z = 0
				}
			}
		}
	}

	function obj:ErrorHandler()
		if LuaModManager:IsModEnabled(self.mod_dir) then
			log("Disabling " .. self.mod_dir)
			--LuaModManager:DisableMod(self.mod_dir)
			
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

	function obj:save_options()
		local file = io.open( self.save_path, "w" )
		if file then
			file:write( json.encode( self.options ) )
			file:close()
		end
	end
	function obj:load_options()
		local file = io.open( self.save_path, "r" )

		if file then
			self.options = json.decode( file:read("*a") )
			file:close()
		else
			self:reset_options()
		end
		self:complement_options()
	end
	function obj:reset_options()
		self.options = self.default_options
	end
	function obj:complement_options()
		local function f(dst, src)
			if type(src) == "table" then
				dst = dst or {}
				for k, v in next, src, nil do
					dst[k] = f(dst[k], v)
				end
			else
				dst = dst or src
			end
			return dst
		end
		self.options = f(self.options, self.default_options)
	end
	obj:load_options()

	return obj
end)()
