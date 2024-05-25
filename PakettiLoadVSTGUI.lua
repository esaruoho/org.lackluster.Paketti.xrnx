-- Declare variables at the beginning of the script to ensure they're available globally
local vb = renoise.ViewBuilder()
local checkboxes = {}
local deviceReadableNames = {}
local addedKeyBindings = {}

function vstAddAsShortcut()
    for _, cb_info in ipairs(checkboxes) do
        if cb_info.checkbox.value then
            local keyBindingName = ("Global:Track Devices:Load VST " .. cb_info.name .. " Device")

            -- Check if we've already attempted to add this keybinding
            if not addedKeyBindings[keyBindingName] then
                print("Adding shortcut for: " .. cb_info.name)

                -- Attempt to add the keybinding, using pcall to catch any errors gracefully
                local success, err = pcall(function()
                    renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadvst(cb_info.path) end}
                end)

                -- Check if the keybinding was added successfully
                if success then
                    addedKeyBindings[keyBindingName] = true
                else
                    print("Could not add keybinding for " .. cb_info.name .. ". It might already exist.")
                end
            else
                print("Keybinding for " .. cb_info.name .. " already added.")
            end
        end
    end
end

function vstCreateScrollableVSTList()
    -- Sort the devices alphabetically, case-insensitive
    table.sort(deviceReadableNames, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    local columns = {
        vb:column {},
        vb:column {},
        vb:column {},
        vb:column {}
    }

    local num_devices = #deviceReadableNames
    local num_columns = #columns
    local devices_per_column = math.ceil(num_devices / num_columns)

    for i, device in ipairs(deviceReadableNames) do
        local column_index = math.floor((i - 1) / devices_per_column) + 1
        local checkbox = vb:checkbox { value = false, id = "checkbox_vst_" .. tostring(i) }
        checkboxes[#checkboxes + 1] = { checkbox = checkbox, path = device.path, name = device.name }
        local device_row = vb:row {
            checkbox,
            vb:text { text = device.name }
        }

        columns[column_index]:add_child(device_row)
    end

    local column_container = vb:row {spacing = 20}
    for _, column in ipairs(columns) do
        column_container:add_child(column)
    end

    return column_container
end

function vstLoadSelectedVSTDevices()
    local track_index = renoise.song().selected_track_index
    for _, cb_info in ipairs(checkboxes) do
        if cb_info.checkbox.value then
            local pluginPath = cb_info.path
            print("Loading VST Device:", pluginPath)
            loadvst(pluginPath)
        end
    end
end

function vstShowPluginListDialog()
    checkboxes = {}  -- Reinitialize the checkboxes table to avoid carrying over previous states
    local track_index = renoise.song().selected_track_index
    local available_plugins = renoise.song().tracks[track_index].available_devices
    deviceReadableNames = {}

    for i, device_path in ipairs(available_plugins) do
        if device_path:find("VST") and not device_path:find("VST3") then
            local device_name = device_path:match("([^/]+)$")
            deviceReadableNames[#deviceReadableNames + 1] = {name = device_name, path = device_path}
        end
    end

    local custom_dialog

    -- Define the action buttons and their behaviors
    local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
    local button_spacing = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
    local action_buttons = vb:column {
        uniform = true,
        width = "100%",
        vb:horizontal_aligner {
            vb:button {
                text = "Load Device(s)",
                width = "50%",
                height = button_height,
                notifier = function()
                    vstLoadSelectedVSTDevices()
                end
            },
            vb:button {
                text = "Load Device(s) & Close",
                width = "50%",
                height = button_height,
                notifier = function()
                    vstLoadSelectedVSTDevices()
                    custom_dialog:close()
                end
            }
        },
        vb:button {
            text = "Add Device(s) as Shortcut(s)",
            height = button_height,
            notifier = vstAddAsShortcut
        },
        vb:button {
            text = "Cancel",
            height = button_height,
            notifier = function()
                custom_dialog:close()
            end
        }
    }

    local dialog_content = vb:column {
        margin = 10,
        spacing = 5,
        vstCreateScrollableVSTList(),
        action_buttons
    }

    custom_dialog = renoise.app():show_custom_dialog("Load VST Device(s)", dialog_content)
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Load VST Devices Dialog",invoke=vstShowPluginListDialog}

