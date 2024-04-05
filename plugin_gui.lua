-- Placeholder for storing the reference to the custom dialog
local custom_dialog = nil
local custom_dialog_content = nil

local function show_plugin_list_dialog()
    local vb = renoise.ViewBuilder()

    -- Fetch effect plugins and synthesizer plugins
    local devices = renoise.song().tracks[renoise.song().selected_track_index].available_devices
    local plugins = renoise.song().selected_instrument.plugin_properties.available_plugins

    -- Separate storage for synthesizer plugins
    local synth_plugins = {
        AU = {},
        VST = {}
    }

    -- Categorizing plugins and devices
    local categorized_plugins = {
        VST = {},
        AU = {},
        Native = {}
    }

    for _, plugin in ipairs(plugins) do
        if plugin:find("VST") then
            table.insert(synth_plugins.VST, "VST/" .. plugin:match("([^/]+)$"))
        elseif plugin:find("AU") then
            table.insert(synth_plugins.AU, "AU/" .. plugin:match("([^/]+)$"))
        end
    end

    for _, device in ipairs(devices) do
        local device_name = device:match("([^/]+)$")  -- Fetches the name after the last slash

        if device:find("VST") then
            table.insert(categorized_plugins.VST, "VST/" .. device_name)
        elseif device:find("AU") then
            table.insert(categorized_plugins.AU, "AU/" .. device_name)
        elseif device:find("Native") then
            table.insert(categorized_plugins.Native, "Native/" .. device_name)
        end
    end

    local selected_plugins = {}

    -- Function to create scrollable plugin list with checkboxes for each plugin type
    local function create_scrollable_plugin_list(title, plugins, identifier)
        local list = vb:vertical_aligner { mode = "top", spacing = 2 }

        for _, plugin_name in ipairs(plugins) do
            local checkbox = vb:checkbox { value = false }
            list:add_child(vb:row {
                checkbox,
                vb:text { text = plugin_name, align = "left" },
                notifier = function(value)
                    selected_plugins[identifier .. plugin_name] = value and plugin_name or nil
                end
            })
        end

        -- Adding a scrollbar requires managing the vertical_aligner through a custom method,
        -- as direct scrollbar components are not supported in this context.
        return vb:column {
            margin = 5,
            vb:text { text = title, font = "bold" },
            vb:row {
                style = "panel",
                height = 300,
                width = 220,
                list
            }
        }
    end

    -- Layout for dialog content
    local content = vb:row {
        margin = 10,
        spacing = 10,
        create_scrollable_plugin_list("VST Effects", categorized_plugins.VST, "VSTEffect/"),
        create_scrollable_plugin_list("AudioUnit Effects", categorized_plugins.AU, "AUEffect/"),
        create_scrollable_plugin_list("Native", categorized_plugins.Native, "Native/"),
        create_scrollable_plugin_list("VST Plugins", synth_plugins.VST, "VSTPlugin/"),
        create_scrollable_plugin_list("AudioUnit Plugins", synth_plugins.AU, "AUPlugin/")
    }

    -- Buttons for generating shortcuts and cancelling
    local buttons = vb:horizontal_aligner {
        mode = "center",
        spacing = 10,
        vb:button {
            text = "Generate Shortcuts",
            notifier = function()
                -- Placeholder: Implement logic to generate shortcuts for selected plugins
                for id, name in pairs(selected_plugins) do
                    print("Generate shortcut for:", id)
                    -- Logic to generate shortcuts goes here
                end
            end
        },
        vb:button {
            text = "Cancel",
            notifier = function()
                if custom_dialog and custom_dialog.visible then
                    custom_dialog:close()
                end
            end
        }
    }

    custom_dialog_content = vb:column { content, buttons }
    custom_dialog = renoise.app():show_custom_dialog("Plugin List", custom_dialog_content)
end

-- Add a menu entry for easy access
renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:Paketti..:Generate Shortcuts",
    invoke = show_plugin_list_dialog
}

