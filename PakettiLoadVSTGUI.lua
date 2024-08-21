local vb = renoise.ViewBuilder()
local checkboxes = {}
local deviceReadableNames = {}
local addedKeyBindings = {}

function vstAddAsShortcut()
  for _, cb_info in ipairs(checkboxes) do
    if cb_info.checkbox.value then
      local keyBindingName = "Global:Track Devices:Load Device (VST) " .. cb_info.name
      local midiMappingName = "Track Devices:Paketti:Load Device (VST) " .. cb_info.name

      if not addedKeyBindings[keyBindingName] then
        print("Adding shortcut for: " .. cb_info.name)

        local success, err = pcall(function()
          renoise.tool():add_keybinding{name=keyBindingName, invoke=function() loadvst(cb_info.path) end}
          renoise.tool():add_midi_mapping{name=midiMappingName, invoke=function(message) if message:is_trigger() then  loadvst(cb_info.path) end end}
        end)

        if success then
          addedKeyBindings[keyBindingName] = true
          saveToPreferencesFile(keyBindingName, midiMappingName, cb_info.path)
        else
          print("Could not add keybinding for " .. cb_info.name .. ". It might already exist.")
        end
      else
        print("Keybinding for " .. cb_info.name .. " already added.")
      end
    end
  end
  renoise.app():show_status("Devices added. Open Settings -> Keys, search for 'Load Device' or Midi Mappings and search for 'Load Device'")
end

function vstCreateScrollableVSTList()
    table.sort(deviceReadableNames, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    local columns = {
        vb:column {},
        vb:column {},
        vb:column {},
        vb:column {}
    }

    local max_devices_per_column = 22

    for i, device in ipairs(deviceReadableNames) do
        local column_index = math.floor((i - 1) / max_devices_per_column) + 1
        local checkbox_id = "checkbox_vst_" .. tostring(i) .. "_" .. tostring(math.random(1000000))
        local checkbox = vb:checkbox { value = false, id = checkbox_id }
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

function vstResetSelection()
    for _, cb_info in ipairs(checkboxes) do
        cb_info.checkbox.value = false
    end
end

function vstRandomizeSelection()
    vstResetSelection()  -- Clear previous selections

    local numDevices = #checkboxes
    local numSelections = math.random(1, numDevices)

    local selectedIndices = {}
    while #selectedIndices < numSelections do
        local randIndex = math.random(1, numDevices)
        if not selectedIndices[randIndex] then
            selectedIndices[randIndex] = true
            checkboxes[randIndex].checkbox.value = true
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
            text = "Add Device(s) as Shortcut(s) & MidiMappings",
            height = button_height,
            notifier = vstAddAsShortcut
        },
        vb:button {
            text = "Randomize Selection",
            height = button_height,
            notifier = function()
                vstRandomizeSelection()
            end
        },
        vb:button { text="Select All",
        height=button_height,
        notifier=function()
        
    for _, cb_info in ipairs(checkboxes) do
        cb_info.checkbox.value = true
    end
end},        
        
        vb:button {
            text = "Reset Selection",
            height = button_height,
            notifier = function()
                vstResetSelection()
            end
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

