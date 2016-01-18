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

	MenuCallbackHandler.default_offset_x = function(self, item)
		WeaponPanel.options.base.offset.x = item:value()
		WeaponPanel:save_options()
	end
	MenuCallbackHandler.default_offset_y = function(self, item)
		WeaponPanel.options.base.offset.y = item:value()
		WeaponPanel:save_options()
	end
	MenuCallbackHandler.default_offset_z = function(self, item)
		WeaponPanel.options.base.offset.z = item:value()
		WeaponPanel:save_options()
	end
	
	MenuHelper:AddSlider({
		id = "WeaponPanelOptions_default_offset_x",
		title = "Horizontal offset",
		desc = "Horizontal offset(cm). Default: " .. WeaponPanel.default_options.base.offset.x,
		callback = "default_offset_x",
		menu_id = WeaponPanel.options_menu,
		value = WeaponPanel.options.base.offset.x,
		show_value = true,
		min = -30,
		max = 30,
		step = 1,
		localized = false,
	})
	MenuHelper:AddSlider({
		id = "WeaponPanelOptions_default_offset_y",
		title = "Depth offset",
		desc = "Depth offset(cm). Default: " .. WeaponPanel.default_options.base.offset.y,
		callback = "default_offset_y",
		menu_id = WeaponPanel.options_menu,
		value = WeaponPanel.options.base.offset.y,
		show_value = true,
		min = -30,
		max = 30,
		step = 1,
		localized = false,
	})
	MenuHelper:AddSlider({
		id = "WeaponPanelOptions_default_offset_z",
		title = "Vertical offset",
		desc = "Vertical offset(cm). Default: " .. WeaponPanel.default_options.base.offset.z,
		callback = "default_offset_z",
		disabled_color = Color.black,
		menu_id = WeaponPanel.options_menu,
		value = WeaponPanel.options.base.offset.z,
		show_value = true,
		min = -30,
		max = 30,
		step = 1,
		localized = false,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "WeaponPanelOptions", function(menu_manager, nodes)
	nodes[WeaponPanel.options_menu] = MenuHelper:BuildMenu(WeaponPanel.options_menu, {area_bg = "half"})
	MenuHelper:AddMenuItem(MenuHelper.menus.lua_mod_options_menu, WeaponPanel.options_menu, "WeaponPanel_options_title", "WeaponPanel_options_desc")
end)
