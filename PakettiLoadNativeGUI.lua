function show_plugin_list_dialog()
    local vb = renoise.ViewBuilder()
    local checkboxes = {}

    local track_index = renoise.song().selected_track_index
    local available_devices = renoise.song().tracks[track_index].available_devices
    local deviceReadableNames = {}

    for i, device_path in ipairs(available_devices) do
        if device_path:find("Native/") then
            local device_name = device_path:match("([^/]+)$")
            deviceReadableNames[#deviceReadableNames + 1] = {name = device_name, path = device_path}
        end
    end

    table.sort(deviceReadableNames, function(a, b) return a.name < b.name end)

    local function create_scrollable_native_list()
        local left_column = vb:column {}
        local right_column = vb:column {}
        local num_devices = #deviceReadableNames
        local mid_point = math.ceil(num_devices / 2)

        for i, device in ipairs(deviceReadableNames) do
            local checkbox = vb:checkbox { value = false, id = "checkbox_native_" .. tostring(i) }
            checkboxes[#checkboxes + 1] = { checkbox = checkbox, path = device.path, name = device.name }
            local device_row = vb:row {
                checkbox,
                vb:text { text = device.name }
            }

            if i <= mid_point then
                left_column:add_child(device_row)
            else
                right_column:add_child(device_row)
            end
        end

        return vb:horizontal_aligner {
            mode = "left",
            spacing = 20,
            left_column,
            right_column
        }
    end

    local notAllowedInMaster = {
        ["#Multiband Send"] = true,
        ["#Send"] = true,
        ["#Sidechain"] = true,
        ["*Key Tracker"] = true,
        ["*Velocity Tracker"] = true
    }

    local notAllowedInSend = {
        ["*Key Tracker"] = true,
        ["*Velocity Tracker"] = true
    }

    local function loadSelectedNativeDevices()
        local track_type = renoise.song().tracks[track_index].type
        local notAllowedDevices = {}

        if track_type == renoise.Track.TRACK_TYPE_MASTER then
            notAllowedDevices = notAllowedInMaster
        elseif track_type == renoise.Track.TRACK_TYPE_SEND then
            notAllowedDevices = notAllowedInSend
        elseif track_type == renoise.Track.TRACK_TYPE_GROUP then
            notAllowedDevices = notAllowedInGroup
        end

        for _, cb_info in ipairs(checkboxes) do
            if cb_info.checkbox.value then
                local canLoad = not notAllowedDevices[cb_info.name]
                if canLoad then
                    local pluginPath = cb_info.path
                    print("Loading Native Device:", pluginPath)
                    loadnative(pluginPath)
                else
                    print("Device not allowed on this track type:", cb_info.name)
                end
            end
        end
    end

-- Placeholder for tracking added keybindings
local addedKeyBindings = {}

local function addAsShortcut()
    for _, cb_info in ipairs(checkboxes) do
        if cb_info.checkbox.value then
            local keyBindingName = "Global:Track Devices:Load " .. cb_info.name .. " (Native)"

            -- Check if we've already attempted to add this keybinding
            if not addedKeyBindings[keyBindingName] then
                print("Adding shortcut for: " .. cb_info.name)

                -- Attempt to add the keybinding, using pcall to catch any errors gracefully
                local success, err = pcall(function()
                    renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadnative(cb_info.path) end}
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
    local custom_dialog

   -- Define the action buttons and their behaviors
    local button_height = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
    local button_spacing = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
    local action_buttons = vb:column {
      uniform = true,
      width = "100%",
      vb:horizontal_aligner {
        vb:button {
            text = "Load Plugin",
            width = "50%",
            height = button_height,
            notifier = function()
                loadSelectedNativeDevice()
            end
        },
        vb:button {
            text = "Load Plugin & Close",
            width = "50%",
            height = button_height,
            notifier = function()
                loadSelectedNativeDevice()
                custom_dialog:close()
            end
        } 
      },
      vb:button {
          text = "Add as Shortcut",
          height = button_height,
          notifier = addAsShortcut
          
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
        create_scrollable_native_list(),
        action_buttons -- _and_shortcut
    }

    custom_dialog = renoise.app():show_custom_dialog("Load Native Device", dialog_content)
end


