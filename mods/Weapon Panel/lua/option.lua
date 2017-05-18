dofile(ModPath.. "lua/common.lua")
WeaponPanel.options_menu = "WeaponPanel_menu"

Hooks:Add("LocalizationManagerPostInit", "WeaponPanelLocatizations", function(loc)
	LocalizationManager:add_localized_strings({
		["WeaponPanel_options_title"] = "Weapon Panel",
		["WeaponPanel_options_desc"] = "Weapon Panel Options",
	})
end)

Hooks:Add("MenuManagerSetupCustomMenus", "WeaponPanelOptions", function(menu_manager, nodes)
	MenuHelper:NewMenu(WeaponPanel.options_menu)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "WeaponPanelOptions", function(menu_manager, nodes)

	MenuCallbackHandler.WeaponPanelOptions_weapon = function(self, item)
		local name = item:parameters().name
		local menu_id = name .. "_menu"
		local _, _, id = name:find("^WeaponPanelOptions_weapon_(.+)$")
		if id then
			MenuHelper:NewMenu(menu_id)
			menu.logic._data._nodes[menu_id] = MenuHelper:BuildMenu(menu_id, {area_bg = "half"})

		end
	end
	MenuCallbackHandler.WeaponPanelOptions_realammo = function(self, item)
		local name = item:parameters().name
		local menu_id = name .. "_menu"
		local _, _, id = name:find("^WeaponPanelOptions_(.+)_realammo$")
		if id then
			WeaponPanel.options.data[id].realammo = (item:value() == "on" and true or false)
			WeaponPanel:save_options()

			if WeaponPanel.ws_panel then
				WeaponPanel:update_panel_info()
			end
		end
	end
	MenuCallbackHandler.WeaponPanelOptions_rotate = function(self, item)
		local name = item:parameters().name
		local menu_id = name .. "_menu"
		local _, _, id = name:find("^WeaponPanelOptions_(.+)_rotate$")
		if id then
			WeaponPanel.options.data[id].rotation = (item:value() == "on" and true or false)
			WeaponPanel:save_options()

			if WeaponPanel.ws_panel then
				WeaponPanel:update(managers.player:player_unit():camera():camera_unit():base())
			end
		end
	end
	MenuCallbackHandler.WeaponPanelOptions_alpha = function(self, item)
		local alpha = item:value()
		local name = item:parameters().name
		local _, _, id = name:find("^WeaponPanelOptions_(.+)_alpha$")
		if id then
			WeaponPanel.options.data[id].alpha = alpha
			WeaponPanel:save_options()

			if WeaponPanel.ws_panel then
				local info_panel = WeaponPanel.ws_panel:child("info_panel")
				info_panel:child("clip_text_bg"):set_alpha(alpha)
				info_panel:child("clip_text_bg2"):set_alpha(alpha)
				info_panel:child("ammo_text_bg"):set_alpha(alpha)
				info_panel:child("ammo_text_bg2"):set_alpha(alpha)
			end
		end
	end
	MenuCallbackHandler.WeaponPanelOptions_offset = function(self, item)
		local val = item:value()
		local name = item:parameters().name
		local _, _, id, axis = name:find("^WeaponPanelOptions_(.+)_offset_(.)$")
		if id and axis then
			WeaponPanel.options.data[id].offset[axis] = val
			WeaponPanel:save_options()

			if WeaponPanel.ws_panel and managers.player:local_player() then
				WeaponPanel:update(managers.player:local_player():camera():camera_unit():base())
			end
		end
	end

	MenuHelper:AddToggle({
		id = "WeaponPanelOptions_base_realammo",
		title = "Real ammo",
		desc = "Real ammo. Default: " .. tostring(WeaponPanel.options.default.base.realammo),
		callback = "WeaponPanelOptions_realammo",
		menu_id = WeaponPanel.options_menu,
		value = WeaponPanel.options.data.base.realammo,
		localized = false,
		priority = 11,
	})

	MenuHelper:AddToggle({
		id = "WeaponPanelOptions_base_rotate",
		title = "Rotate",
		desc = "Rotate panel along with weapon's roll. Default: " .. tostring(WeaponPanel.options.default.base.rotation),
		callback = "WeaponPanelOptions_rotate",
		menu_id = WeaponPanel.options_menu,
		value = WeaponPanel.options.data.base.rotation,
		localized = false,
		priority = 11,
	})

	MenuHelper:AddSlider({
		id = "WeaponPanelOptions_base_alpha",
		title = "Panel opacity",
		desc = "Panel opacity(%). Default: " .. tostring(WeaponPanel.options.default.base.alpha * 100),
		callback = "WeaponPanelOptions_alpha",
		menu_id = WeaponPanel.options_menu,
		value = WeaponPanel.options.data.base.alpha,
		show_value = false,
		min = 0,
		max = 1,
		step = 0.05,
		localized = false,
		priority = 10,
	})

	for _, v in ipairs({
		[1] = {
			axis = "x",
			title = "Horizontal offset",
			priority = 9,
		},
		[2] = {
			axis = "y",
			title = "Depth offset",
			priority = 8,
		},
		[3] = {
			axis = "z",
			title = "Vertical offset",
			priority = 7,
		},
	}) do
		MenuHelper:AddSlider({
			id = "WeaponPanelOptions_base_offset_" .. v.axis,
			title = v.title,
			desc = v.title .. "(cm). Default: " .. tostring(WeaponPanel.options.default.base.offset[v.axis]),
			callback = "WeaponPanelOptions_offset",
			menu_id = WeaponPanel.options_menu,
			value = WeaponPanel.options.data.base.offset[v.axis],
			show_value = true,
			min = -30,
			max = 30,
			step = 1,
			localized = false,
			priority = v.priority,
		})
	end

	--[[
	local function AddWeaponOption(id)
		MenuHelper:AddButton({
			id = "WeaponPanelOptions_weapon_" .. id,
			title = id,
			desc = id,
			callback = "WeaponPanelOptions_weapon",
		})
		MenuHelper:AddSlider({
			id = "WeaponPanelOptions_" .. id .. "_alpha",
			title = "Panel opacity",
			desc = "Panel opacity(%). Default: " .. tostring(WeaponPanel.options.default[id].alpha * 100),
			callback = "WeaponPanelOptions_alpha",
			menu_id = WeaponPanel.options_menu,
			value = WeaponPanel.options.data[id].alpha,
			show_value = false,
			min = 0,
			max = 1,
			step = 0.05,
			localized = false,
			priority = 10,
		})

		for _, v in ipairs({
			[1] = {
				axis = "x",
				title = "Horizontal offset",
				priority = 9,
			},
			[2] = {
				axis = "y",
				title = "Depth offset",
				priority = 8,
			},
			[3] = {
				axis = "z",
				title = "Vertical offset",
				priority = 7,
			},
		}) do
			MenuHelper:AddSlider({
				id = "WeaponPanelOptions_" .. id .. "_offset_" .. v.axis,
				title = v.title,
				desc = v.title .. "(cm). Default: " .. tostring(WeaponPanel.options.default[id].offset[v.axis]),
				callback = "WeaponPanelOptions_offset",
				menu_id = WeaponPanel.options_menu,
				value = WeaponPanel.options.data[id].offset[v.axis],
				show_value = true,
				min = -30,
				max = 30,
				step = 1,
				localized = false,
				priority = v.priority,
			})
		end
	end
	AddWeaponOption("base")
	]]
end)

Hooks:Add("MenuManagerBuildCustomMenus", "WeaponPanelOptions", function(menu_manager, nodes)
	nodes[WeaponPanel.options_menu] = MenuHelper:BuildMenu(WeaponPanel.options_menu, {area_bg = "none"})
	MenuHelper:AddMenuItem(MenuHelper.menus.lua_mod_options_menu, WeaponPanel.options_menu, "WeaponPanel_options_title", "WeaponPanel_options_desc")
end)
